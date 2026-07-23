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

    # Try to find mv anywhere

    $mvFound = Get-Command mv.exe -ErrorAction SilentlyContinue -CommandType Application

    if ($mvFound) { return }



    # Not found — try Git's usr/bin at common locations

    $gitPaths = @(

        'C:\Program Files\Git\usr\bin',

        'C:\Program Files (x86)\Git\usr\bin',

        "$env:LOCALAPPDATA\Programs\Git\usr\bin",

        "$env:USERPROFILE\scoop\apps\git\current\usr\bin"

    )



    foreach ($gp in $gitPaths) {

        if (Test-Path "$gp\mv.exe") {

            $env:Path = "$gp;$env:Path"

            Write-Ok "Unix tools found at: $gp"

            return

        }

    }



    # Nothing found — install busybox via Scoop (most reliable)

    Write-Warn "Unix tools (mv/rm) not found — installing busybox via Scoop..."



    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {

        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression

    }



    # busybox in main bucket provides all Unix commands

    scoop install busybox *>&1 | Out-Null



    # Activate busybox shims

    $busyboxShim = "$env:USERPROFILE\scoop\shims"

    if (Test-Path "$busyboxShim\mv.exe") {

        $env:Path = "$busyboxShim;$env:Path"

        Write-Ok "busybox installed — mv/rm now available"

        return

    }



    Write-Error "Unix tools still not found after trying Git paths and busybox."

    Write-Error "Install Git for Windows (with 'Unix tools' option) or run: scoop install busybox"

    Write-Error "Then re-run this script."

    exit 1

}



# ── Read pinned android-sdk version from .mise.toml ──────────────────────────

# mise's global install cache ($MiseData) is shared across every project on

# the machine, so a dev who's touched another Flutter/Android project can end

# up with multiple android-sdk versions cached. Always read the version this

# project actually pins rather than guessing from whatever is on disk (a plain

# string sort of directory names, e.g., puts "9.0" ahead of "20.0").

function Get-AndroidSdkVersion {

    $version = (Get-Content '.mise.toml' | Select-String 'android-sdk' | ForEach-Object { $_ -replace '.*"([^"]+)".*', '$1' })[0]

    if (-not $version) {

        Write-Error "Could not find android-sdk version in .mise.toml"

        exit 1

    }

    return $version

}



# ── Resolve ANDROID_HOME from mise install ───────────────────────────────────

function Resolve-AndroidHome {

    param([string]$Version)

    # vfox's android-sdk plugin expands a major-only pin like "20" to a

    # concrete "20.0" install dir. Check both forms.

    foreach ($candidate in @($Version, "$Version.0")) {

        $dir = Join-Path "$MiseData\installs\android-sdk" $candidate

        if (Test-Path $dir -PathType Container) {

            return $dir

        }

    }

    Write-Error "Android SDK version $Version (from .mise.toml) not found under $MiseData\installs\android-sdk\"

    Write-Error "This means mise install failed for android-sdk. Check the errors above."

    exit 1

}



# ── Shim adb/fastboot/emulator into %USERPROFILE%\.local\bin ────────────────

# If the user has `mise activate pwsh` in their profile (mise's standard

# recommended setup, same as this project's own .zshrc), mise rebuilds PATH

# from scratch on every prompt and prunes anything under its own install dir

# that it doesn't itself manage — platform-tools/emulator, installed

# separately via sdkmanager, aren't recognized "tool" bin dirs. Adding those

# paths directly to the profile gets silently stripped moments later.

# Windows symlinks need Developer Mode/admin, so use thin .cmd wrapper shims

# in a directory outside mise's install tree instead — immune to the pruning.

