<#
.SYNOPSIS
    LeafLens — Project Setup Script (Windows)
.DESCRIPTION
    Installs Scoop, mise, project toolchain, Android SDK extras, creates an
    emulator, and adds adb/emulator to PATH in the PowerShell profile.
    Idempotent — safe to run multiple times.
.NOTES
    Requires PowerShell 5.1+ (pwsh preferred). Run in a non-admin terminal.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ── Config ──────────────────────────────────────────────────────────────────
$AvdName = 'pixel_8'
$AvdTarget = 'system-images;android-36;google_apis;arm64-v8a'
$SdkPackages = @(
    'platform-tools'
    'emulator'
    $AvdTarget
    'build-tools;36.1.0'
)
$MiseData = if ($env:MISE_DATA) { $env:MISE_DATA } else { "$env:LOCALAPPDATA\mise" }

function Write-Info  { Write-Host "[INFO]  $args" -ForegroundColor Cyan }
function Write-Ok    { Write-Host "[OK]    $args" -ForegroundColor Green }
function Write-Warn  { Write-Host "[WARN]  $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }

# ── Admin guard ─────────────────────────────────────────────────────────────
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($IsAdmin) {
    Write-Warn "Running as Administrator — Scoop works better without elevation."
    Write-Warn "Run as a standard user, then re-run."
    exit 1
}

# ── Check Unix tools (mv/rm) needed by mise ─────────────────────────────────
function Assert-UnixTools {
    # Try common Git-for-Windows paths
    $gitUsrBin = 'C:\Program Files\Git\usr\bin'
    $gitUsrBinX86 = 'C:\Program Files (x86)\Git\usr\bin'

    if (Get-Command mv -ErrorAction SilentlyContinue) {
        return
    }

    Write-Info "Unix tools (mv/rm) not found — checking Git paths..."

    if (Test-Path "$gitUsrBin\mv.exe") {
        $env:Path = "$gitUsrBin;$env:Path"
        Write-Ok "Added Git's usr/bin to PATH: $gitUsrBin"
        return
    }
    if (Test-Path "$gitUsrBinX86\mv.exe") {
        $env:Path = "$gitUsrBinX86;$env:Path"
        Write-Ok "Added Git's usr/bin to PATH: $gitUsrBinX86"
        return
    }

    # Git not found — offer to install Unix tools via Scoop
    Write-Warn "Git for Windows not found or missing Unix tools (mv, rm)."
    Write-Warn "mise requires mv/rm on Windows for extraction."
    Write-Warn ""
    Write-Warn "Fix options:"
    Write-Warn "  1. Install Git for Windows with 'Use Git and optional Unix tools from the Command Prompt'"
    Write-Warn "  2. Or run: scoop install busybox"
    Write-Warn "  3. Manually add C:\Program Files\Git\usr\bin to your PATH"
    Write-Warn ""
    Write-Warn "Attempting to install busybox via Scoop as fallback..."

    # Ensure Scoop is available
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Info "Scoop not found — installing first..."
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    }

    scoop install busybox *>&1 | Out-Null

    if (Get-Command mv -ErrorAction SilentlyContinue) {
        Write-Ok "busybox installed — mv/rm now available"
        return
    }

    Write-Error "Could not install Unix tools. Install Git for Windows or busybox manually, then re-run."
    exit 1
}

# ── Resolve ANDROID_HOME from mise install (version-agnostic) ───────────────
function Resolve-AndroidHome {
    $sdkDir = Get-ChildItem "$MiseData\installs\android-sdk" -Directory -ErrorAction SilentlyContinue `
        | Sort-Object Name -Descending `
        | Select-Object -First 1

    if (-not $sdkDir) {
        Write-Error "Android SDK not found under $MiseData\installs\android-sdk\"
        Write-Error "This means mise install failed for android-sdk. Check the errors above."
        exit 1
    }
    return $sdkDir.FullName
}

# ── Add PATH entries to PowerShell profile if missing ───────────────────────
function Ensure-PathEntries {
    param([string]$AndroidHome)

    $lines = @(
        "`$env:Path = `"${AndroidHome}\platform-tools;`$env:Path`""
        "`$env:Path = `"${AndroidHome}\emulator;`$env:Path`""
    )

    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path $profilePath -Parent

    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    if (-not (Test-Path $profilePath -PathType Leaf)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $existing = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    $header = "# Added by LeafLens setup script"

    foreach ($line in $lines) {
        if ($existing -match [Regex]::Escape($line)) {
            Write-Ok "Already in profile: $line"
        } else {
            Add-Content -Path $profilePath -Value "`n$header`n$line"
            Write-Info "Added to $profilePath`: $line"
        }
    }
}

# ── Scoop ──────────────────────────────────────────────────────────────────
function Install-ScoopIfMissing {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Ok "Scoop already installed"
        return
    }
    Write-Info "Scoop not found — installing..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Error "Scoop installation failed."
        exit 1
    }
    Write-Ok "Scoop installed"
}

