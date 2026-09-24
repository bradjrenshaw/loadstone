//! Universal (fat) Mach-O assembly for the `merge-universal-binary` step
//! (SPEC §9.11): the pure-Rust equivalent of `lipo -create`, because end
//! users' Macs have no `lipo` (it needs the Xcode command line tools).
//!
//! Why the engine needs this at all: on macOS the Lovely Injector is loaded
//! with `DYLD_INSERT_LIBRARIES`, and dyld aborts the game when the inserted
//! library has no slice for the process's architecture. Steam may run the
//! game natively (arm64) or translated (x86_64 under Rosetta) depending on
//! the Steam client, so the only injector that works everywhere carries
//! both slices. Upstream ships one thin dylib per architecture; the
//! registry downloads both and the engine combines them here.
//!
//! Format (mach-o/fat.h): a big-endian header `{ magic 0xCAFEBABE, nfat_arch }`
//! followed by one `{ cputype, cpusubtype, offset, size, align }` record per
//! slice, then the slices at their offsets. Each slice is a byte-exact copy
//! of the thin file, so per-slice code signatures stay valid.

use std::collections::BTreeSet;

use anyhow::{bail, Result};

const FAT_MAGIC: u32 = 0xCAFE_BABE;
const MH_MAGIC_64: u32 = 0xFEED_FACF;
const MH_MAGIC: u32 = 0xFEED_FACE;
/// 2^14: the page alignment arm64 slices require; harmless for x86_64.
const SLICE_ALIGN_LOG2: u32 = 14;

/// One thin Mach-O image: its CPU identity and bytes.
pub struct Slice {
    pub cputype: u32,
    pub cpusubtype: u32,
    pub data: Vec<u8>,
}

fn be32(b: &[u8], at: usize) -> Option<u32> {
    b.get(at..at + 4).map(|x| u32::from_be_bytes([x[0], x[1], x[2], x[3]]))
}

fn le32(b: &[u8], at: usize) -> Option<u32> {
    b.get(at..at + 4).map(|x| u32::from_le_bytes([x[0], x[1], x[2], x[3]]))
}

/// Split a Mach-O file into its slices: one for a thin file, several for
/// an already-universal one. Rejects anything that is not Mach-O.
pub fn slices_of(data: &[u8]) -> Result<Vec<Slice>> {
    match be32(data, 0) {
        Some(FAT_MAGIC) => {
            let n = be32(data, 4).unwrap_or(0) as usize;
            let mut out = Vec::with_capacity(n);
            for i in 0..n {
                let rec = 8 + i * 20;
                let (Some(cputype), Some(cpusubtype), Some(offset), Some(size)) =
                    (be32(data, rec), be32(data, rec + 4), be32(data, rec + 8), be32(data, rec + 12))
                else {
                    bail!("truncated universal binary header");
                };
                let (start, end) = (offset as usize, offset as usize + size as usize);
                let Some(bytes) = data.get(start..end) else {
                    bail!("universal binary slice {i} lies outside the file");
                };
                out.push(Slice { cputype, cpusubtype, data: bytes.to_vec() });
            }
            Ok(out)
        }
        _ => {
            // Thin images are little-endian on every platform Apple ships.
            match le32(data, 0) {
                Some(MH_MAGIC_64) | Some(MH_MAGIC) => {}
                _ => bail!("not a Mach-O file"),
            }
            let (Some(cputype), Some(cpusubtype)) = (le32(data, 4), le32(data, 8)) else {
                bail!("truncated Mach-O header");
            };
            Ok(vec![Slice { cputype, cpusubtype, data: data.to_vec() }])
        }
    }
}

