//! The edit-ini step (SPEC 9.12): set or remove keys in an INI-style config
//! file while leaving every other byte of it alone — comments, ordering,
//! spacing, line endings, a byte-order mark, and the file's encoding
//! (UTF-8, UTF-16 with a byte-order mark, or bytes kept as they are).
//!
//! Keys and section names compare case-insensitively, as INI readers do.
//! Without a `section`, an op addresses the first line with that key
//! anywhere in the file, and `set` appends a missing key at the end.

use std::path::Path;

use anyhow::{bail, Context as _, Result};
use serde_json::Value;

use crate::types::{IniOp, IniOpKind};

#[derive(Clone, Copy, PartialEq, Eq)]
enum Encoding {
    Utf8,
    /// Not valid UTF-8: read byte-per-char so it round-trips unchanged.
    Latin1,
    /// UTF-16 with a byte-order mark, as Windows programs often write.
    Utf16Le,
    Utf16Be,
}

struct Document {
    bom: bool,
    encoding: Encoding,
    newline: &'static str,
    trailing_newline: bool,
    lines: Vec<String>,
}

impl Document {
    fn parse(bytes: &[u8], file: &Path) -> Result<Document> {
        let utf16 = |body: &[u8], from: fn([u8; 2]) -> u16| -> Result<String> {
            let (pairs, odd) = body.as_chunks::<2>();
            if !odd.is_empty() {
                bail!("{} starts with a UTF-16 byte-order mark but has an odd length", file.display());
            }
            let units: Vec<u16> = pairs.iter().map(|&pair| from(pair)).collect();
            String::from_utf16(&units).with_context(|| format!("{} is not valid UTF-16", file.display()))
        };
        let (bom, text, encoding) = if let Some(body) = bytes.strip_prefix(&[0xFF, 0xFE]) {
            (true, utf16(body, u16::from_le_bytes)?, Encoding::Utf16Le)
        } else if let Some(body) = bytes.strip_prefix(&[0xFE, 0xFF]) {
            (true, utf16(body, u16::from_be_bytes)?, Encoding::Utf16Be)
        } else {
            let (bom, body) = match bytes.strip_prefix(&[0xEF, 0xBB, 0xBF]) {
                Some(rest) => (true, rest),
                None => (false, bytes),
            };
            // Text files hold no NUL bytes; these are almost surely UTF-16
            // without a byte-order mark, which can't be edited safely.
            if body.contains(&0) {
                bail!(
                    "{} looks like UTF-16 text without a byte-order mark; refusing to edit it",
                    file.display()
                );
            }
            match std::str::from_utf8(body) {
                Ok(t) => (bom, t.to_string(), Encoding::Utf8),
                Err(_) => (bom, body.iter().map(|&b| b as char).collect(), Encoding::Latin1),
            }
        };
        let newline = if text.contains("\r\n") { "\r\n" } else { "\n" };
        let trailing_newline = text.is_empty() || text.ends_with('\n');
        let mut lines: Vec<String> = text
            .split('\n')
            .map(|l| l.strip_suffix('\r').unwrap_or(l).to_string())
            .collect();
        if trailing_newline {
            lines.pop(); // the empty remainder after the final newline
        }
        Ok(Document { bom, encoding, newline, trailing_newline, lines })
    }

    fn render(&self) -> Result<Vec<u8>> {
        let mut text = self.lines.join(self.newline);
        if self.trailing_newline && !self.lines.is_empty() {
            text.push_str(self.newline);
        }
        let mut out = Vec::with_capacity(text.len() + 3);
        match self.encoding {
            Encoding::Utf8 | Encoding::Latin1 if self.bom => out.extend_from_slice(&[0xEF, 0xBB, 0xBF]),
            _ => {}
        }
        match self.encoding {
            Encoding::Utf8 => out.extend_from_slice(text.as_bytes()),
            Encoding::Utf16Le => {
                out.extend_from_slice(&[0xFF, 0xFE]);
                out.extend(text.encode_utf16().flat_map(u16::to_le_bytes));
            }
            Encoding::Utf16Be => {
                out.extend_from_slice(&[0xFE, 0xFF]);
                out.extend(text.encode_utf16().flat_map(u16::to_be_bytes));
            }
            Encoding::Latin1 => {
                for c in text.chars() {
                    let code = c as u32;
                    if code > 0xFF {
                        bail!("cannot write \"{c}\" into a file that is not UTF-8");
                    }
                    out.push(code as u8);
                }
            }
        }
        Ok(out)
    }

    /// For every line: the section it sits in (None before the first
    /// header) and, for key lines, the key.
    fn layout(&self) -> Vec<(Option<String>, LineKind)> {
        let mut section = None;
        self.lines
            .iter()
            .map(|line| {
                let kind = classify(line);
                if let LineKind::Header(name) = &kind {
                    section = Some(name.clone());
                }
                (section.clone(), kind)
            })
            .collect()
    }

