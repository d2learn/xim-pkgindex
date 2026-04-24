# Per-package Windows install / uninstall test, invoked from the
# windows-test CI job. Takes a space-separated list of changed .lua
# paths and exercises each one end-to-end:
#
#   1. parse meta (name, has_windows, is_ref) via parse-xpkg-meta.py
#   2. skip if the package is a thin ref or has no windows branch
#   3. register: `xlings config --add-xpkg <file>`
#   4. snapshot shim + xpkgs state, install, verify new artifacts
#   5. uninstall, verify artifacts are gone

param(
    [Parameter(Mandatory=$true)]
    [string]$ChangedFiles,

    [Parameter(Mandatory=$true)]
    [string]$WorkspaceRoot
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

function Log-Step  { Write-Host "`n==> $args" -ForegroundColor Cyan }
function Log-Info  { Write-Host "  $args" -ForegroundColor Gray }
function Log-Pass  { Write-Host "  [PASS] $args" -ForegroundColor Green }
function Log-Fail  { Write-Host "  [FAIL] $args" -ForegroundColor Red }

$xlingsHome = $env:XLINGS_HOME
if (-not $xlingsHome) { throw "XLINGS_HOME not set" }
$shimDir  = Join-Path $xlingsHome "subos\default\bin"
$xpkgsDir = Join-Path $xlingsHome "data\xpkgs"

function Get-ShimSet {
    if (-not (Test-Path $shimDir)) { return @{} }
    $set = @{}
    foreach ($entry in Get-ChildItem $shimDir -File -ErrorAction SilentlyContinue) {
        $set[$entry.Name] = $true
    }
    return $set
}

function Get-PkgInstallDirs([string]$pkgName) {
    if (-not (Test-Path $xpkgsDir)) { return @() }
    # xlings stores installs under <xpkgs>/<ns>-x-<name>/<version>/
    return Get-ChildItem $xpkgsDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "^[a-z]+-x-$([regex]::Escape($pkgName))$" }
}

$files = $ChangedFiles -split '\s+' | Where-Object { $_ -and $_.Trim() -ne "" }
if (-not $files -or $files.Count -eq 0) {
    Write-Host "No changed .lua files. Nothing to test." -ForegroundColor Yellow
    exit 0
}

$failures = @()
$tested   = 0
$skipped  = 0

foreach ($relFile in $files) {
    $luaFile = Join-Path $WorkspaceRoot $relFile
    if (-not (Test-Path $luaFile)) {
        Log-Info "skip (path does not exist): $relFile"
        continue
    }
    if ($luaFile -notlike "*.lua") {
        Log-Info "skip (not a .lua file): $relFile"
        continue
    }

    Log-Step "Parsing meta: $relFile"
    $metaJson = python "$WorkspaceRoot\.github\scripts\parse-xpkg-meta.py" $luaFile
    if ($LASTEXITCODE -ne 0) {
        Log-Fail "parser failed"
        $failures += $relFile
        continue
    }
    $meta = $metaJson | ConvertFrom-Json
    Log-Info "name=$($meta.name)  programs=[$($meta.programs -join ',')]  is_ref=$($meta.is_ref)  has_windows=$($meta.has_windows)"

    if ($meta.is_ref) {
        Log-Info "skip (ref package)"
        $skipped++
        continue
    }
    if (-not $meta.has_windows) {
        Log-Info "skip (no windows branch)"
        $skipped++
        continue
    }
    if (-not $meta.name) {
        Log-Fail "package name not parseable"
        $failures += $relFile
        continue
    }

    $tested++
    $pkg = $meta.name

    # --- register ---
    Log-Step "[$pkg] register"
    & xlings config --add-xpkg $luaFile 2>&1 | Write-Host
    if ($LASTEXITCODE -ne 0) {
        Log-Fail "config --add-xpkg failed"
        $failures += "$relFile (register)"
        continue
    }

    # --- snapshot pre-install state ---
    $shimsBefore = Get-ShimSet
    Log-Info "shims before install: $($shimsBefore.Count)"

    # --- install ---
    Log-Step "[$pkg] install"
    & xlings install "local:$pkg" -y 2>&1 | Write-Host
    if ($LASTEXITCODE -ne 0) {
        Log-Fail "install failed"
        $failures += "$relFile (install)"
        continue
    }

    # --- post-install checks ---
    Log-Step "[$pkg] post-install checks"
    $installDirs = @(Get-PkgInstallDirs -pkgName $pkg)
    if ($installDirs.Count -eq 0) {
        Log-Fail "no install dir matching '*-x-$pkg' found under $xpkgsDir"
        $failures += "$relFile (install-dir-missing)"
        # still attempt uninstall below
    } else {
        foreach ($d in $installDirs) {
            $versions = @(Get-ChildItem $d.FullName -Directory -ErrorAction SilentlyContinue)
            if ($versions.Count -eq 0) {
                Log-Fail "install dir has no version subdir: $($d.FullName)"
                $failures += "$relFile (install-dir-empty)"
            } else {
                foreach ($v in $versions) { Log-Pass "install dir: $($v.FullName)" }
            }
        }
    }

    $shimsAfter = Get-ShimSet
    $newShims = $shimsAfter.Keys | Where-Object { -not $shimsBefore.ContainsKey($_) }
    if (-not $newShims -or $newShims.Count -eq 0) {
        if ($meta.programs -and $meta.programs.Count -gt 0) {
            Log-Fail "no new shim appeared in $shimDir (expected one per program: $($meta.programs -join ','))"
            $failures += "$relFile (no-shim)"
        } else {
            Log-Info "no new shim appeared (package has no 'programs' declared — not a program-type package)"
        }
    } else {
        foreach ($s in $newShims) { Log-Pass "new shim: $s" }

        if ($meta.programs -and $meta.programs.Count -gt 0) {
            foreach ($prog in $meta.programs) {
                $matched = $newShims | Where-Object { $_ -eq $prog -or $_ -eq "$prog.exe" -or $_ -eq "$prog.cmd" }
                if (-not $matched) {
                    Log-Fail "declared program '$prog' has no corresponding shim"
                    $failures += "$relFile (missing-shim:$prog)"
                }
            }
        }
    }

    # --- uninstall ---
    Log-Step "[$pkg] uninstall"
    & xlings remove "local:$pkg" -y 2>&1 | Write-Host
    if ($LASTEXITCODE -ne 0) {
        Log-Fail "uninstall failed"
        $failures += "$relFile (uninstall)"
        continue
    }

    # --- post-uninstall checks ---
    Log-Step "[$pkg] post-uninstall checks"
    $shimsFinal = Get-ShimSet
    $leftover = $newShims | Where-Object { $shimsFinal.ContainsKey($_) }
    if ($leftover -and $leftover.Count -gt 0) {
        Log-Fail "shims still present after uninstall: $($leftover -join ',')"
        $failures += "$relFile (leftover-shim)"
    } else {
        Log-Pass "all shims cleaned"
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host " Windows test summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  tested:   $tested"
Write-Host "  skipped:  $skipped"
Write-Host "  failures: $($failures.Count)"
if ($failures.Count -gt 0) {
    foreach ($f in $failures) { Write-Host "    - $f" -ForegroundColor Red }
    exit 1
}
exit 0
