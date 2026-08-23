// Embeds a distribution profile at compile time when LOADSTONE_EMBED_PROFILE
// points at a JSON file — that build of the binary becomes a branded
// installer (see loadstone-core::profile). Unset: writes "null" and the
// binary resolves its profile at runtime (sidecar file or default).

use std::env;
use std::fs;
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-env-changed=LOADSTONE_EMBED_PROFILE");
    let out_dir = env::var("OUT_DIR").expect("OUT_DIR not set");
    let dest = Path::new(&out_dir).join("embedded_profile.json");
    let content = match env::var("LOADSTONE_EMBED_PROFILE") {
        Ok(path) if !path.trim().is_empty() => {
            println!("cargo:rerun-if-changed={path}");
            fs::read_to_string(&path)
                .unwrap_or_else(|e| panic!("LOADSTONE_EMBED_PROFILE={path}: {e}"))
        }
        _ => "null".to_string(),
    };
    fs::write(&dest, content).expect("failed to write embedded profile");
}
