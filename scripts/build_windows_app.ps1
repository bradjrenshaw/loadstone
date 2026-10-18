# build_windows_app.ps1 - build a distributable Loadstone .exe for Windows.
# The Windows counterpart of scripts/build_macos_app.sh.
#
# Makes the exe you hand to users:
#   - x64, one file
#   - wxWidgets linked statically (built once from source, then cached)
#   - the C runtime linked statically everywhere (wxWidgets, the app, and the
#     Rust bridge), so it runs without the Visual C++ Redistributable
#   - optionally a branded installer: a distribution profile baked in, its own
#     exe name
#
# Usage:
#   scripts\build_windows_app.ps1                                    the manager
#   scripts\build_windows_app.ps1 -ProfilePath <profile.json> -Name BlindfoldInstaller -Out <dir>
#
# The exe lands at <Out>\<Name>.exe (default: dist\Loadstone.exe).
# Needs: Visual Studio (C++ workload; CMake picks the newest it finds), CMake,
# and Rust (x86_64-pc-windows-msvc). No developer prompt needed. The
# wxWidgets build goes to %LOCALAPPDATA%\loadstone (override with
# LOADSTONE_WX_PREFIX).

param(
    [string]$ProfilePath = "",
    [string]$Name = "Loadstone",
    [string]$Out = ""
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
if (-not $Out) { $Out = Join-Path $repo 'dist' }
New-Item -ItemType Directory -Force -Path $Out | Out-Null
$Out = (Resolve-Path $Out).Path
if ($ProfilePath) { $ProfilePath = (Resolve-Path $ProfilePath).Path }

function Write-Step($msg) { Write-Host "== $msg" }
# cmake/cargo write progress to stderr; run them through cmd so PowerShell 5.1
# doesn't promote those lines to errors under ErrorActionPreference Stop.
function Invoke-Native($cmdline) {
    & cmd /c "$cmdline 2>&1"
    if ($LASTEXITCODE -ne 0) { throw "failed ($LASTEXITCODE): $cmdline" }
}

# --- wxWidgets, static, static CRT ----------------------------------------------
# 3.2.x, as on macOS. wxBUILD_USE_STATIC_RUNTIME builds it /MT to match the app.
$wxVersion = '3.2.8'
$wxPrefix = $env:LOADSTONE_WX_PREFIX
if (-not $wxPrefix) { $wxPrefix = Join-Path $env:LOCALAPPDATA "loadstone\wx-$wxVersion-static-mt" }
if (-not (Test-Path (Join-Path $wxPrefix 'include'))) {
    Write-Step "Building wxWidgets $wxVersion (static; one-time, several minutes)"
    $work = Join-Path ([IO.Path]::GetTempPath()) ("loadstone-wx-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $work | Out-Null
    $zip = Join-Path $work 'wx.zip'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -OutFile $zip `
        "https://github.com/wxWidgets/wxWidgets/releases/download/v$wxVersion/wxWidgets-$wxVersion.zip"
    $src = Join-Path $work 'src'
    Expand-Archive -Path $zip -DestinationPath $src
    # The source zip has no top-level folder; tolerate one anyway.
    if (-not (Test-Path (Join-Path $src 'CMakeLists.txt'))) {
        $src = (Get-ChildItem $src -Directory | Select-Object -First 1).FullName
    }
    $wxBuild = Join-Path $work 'build'
    Invoke-Native ("cmake -S `"$src`" -B `"$wxBuild`" -A x64 " +
        "-DwxBUILD_SHARED=OFF -DwxBUILD_USE_STATIC_RUNTIME=ON " +
        "-DwxBUILD_SAMPLES=OFF -DwxBUILD_TESTS=OFF -DwxBUILD_DEMOS=OFF " +
        "-DwxUSE_WEBVIEW=OFF -DwxUSE_MEDIACTRL=OFF " +
        "-DCMAKE_INSTALL_PREFIX=`"$wxPrefix`"")
    Invoke-Native "cmake --build `"$wxBuild`" --config Release --parallel"
    Invoke-Native "cmake --install `"$wxBuild`" --config Release"
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "   wxWidgets: $wxPrefix"

# --- The app ----------------------------------------------------------------------
# The CMake build runs cargo for the bridge; +crt-static makes Rust (and the
# cxx shim the cc crate compiles) /MT as well.
Write-Step "Building $Name.exe"
$env:RUSTFLAGS = '-C target-feature=+crt-static'
$build = Join-Path $repo 'build-dist'
if (Test-Path $build) { Remove-Item $build -Recurse -Force }
# Release only: wxWidgets is installed in Release, and generating the other
# configurations would point at its never-built Debug libraries.
Invoke-Native ("cmake -S `"$repo\app`" -B `"$build`" -A x64 " +
    "-DCMAKE_CONFIGURATION_TYPES=Release " +
    "-DCMAKE_PREFIX_PATH=`"$wxPrefix`" " +
    "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded " +
    "-DLOADSTONE_EMBED_PROFILE=`"$ProfilePath`" " +
    "-DLOADSTONE_APP_NAME=`"$Name`"")
Invoke-Native "cmake --build `"$build`" --config Release --parallel"

$built = Join-Path $build "Release\$Name.exe"
if (-not (Test-Path $built)) { throw "expected $built after the build" }
$exe = Join-Path $Out "$Name.exe"
Copy-Item $built $exe -Force

# --- Check it needs no redistributable --------------------------------------------
# Import names are plain ASCII in the PE file.
$text = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($exe))
foreach ($dll in @('VCRUNTIME140.dll', 'MSVCP140.dll', 'api-ms-win-crt-runtime')) {
    if ($text.IndexOf($dll, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "$exe still imports $dll - the C runtime is not fully static"
    }
}
Write-Host "Built $exe"