    fn find_key(&self, section: Option<&str>, key: &str) -> Vec<usize> {
        self.layout()
            .iter()
            .enumerate()
            .filter(|(_, (sec, kind))| {
                matches!(kind, LineKind::Key(k) if k.eq_ignore_ascii_case(key))
                    && match section {
                        Some(want) => sec.as_deref().is_some_and(|s| s.eq_ignore_ascii_case(want)),
                        None => true,
                    }
            })
            .map(|(i, _)| i)
            .collect()
    }

    /// Index just past the last non-blank line of `section`, or None when
    /// the file has no such section.
    fn section_end(&self, section: &str) -> Option<usize> {
        let layout = self.layout();
        let mut end = None;
        for (i, (sec, kind)) in layout.iter().enumerate() {
            let inside = sec.as_deref().is_some_and(|s| s.eq_ignore_ascii_case(section));
            if inside && !matches!(kind, LineKind::Blank) {
                end = Some(i + 1);
            }
        }
        end
    }
}

#[derive(Debug, PartialEq)]
enum LineKind {
    Blank,
    Comment,
    Header(String),
    Key(String),
    Other,
}

fn classify(line: &str) -> LineKind {
    let t = line.trim();
    if t.is_empty() {
        LineKind::Blank
    } else if t.starts_with(';') || t.starts_with('#') {
        LineKind::Comment
    } else if t.starts_with('[') {
        match t.find(']') {
            Some(end) => LineKind::Header(t[1..end].trim().to_string()),
            None => LineKind::Other,
        }
    } else if let Some(eq) = t.find('=') {
        LineKind::Key(t[..eq].trim().to_string())
    } else {
        LineKind::Other
    }
}

/// Replace the value on a `key = value` line, keeping the spacing around
/// `=` and any trailing whitespace.
fn replace_value(line: &str, value: &str) -> String {
    let eq = line.find('=').expect("key lines contain '='");
    let after = &line[eq + 1..];
    let lead = after.len() - after.trim_start().len();
    let trail = after.len() - after.trim_end().len();
    let start = eq + 1 + lead;
    let end = line.len() - trail;
    if start >= end {
        // Empty value: keep the spacing before it, then the new value.
        return format!("{}{}", &line[..start.min(line.len())], value);
    }
    format!("{}{}{}", &line[..start], value, &line[end..])
}

pub fn value_text(value: &Value) -> Result<String> {
    match value {
        Value::String(s) => Ok(s.clone()),
        Value::Number(_) | Value::Bool(_) => Ok(value.to_string()),
        _ => bail!("INI values must be a string, number, or boolean"),
    }
}

