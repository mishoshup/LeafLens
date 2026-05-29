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



# ── Check architecture compatibility ────────────────────────────────────────

function Assert-ArchCompatible {

    $arch = (Get-CimInstance Win32_Processor | Select-Object -First 1).Architecture

    # 9 = ARM64, 0 = x86, 9 = ARM64, 12 = x64 (AMD64)

    if ($arch -ne 9) { return }  # Not ARM64, no issue



    Write-Warn "Windows ARM64 detected — Flutter 3.44.0 in .mise.toml has no windows-arm64 build."

    Write-Warn "Flutter only provides windows-x64 builds. Two options:"

    Write-Warn ""

    Write-Warn "  Option 1: Use Flutter's x64 build via ARM64 emulation (recommended)"

    Write-Warn "    - Open .mise.toml and add under [tools]:"

    Write-Warn '      flutter = { version = "3.44.0", platform = "windows-x64" }'

    Write-Warn ""

    Write-Warn "  Option 2: Install Flutter manually outside mise"

    Write-Warn "    - Download from https://docs.flutter.dev/get-started/install/windows/mobile"

    Write-Warn "    - Skip 'mise install' for flutter in the script"

    Write-Warn ""

    $choice = Read-Host "Continue anyway? mise will fail on flutter but may succeed on others (y/N)"

    if ($choice -ne 'y') {

        exit 1

    }

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

    Assert-ArchCompatible

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

