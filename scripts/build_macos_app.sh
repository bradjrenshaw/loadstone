#!/bin/bash
# build_macos_app.sh — build a distributable Loadstone .app for macOS.
#
# `cmake --build build` makes a development app linked against Homebrew's
# wxWidgets, which only runs on machines that have it. This script makes the
# one you hand to users:
#   - universal (arm64 + x86_64), macOS 11+
#   - wxWidgets linked statically (built once from source, then cached)
#   - optionally a branded installer: a distribution profile baked in, its own
#     name and bundle id
#   - ad-hoc signed (Apple Silicon refuses to run unsigned code; this is not
#     a Developer ID signature, so Gatekeeper still asks on first open)
#
# Usage:
#   scripts/build_macos_app.sh                                   the manager
#   scripts/build_macos_app.sh --profile <profile.json> \
#       --name "Blindfold Installer" --bundle-id com.example.installer \
#       --out <dir>
#
# The app lands at <out>/<name>.app (default: dist/Loadstone.app).
# Needs: Xcode command line tools, cmake, rustup targets aarch64-apple-darwin
# and x86_64-apple-darwin. The wxWidgets build goes to
# ~/Library/Caches/loadstone/ (override with LOADSTONE_WX_PREFIX).

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
profile=""
name="Loadstone"
bundle_id="com.bradjrenshaw.loadstone"
out="$repo/dist"
while [ $# -gt 0 ]; do
    case "$1" in
        --profile) profile="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"; shift 2 ;;
        --name) name="$2"; shift 2 ;;
        --bundle-id) bundle_id="$2"; shift 2 ;;
        --out) mkdir -p "$2"; out="$(cd "$2" && pwd)"; shift 2 ;;
        -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
[ -z "$profile" ] || [ -f "$profile" ] || { echo "Profile not found: $profile" >&2; exit 1; }
mkdir -p "$out"

step() { echo "== $*"; }
export MACOSX_DEPLOYMENT_TARGET=11.0
jobs="$(sysctl -n hw.ncpu)"

# --- wxWidgets, static and universal ----------------------------------------
# 3.2.x to match the Windows build. Built with its bundled image/zlib/expat/
# regex copies so nothing from Homebrew leaks into the link.
wx_version=3.2.8
wx_prefix="${LOADSTONE_WX_PREFIX:-$HOME/Library/Caches/loadstone/wx-$wx_version-static-universal}"
if [ ! -x "$wx_prefix/bin/wx-config" ]; then
    step "Building wxWidgets $wx_version (static, universal; one-time, several minutes)"
    work="$(mktemp -d "${TMPDIR:-/tmp}/loadstone-wx-XXXXXX")"
    curl -fsSL -o "$work/wx.tar.bz2" \
        "https://github.com/wxWidgets/wxWidgets/releases/download/v$wx_version/wxWidgets-$wx_version.tar.bz2"
    tar -xjf "$work/wx.tar.bz2" -C "$work"
    mkdir "$work/build"
    (cd "$work/build" && "../wxWidgets-$wx_version/configure" \
        --prefix="$wx_prefix" \
        --disable-shared \
        --enable-universal_binary=arm64,x86_64 \
        --with-osx_cocoa \
        --with-macosx-version-min=11.0 \
        --with-libpng=builtin --with-libjpeg=builtin --with-libtiff=builtin \
        --with-zlib=builtin --with-expat=builtin --with-regex=builtin \
        --without-liblzma --without-libcurl \
        --disable-webview --disable-mediactrl \
        >"$work/configure.log" 2>&1 || { tail -30 "$work/configure.log" >&2; exit 1; })
    (cd "$work/build" && make -j"$jobs" >"$work/make.log" 2>&1 || { tail -30 "$work/make.log" >&2; exit 1; })
    (cd "$work/build" && make install >/dev/null)
    rm -rf "$work"
fi
echo "   wxWidgets: $wx_prefix"

# --- The Rust bridge, both architectures ------------------------------------
universal_dir="$repo/target/universal-apple-darwin/release"
mkdir -p "$universal_dir"
for t in aarch64-apple-darwin x86_64-apple-darwin; do
    step "Building loadstone-bridge ($t)"
    (cd "$repo" && cargo build -q -p loadstone-bridge --release --target "$t")
done
lipo -create \
    "$repo/target/aarch64-apple-darwin/release/libloadstone_bridge.a" \
    "$repo/target/x86_64-apple-darwin/release/libloadstone_bridge.a" \
    -output "$universal_dir/libloadstone_bridge.a"

# --- The app ----------------------------------------------------------------
step "Building $name.app"
build="$repo/build-dist"
rm -rf "$build"
cmake -S "$repo/app" -B "$build" -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
    -DwxWidgets_CONFIG_EXECUTABLE="$wx_prefix/bin/wx-config" \
    -DLOADSTONE_BRIDGE_LIB="$universal_dir/libloadstone_bridge.a" \
    -DLOADSTONE_EMBED_PROFILE="$profile" \
    -DLOADSTONE_APP_NAME="$name" \
    -DLOADSTONE_BUNDLE_ID="$bundle_id" \
    >/dev/null
cmake --build "$build" -j"$jobs" >/dev/null

app="$out/$name.app"
rm -rf "$app"
cp -R "$build/$name.app" "$app"
codesign --force --deep --sign - "$app"

# --- Check it is self-contained ---------------------------------------------
exe="$app/Contents/MacOS/$name"
if otool -L "$exe" | grep -q -e /opt/homebrew -e /usr/local; then
    echo "ERROR: $exe still links something outside the system:" >&2
    otool -L "$exe" >&2
    exit 1
fi
lipo -info "$exe"
echo "Built $app"