/// Apply `ops` to `file`. Writes only when something changed (an already
/// correct file keeps its timestamp), atomically.
pub fn apply_ops(file: &Path, create_if_missing: bool, ops: &[IniOp]) -> Result<bool> {
    let mut doc = if file.exists() {
        Document::parse(
            &std::fs::read(file).with_context(|| format!("failed to read {}", file.display()))?,
            file,
        )?
    } else if create_if_missing {
        Document::parse(b"", file)?
    } else {
        bail!("{} does not exist", file.display());
    };
    let before = doc.lines.clone();

    for op in ops {
        let section = op.section.as_deref();
        match op.op {
            IniOpKind::Set => {
                let value = value_text(op.value.as_ref().context("set requires a value")?)?;
                let hits = doc.find_key(section, &op.key);
                if let Some(&first) = hits.first() {
                    doc.lines[first] = replace_value(&doc.lines[first], &value);
                    continue;
                }
                let new_line = format!("{} = {}", op.key, value);
                match section {
                    None => doc.lines.push(new_line),
                    Some(sec) => match doc.section_end(sec) {
                        Some(at) => doc.lines.insert(at, new_line),
                        None => {
                            if doc.lines.last().is_some_and(|l| !l.trim().is_empty()) {
                                doc.lines.push(String::new());
                            }
                            doc.lines.push(format!("[{sec}]"));
                            doc.lines.push(new_line);
                        }
                    },
                }
            }
            IniOpKind::RemoveKey => {
                for i in doc.find_key(section, &op.key).into_iter().rev() {
                    doc.lines.remove(i);
                }
            }
        }
    }

    if doc.lines == before && file.exists() {
        return Ok(false);
    }
    let bytes = doc.render()?;
    if let Some(parent) = file.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("failed to create {}", parent.display()))?;
    }
    let tmp = file.with_extension("loadstone-tmp");
    std::fs::write(&tmp, &bytes).with_context(|| format!("failed to write {}", tmp.display()))?;
    std::fs::rename(&tmp, file).with_context(|| format!("failed to replace {}", file.display()))?;
    Ok(true)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ops(v: serde_json::Value) -> Vec<IniOp> {
        serde_json::from_value(v).unwrap()
    }

    fn edit(initial: &[u8], o: serde_json::Value) -> Vec<u8> {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("config.ini");
        std::fs::write(&f, initial).unwrap();
        apply_ops(&f, false, &ops(o)).unwrap();
        std::fs::read(&f).unwrap()
    }

    #[test]
    fn set_replaces_in_place_keeping_layout_and_crlf() {
        let out = edit(
            b"; Civ config\r\n[Debug]\r\nloggingenabled  =   0  \r\nOther = 2\r\n",
            serde_json::json!([{ "op": "set", "key": "LoggingEnabled", "value": 1 }]),
        );
        assert_eq!(out, b"; Civ config\r\n[Debug]\r\nloggingenabled  =   1  \r\nOther = 2\r\n");
    }

    #[test]
    fn set_appends_a_missing_key_at_the_end() {
        let out = edit(b"[A]\nx = 1\n", serde_json::json!([{ "op": "set", "key": "LoggingEnabled", "value": "1" }]));
        assert_eq!(out, b"[A]\nx = 1\nLoggingEnabled = 1\n");
    }

    #[test]
    fn sections_scope_lookups_and_inserts() {
        let out = edit(
            b"[A]\nkey = a\n\n[B]\nother = 1\n\n",
            serde_json::json!([
                { "op": "set", "section": "b", "key": "key", "value": "b" },
                { "op": "set", "section": "C", "key": "new", "value": "c" }
            ]),
        );
        assert_eq!(out, b"[A]\nkey = a\n\n[B]\nother = 1\nkey = b\n\n[C]\nnew = c\n");
    }

    #[test]
    fn remove_key_and_bom_and_non_utf8_survive() {
        let mut initial = vec![0xEF, 0xBB, 0xBF];
        initial.extend_from_slice(b"Name = Caf\xE9\nDrop = 1\n");
        // Not valid UTF-8 after the BOM: the 0xE9 byte must come back intact.
        let out = edit(&initial, serde_json::json!([{ "op": "remove-key", "key": "drop" }]));
        let mut expected = vec![0xEF, 0xBB, 0xBF];
        expected.extend_from_slice(b"Name = Caf\xE9\n");
        assert_eq!(out, expected);
    }

    fn utf16le(text: &str) -> Vec<u8> {
        let mut out = vec![0xFF, 0xFE];
        out.extend(text.encode_utf16().flat_map(u16::to_le_bytes));
        out
    }

    #[test]
    fn utf16_files_are_edited_in_their_own_encoding() {
        let out = edit(
            &utf16le("[Debug]\r\nLoggingEnabled = 0\r\nName = Café\r\n"),
            serde_json::json!([
                { "op": "set", "key": "loggingenabled", "value": 1 },
                { "op": "set", "key": "New", "value": "x" }
            ]),
        );
        assert_eq!(out, utf16le("[Debug]\r\nLoggingEnabled = 1\r\nName = Café\r\nNew = x\r\n"));

        let mut be = vec![0xFE, 0xFF];
        be.extend("a = 1\n".encode_utf16().flat_map(u16::to_be_bytes));
        let out = edit(&be, serde_json::json!([{ "op": "set", "key": "a", "value": 2 }]));
        let mut expected = vec![0xFE, 0xFF];
        expected.extend("a = 2\n".encode_utf16().flat_map(u16::to_be_bytes));
        assert_eq!(out, expected);
    }

    #[test]
    fn utf16_without_a_bom_is_refused_untouched() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("config.ini");
        let bytes: Vec<u8> = "a = 1\r\n".encode_utf16().flat_map(u16::to_le_bytes).collect();
        std::fs::write(&f, &bytes).unwrap();
        let err = apply_ops(&f, false, &ops(serde_json::json!([{ "op": "set", "key": "a", "value": 2 }]))).unwrap_err();
        assert!(format!("{err:#}").contains("UTF-16"), "{err:#}");
        assert_eq!(std::fs::read(&f).unwrap(), bytes);
    }

    #[test]
    fn unchanged_file_is_not_rewritten_and_missing_file_errors() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("c.ini");
        std::fs::write(&f, b"LoggingEnabled = 1\n").unwrap();
        let changed = apply_ops(&f, false, &ops(serde_json::json!([{ "op": "set", "key": "LoggingEnabled", "value": 1 }]))).unwrap();
        assert!(!changed);
        assert!(apply_ops(&tmp.path().join("absent.ini"), false, &ops(serde_json::json!([{ "op": "set", "key": "a", "value": 1 }]))).is_err());
        assert!(apply_ops(&tmp.path().join("new.ini"), true, &ops(serde_json::json!([{ "op": "set", "key": "a", "value": 1 }]))).unwrap());
        assert_eq!(std::fs::read(tmp.path().join("new.ini")).unwrap(), b"a = 1\n");
    }
}