# ── mise ────────────────────────────────────────────────────────────────────
function Install-Mise {
    if (Get-Command mise -ErrorAction SilentlyContinue) {
        Write-Ok "mise already installed ($(mise --version))"
        return
    }
    Write-Info "Installing mise via Scoop..."
    scoop install mise *>&1 | ForEach-Object { Write-Host "  $_" }
    if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
        Write-Error "mise installation failed."
        exit 1
    }
    Write-Ok "mise installed ($(mise --version))"
}

# ── Find project root ───────────────────────────────────────────────────────
function Find-ProjectRoot {
    $dir = Get-Location
    while ($dir) {
        if (Test-Path (Join-Path $dir '.mise.toml') -PathType Leaf) {
            return $dir
        }
        $dir = $dir.Parent
    }
    Write-Error "No .mise.toml found from $((Get-Location).Path) upward."
    exit 1
}

# ── mise trust + install with progress ──────────────────────────────────────
function Install-MiseTools {
    param([string]$ProjectRoot)
    Set-Location $ProjectRoot

    Write-Info "Trusting mise config..."
    mise trust *>$null

    Write-Info "Installing project toolchain via mise..."
    Write-Info "(this downloads Flutter, Android SDK, Java, Gradle, pnpm — may take a while)..."
    mise install 2>&1 | ForEach-Object { Write-Host "  $_" }

    # Verify key tools were installed
    $androidSdkDir = Get-ChildItem "$MiseData\installs\android-sdk" -Directory -ErrorAction SilentlyContinue
    $flutterDir = Get-ChildItem "$MiseData\installs\flutter" -Directory -ErrorAction SilentlyContinue

    if (-not $androidSdkDir) {
        Write-Error "android-sdk failed to install. Check the mise output above for errors."
        Write-Error "Common cause: missing Unix tools (mv/rm) on Windows."
        exit 1
    }
    if (-not $flutterDir) {
        Write-Error "flutter failed to install. Check the mise output above."
        exit 1
    }

    Write-Ok "mise tools installed"
}

# ── SDK extras ──────────────────────────────────────────────────────────────
function Install-SdkExtras {
    if (-not (Get-Command sdkmanager -ErrorAction SilentlyContinue)) {
        Write-Error "sdkmanager not in PATH after mise install."
        exit 1
    }

    Write-Info "Accepting SDK licenses..."
    'y' * 10 | sdkmanager --licenses *>$null

    foreach ($pkg in $SdkPackages) {
        $installed = sdkmanager --list 2>&1
        if ($installed -match "^\s*$pkg\s+.*Installed") {
            Write-Ok "SDK package already installed: $pkg"
            continue
        }
        Write-Info "Installing SDK package: $pkg..."
        sdkmanager $pkg 2>&1 | ForEach-Object { Write-Host "  $_" }
        Write-Ok "Installed: $pkg"
    }
}

# ── AVD ────────────────────────────────────────────────────────────────────
function Create-Avd {
    if (-not (Get-Command avdmanager -ErrorAction SilentlyContinue)) {
        Write-Error "avdmanager not in PATH"
        exit 1
    }
    $avdList = avdmanager list avd -c 2>&1
    if ($avdList -match "^${AvdName}$") {
        Write-Ok "AVD '${AvdName}' already exists"
        return
    }
    Write-Info "Creating AVD '${AvdName}' (requires system-images;android-36)..."
    'no' | avdmanager create avd -n $AvdName -k $AvdTarget -d pixel_8 -f 2>&1 | ForEach-Object { Write-Host "  $_" }
    Write-Ok "AVD '${AvdName}' created"
}

# ── Verify final state ──────────────────────────────────────────────────────
function Verify-Setup {
    $ok = $true

    if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
        Write-Warn "adb not in PATH. Run the script again or restart your terminal."
        $ok = $false
    }

    $avdCheck = avdmanager list avd -c 2>&1
    if ($avdCheck -notmatch "^${AvdName}$") {
        Write-Warn "AVD '${AvdName}' not found. It may not have been created."
        $ok = $false
    }

    if ($ok) {
        Write-Ok "All checks passed."
    }
}

# ── Run ─────────────────────────────────────────────────────────────────────
function Main {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║        LeafLens — Environment Setup              ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Assert-UnixTools
    Install-ScoopIfMissing
    Install-Mise

    $projectRoot = Find-ProjectRoot
    Write-Info "Project root: $projectRoot"

    Install-MiseTools -ProjectRoot $projectRoot

    $env:ANDROID_HOME = Resolve-AndroidHome
    Write-Ok "ANDROID_HOME=$env:ANDROID_HOME"

    Install-SdkExtras
    Create-Avd

    Ensure-PathEntries -AndroidHome $env:ANDROID_HOME
    Verify-Setup

    Write-Host ""
    Write-Ok "All done."
    Write-Host "Restart your terminal or run: . `$PROFILE"
    Write-Host "Then:  emulator -avd $AvdName"
    Write-Host "       adb devices"
    Write-Host ""
}

Main