function New-SdkShims {

    param([string]$AndroidHome)



    $shimDir = "$env:USERPROFILE\.local\bin"

    if (-not (Test-Path $shimDir)) {

        New-Item -ItemType Directory -Path $shimDir -Force | Out-Null

    }



    $targets = @(

        "$AndroidHome\platform-tools\adb.exe"

        "$AndroidHome\platform-tools\fastboot.exe"

        "$AndroidHome\emulator\emulator.exe"

    )



    foreach ($target in $targets) {

        if (Test-Path $target -PathType Leaf) {

            $name = [System.IO.Path]::GetFileNameWithoutExtension($target)

            $shimPath = "$shimDir\$name.cmd"

            Set-Content -Path $shimPath -Value "@echo off`r`n`"$target`" %*" -Encoding ASCII

            Write-Ok "Shimmed $shimPath -> $target"

        }

    }

}



# ── Ensure %USERPROFILE%\.local\bin is on PATH ───────────────────────────────

# This one entry is safe to persist in the profile: it lives outside mise's

# install tree, so mise's activate hook never prunes it.

function Ensure-LocalBinOnPath {

    $shimDir = "$env:USERPROFILE\.local\bin"

    $line = "`$env:Path = `"$shimDir;`$env:Path`""



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



    if ($existing -match [Regex]::Escape($line)) {

        Write-Ok "Already in profile: $line"

    } else {

        Add-Content -Path $profilePath -Value "`n$header`n$line"

        Write-Info "Added to $profilePath`: $line"

    }

}



# ── Check architecture compatibility ────────────────────────────────────────

$script:IsArm64 = $false

function Assert-ArchCompatible {

    $arch = (Get-CimInstance Win32_Processor | Select-Object -First 1).Architecture

    # 9 = ARM64, 0 = x86, 9 = ARM64, 12 = x64 (AMD64)

    if ($arch -ne 9) { return }  # Not ARM64, no issue

    $script:IsArm64 = $true

    Write-Warn "Windows ARM64 detected — Flutter 3.44.0 has no windows-arm64 build. Skipping Flutter (install it manually)."

}

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


    # Windows fix: mise's internal mkdir -p uses CMD (not PowerShell),
    # and CMD's mkdir doesn't understand -p. Pre-create the expected
    # android-sdk directory structure so mkdir -p becomes a no-op.
    if ($IsWindows -or $env:OS -match 'Windows') {
        # vfox expands a major-only pin like "20" to a concrete "20.0"
        # install dir — that's the physical path mise actually creates.
        $expandedVersion = "$(Get-AndroidSdkVersion).0"
        $expectedDir = "$MiseData\installs\android-sdk\$expandedVersion\cmdline-tools\$expandedVersion\bin"
        New-Item -ItemType Directory -Path $expectedDir -Force | Out-Null
        Write-Info "Pre-created android-sdk directory: $expectedDir"
    }

    if ($script:IsArm64) {
        $env:MISE_DISABLE_TOOLS = "flutter"
    }

    Write-Info "Installing project toolchain via mise..."
    Write-Info "(this downloads Flutter, Android SDK, Java, Gradle, pnpm — may take a while)..."

    mise install 2>&1 | ForEach-Object { Write-Host "  $_" }



    # Verify key tools were installed

    $androidSdkDir = Get-ChildItem "$MiseData\installs\android-sdk" -Directory -ErrorAction SilentlyContinue



    if (-not $androidSdkDir) {

        Write-Error "android-sdk failed to install. Check the mise output above for errors."

        Write-Error "Common cause: missing Unix tools (mv/rm) on Windows."

        exit 1

    }

    if (-not $script:IsArm64) {

        $flutterDir = Get-ChildItem "$MiseData\installs\flutter" -Directory -ErrorAction SilentlyContinue

        if (-not $flutterDir) {

            Write-Error "flutter failed to install. Check the mise output above."

            exit 1

        }

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

    Assert-ArchCompatible

    Install-ScoopIfMissing

    Install-Mise



    $projectRoot = Find-ProjectRoot

    Write-Info "Project root: $projectRoot"



    Install-MiseTools -ProjectRoot $projectRoot



    $androidSdkVersion = Get-AndroidSdkVersion

    $env:ANDROID_HOME = Resolve-AndroidHome -Version $androidSdkVersion

    Write-Ok "ANDROID_HOME=$env:ANDROID_HOME"



    Install-SdkExtras

    Create-Avd



    New-SdkShims -AndroidHome $env:ANDROID_HOME

    Ensure-LocalBinOnPath

    Verify-Setup



    Write-Host ""

    Write-Ok "All done."

    Write-Host "Restart your terminal or run: . `$PROFILE"

    Write-Host "Then:  emulator -avd $AvdName"

    Write-Host "       adb devices"

    if ($script:IsArm64) {

        Write-Warn "Flutter was skipped (no windows-arm64 build) — install it manually."

    }

    Write-Host ""

}



Main

