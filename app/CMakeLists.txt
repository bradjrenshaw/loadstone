# Loadstone Mod Manager — C++ wxWidgets shell over the Rust core.
#
# Configure (from a VS developer environment):
#   cmake -S app -B build -G Ninja -DCMAKE_BUILD_TYPE=Release ^
#         -DCMAKE_PREFIX_PATH=C:/path/to/wx-static
# Build:
#   cmake --build build
#
# The Rust side (loadstone-bridge staticlib + generated cxx headers) is built
# by cargo as part of this build; cargo's own caching makes the extra
# invocation a no-op when nothing changed.

cmake_minimum_required(VERSION 3.24)
project(loadstone-app CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Rust bridge -------------------------------------------------------------
set(REPO_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(CARGO_TARGET_DIR "${REPO_ROOT}/target")
set(BRIDGE_LIB "${CARGO_TARGET_DIR}/release/loadstone_bridge.lib")

add_custom_target(bridge
    COMMAND cargo build -p loadstone-bridge --release
    WORKING_DIRECTORY "${REPO_ROOT}"
    BYPRODUCTS "${BRIDGE_LIB}"
    COMMENT "cargo build loadstone-bridge"
    VERBATIM
)

# --- wxWidgets (static) ------------------------------------------------------
find_package(wxWidgets CONFIG REQUIRED COMPONENTS core base)

# --- The app -----------------------------------------------------------------
add_executable(loadstone-manager WIN32
    src/main.cpp
)
add_dependencies(loadstone-manager bridge)

target_include_directories(loadstone-manager PRIVATE
    "${CARGO_TARGET_DIR}/cxxbridge"
    # For loadstone-bridge/include/ui_callbacks.h (the callback interface
    # the app implements).
    "${REPO_ROOT}/crates"
)

target_link_libraries(loadstone-manager PRIVATE
    wx::core wx::base
    "${BRIDGE_LIB}"
    # Native libs the Rust staticlib needs (from `cargo rustc -- --print
    # native-static-libs`); userenv/ws2_32/dbghelp cover std + reqwest.
    kernel32 ntdll userenv ws2_32 dbghelp
)

if(MSVC)
    target_compile_options(loadstone-manager PRIVATE /W4 /utf-8)
endif()
