fn main() {
    // Generates the C++ side of the bridge and compiles it into this
    // staticlib. Headers are exported to <target-dir>/cxxbridge/, which the
    // app's CMakeLists adds to its include path.
    //
    // The extra include path makes `include!("loadstone-bridge/include/...")`
    // resolve (it points at the crates/ directory containing this crate).
    let crates_dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("crate has a parent directory")
        .to_path_buf();
    cxx_build::bridge("src/lib.rs")
        .std("c++17")
        .include(crates_dir)
        .compile("loadstone-bridge");
    println!("cargo:rerun-if-changed=src/lib.rs");
    println!("cargo:rerun-if-changed=include/ui_callbacks.h");
}