/// Combine the inputs (thin or fat) into one universal binary. Every input
/// slice must be a distinct architecture.
pub fn merge(inputs: &[Vec<u8>]) -> Result<Vec<u8>> {
    let mut slices = Vec::new();
    for input in inputs {
        slices.extend(slices_of(input)?);
    }
    if slices.len() < 2 {
        bail!("a universal binary needs at least two architectures");
    }
    let mut seen = BTreeSet::new();
    for s in &slices {
        if !seen.insert(s.cputype) {
            bail!("two inputs carry the same architecture (cputype {:#x})", s.cputype);
        }
    }

    let align = 1usize << SLICE_ALIGN_LOG2;
    let header_len = 8 + 20 * slices.len();
    let mut offset = header_len.div_ceil(align) * align;
    let mut records = Vec::with_capacity(slices.len());
    for s in &slices {
        records.push((s.cputype, s.cpusubtype, offset, s.data.len()));
        offset = (offset + s.data.len()).div_ceil(align) * align;
    }

    let mut out = vec![0u8; offset];
    out[0..4].copy_from_slice(&FAT_MAGIC.to_be_bytes());
    out[4..8].copy_from_slice(&(slices.len() as u32).to_be_bytes());
    for (i, (cputype, cpusubtype, off, size)) in records.iter().enumerate() {
        let rec = 8 + i * 20;
        if *off > u32::MAX as usize || *size > u32::MAX as usize {
            bail!("input too large for a universal binary");
        }
        out[rec..rec + 4].copy_from_slice(&cputype.to_be_bytes());
        out[rec + 4..rec + 8].copy_from_slice(&cpusubtype.to_be_bytes());
        out[rec + 8..rec + 12].copy_from_slice(&(*off as u32).to_be_bytes());
        out[rec + 12..rec + 16].copy_from_slice(&(*size as u32).to_be_bytes());
        out[rec + 16..rec + 20].copy_from_slice(&SLICE_ALIGN_LOG2.to_be_bytes());
    }
    for (s, (_, _, off, size)) in slices.iter().zip(&records) {
        out[*off..*off + *size].copy_from_slice(&s.data);
    }
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    const CPU_X86_64: u32 = 0x0100_0007;
    const CPU_ARM64: u32 = 0x0100_000C;

    fn thin(cputype: u32, body: &[u8]) -> Vec<u8> {
        let mut v = Vec::new();
        v.extend_from_slice(&MH_MAGIC_64.to_le_bytes());
        v.extend_from_slice(&cputype.to_le_bytes());
        v.extend_from_slice(&3u32.to_le_bytes()); // cpusubtype
        v.extend_from_slice(body);
        v
    }

    #[test]
    fn merges_two_thin_images_and_round_trips() {
        let a = thin(CPU_X86_64, b"intel slice");
        let b = thin(CPU_ARM64, b"arm slice, a bit longer");
        let fat = merge(&[a.clone(), b.clone()]).unwrap();
        assert_eq!(&fat[0..4], &FAT_MAGIC.to_be_bytes());
        let back = slices_of(&fat).unwrap();
        assert_eq!(back.len(), 2);
        assert_eq!(back[0].cputype, CPU_X86_64);
        assert_eq!(back[0].data, a);
        assert_eq!(back[1].cputype, CPU_ARM64);
        assert_eq!(back[1].data, b);
        // Slices sit on 16 KiB boundaries, as arm64 requires.
        let first_off = be32(&fat, 8 + 8).unwrap();
        assert_eq!(first_off % (1 << SLICE_ALIGN_LOG2), 0);
    }

    #[test]
    fn accepts_an_already_fat_input_and_rejects_duplicates() {
        let a = thin(CPU_X86_64, b"x");
        let b = thin(CPU_ARM64, b"y");
        let fat = merge(&[a.clone(), b.clone()]).unwrap();
        // Re-merging a fat file with nothing new is a duplicate.
        let err = merge(&[fat.clone(), a.clone()]).unwrap_err();
        assert!(err.to_string().contains("same architecture"), "{err}");
        // But a fat input plus a genuinely new arch is fine.
        let c = thin(0x0100_0012, b"z");
        assert_eq!(slices_of(&merge(&[fat, c]).unwrap()).unwrap().len(), 3);
    }

    #[test]
    fn rejects_non_mach_o_and_single_input() {
        assert!(slices_of(b"MZ\x90\x00 not mach-o at all").is_err());
        assert!(merge(&[thin(CPU_ARM64, b"only one")]).is_err());
    }
}
