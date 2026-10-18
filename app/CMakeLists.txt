# Loadstone Mod Manager — C++ wxWidgets shell over the Rust core.
#
# Configure on Windows (from a VS developer environment):
#   cmake -S app -B build -G Ninja -DCMAKE_BUILD_TYPE=Release ^
#         -DCMAKE_PREFIX_PATH=C:/path/to/wx-static
# Configure on macOS (wxWidgets from Homebrew, found through wx-config):
#   cmake -S app -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
# Build:
#   cmake --build build
#
# Windows produces build/loadstone-manager.exe; macOS produces the
# build/Loadstone.app bundle.
#
# The Rust side (loadstone-bridge staticlib + generated cxx headers) is built
# by cargo as part of this build; cargo's own caching makes the extra
# invocation a no-op when nothing changed.

cmake_minimum_required(VERSION 3.24)
project(loadstone-app VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Rust bridge -------------------------------------------------------------
set(REPO_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(CARGO_TARGET_DIR "${REPO_ROOT}/target")
# A prebuilt bridge (scripts/build_macos_app.sh passes a universal one made
# with lipo); otherwise cargo builds it for the host as part of this build.
set(LOADSTONE_BRIDGE_LIB "" CACHE FILEPATH "Prebuilt loadstone-bridge static library")
if(LOADSTONE_BRIDGE_LIB)
    set(BRIDGE_LIB "${LOADSTONE_BRIDGE_LIB}")
    add_custom_target(bridge)
else()
    if(WIN32)
        set(BRIDGE_LIB "${CARGO_TARGET_DIR}/release/loadstone_bridge.lib")
    else()
        set(BRIDGE_LIB "${CARGO_TARGET_DIR}/release/libloadstone_bridge.a")
    endif()
    add_custom_target(bridge
        COMMAND cargo build -p loadstone-bridge --release
        WORKING_DIRECTORY "${REPO_ROOT}"
        BYPRODUCTS "${BRIDGE_LIB}"
        COMMENT "cargo build loadstone-bridge"
        VERBATIM
    )
endif()

# --- wxWidgets ----------------------------------------------------------------
# Windows links a static wx build through its CMake package; elsewhere the
# stock FindwxWidgets module asks wx-config (Homebrew's wxwidgets ships no
# CMake package).
if(WIN32)
    find_package(wxWidgets CONFIG REQUIRED COMPONENTS core base)
    set(WX_TARGETS wx::core wx::base)
else()
    find_package(wxWidgets REQUIRED COMPONENTS core base)
    include(${wxWidgets_USE_FILE})
    set(WX_TARGETS ${wxWidgets_LIBRARIES})
endif()

# --- The app -----------------------------------------------------------------
add_executable(loadstone-manager WIN32 MACOSX_BUNDLE
    src/main.cpp
)
add_dependencies(loadstone-manager bridge)
# Branded installer builds rename the product (the macOS bundle name and id,
# the Windows exe name).
set(LOADSTONE_APP_NAME "" CACHE STRING "Product name for a branded build (default: Loadstone)")
set(LOADSTONE_BUNDLE_ID "com.bradjrenshaw.loadstone" CACHE STRING "macOS bundle identifier")
if(LOADSTONE_APP_NAME)
    set_target_properties(loadstone-manager PROPERTIES OUTPUT_NAME "${LOADSTONE_APP_NAME}")
    set(APP_NAME "${LOADSTONE_APP_NAME}")
else()
    set(APP_NAME "Loadstone")
endif()
if(APPLE)
    set_target_properties(loadstone-manager PROPERTIES
        OUTPUT_NAME "${APP_NAME}"
        MACOSX_BUNDLE_BUNDLE_NAME "${APP_NAME}"
        MACOSX_BUNDLE_GUI_IDENTIFIER "${LOADSTONE_BUNDLE_ID}"
        MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    )
endif()

# Compile-time distribution profile for branded installer builds. Point
# LOADSTONE_EMBED_PROFILE at a profile JSON file to bake it into the exe;
# unset, the generated header carries "null" and the profile resolves at
# runtime (loadstone.json sidecar, else the default manager profile).
# NOTE: file(READ) runs at configure time — re-run CMake configure after
# editing the profile file.
set(LOADSTONE_EMBED_PROFILE "" CACHE FILEPATH "Distribution profile JSON to embed into the executable")
if(LOADSTONE_EMBED_PROFILE)
    file(READ "${LOADSTONE_EMBED_PROFILE}" LOADSTONE_PROFILE_JSON)
    message(STATUS "Embedding distribution profile: ${LOADSTONE_EMBED_PROFILE}")
else()
    set(LOADSTONE_PROFILE_JSON "null")
endif()
configure_file(src/embedded_profile.h.in "${CMAKE_BINARY_DIR}/generated/embedded_profile.h" @ONLY)

target_include_directories(loadstone-manager PRIVATE
    "${CMAKE_BINARY_DIR}/generated"
    "${CARGO_TARGET_DIR}/cxxbridge"
    # For loadstone-bridge/include/ui_callbacks.h (the callback interface
    # the app implements).
    "${REPO_ROOT}/crates"
)

# Native libs the Rust staticlib needs (from `cargo rustc -p loadstone-bridge
# --release -- --print native-static-libs`).
if(WIN32)
    # userenv/ws2_32/dbghelp cover std + reqwest.
    set(RUST_NATIVE_LIBS kernel32 ntdll userenv ws2_32 dbghelp)
elseif(APPLE)
    # std + reqwest's native TLS.
    set(RUST_NATIVE_LIBS
        "-framework Security" "-framework CoreFoundation"
        "-framework SystemConfiguration" iconv c m)
else()
    set(RUST_NATIVE_LIBS ssl crypto gcc_s util rt pthread m dl c)
endif()

target_link_libraries(loadstone-manager PRIVATE
    ${WX_TARGETS}
    "${BRIDGE_LIB}"
    ${RUST_NATIVE_LIBS}
)

if(MSVC)
    target_compile_options(loadstone-manager PRIVATE /W4 /utf-8)
endif()
