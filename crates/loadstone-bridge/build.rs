fn main() {
    // Generates the C++ side of the bridge and compiles it into this
    // staticlib. Headers are exported to <target-dir>/cxxbridge/, which the
    // app's CMakeLists adds to its include path.
    cxx_build::bridge("src/lib.rs").std("c++17").compile("loadstone-bridge");
    println!("cargo:rerun-if-changed=src/lib.rs");
}
