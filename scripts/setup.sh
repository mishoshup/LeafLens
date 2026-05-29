#!/usr/bin/env bash
# =============================================================================
# LeafLens — Project Setup Script (Linux / macOS / Windows Git Bash)
# =============================================================================
# Installs mise, project toolchain, Android SDK extras, creates an emulator,
# and adds adb/emulator to PATH in the appropriate shell RC file.
# Idempotent — safe to run multiple times.
# =============================================================================

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────────
AVD_NAME="pixel_8"
AVD_TARGET="system-images;android-36;google_apis;arm64-v8a"
SDK_PACKAGES=(
  "platform-tools"
  "emulator"
  "${AVD_TARGET}"
  "build-tools;36.1.0"
)

# ── Colors ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
log_info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Platform detection ──────────────────────────────────────────────────────
OS="$(uname -s)"
IS_WINDOWS=false
IS_ARM64=false
case "$OS" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=true ;;
esac
if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
  IS_ARM64=true
fi

if [[ "$OS" != "Linux" && "$OS" != "Darwin" && "$IS_WINDOWS" != "true" ]]; then
  log_error "Unsupported OS: $OS."
  exit 1
fi

# ── Mise data directory ────────────────────────────────────────────────────
if [[ "$IS_WINDOWS" == "true" ]]; then
  DEFAULT_MISE_DATA="${LOCALAPPDATA}/mise"
  DEFAULT_MISE_DATA="${DEFAULT_MISE_DATA//\\/\/}"
else
  DEFAULT_MISE_DATA="$HOME/.local/share/mise"
fi
MISE_DATA="${MISE_DATA:-$DEFAULT_MISE_DATA}"

# ── Resolve ANDROID_HOME from mise install ──────────────────────────────────
resolve_android_home() {
  local sdk_dir
  sdk_dir="$(find "$MISE_DATA/installs/android-sdk" -maxdepth 1 -type d -name "*" 2>/dev/null \
    | grep -v "^$MISE_DATA/installs/android-sdk$" | head -1 || true)"
  if [[ -z "$sdk_dir" ]]; then
    log_error "Android SDK not found under $MISE_DATA/installs/android-sdk/"
    log_error "Run 'mise install' first."
    return 1
  fi
  echo "$sdk_dir"
}

# ── Detect shell RC file ────────────────────────────────────────────────────
detect_rc() {
  if [[ "$IS_WINDOWS" == "true" ]]; then
    echo "$HOME/.bashrc"
    return
  fi
  case "${SHELL##*/}" in
    zsh)  echo "$HOME/.zshrc" ;;
    bash)
      if [[ "$OS" == "Darwin" ]]; then echo "$HOME/.bash_profile"
      else echo "$HOME/.bashrc"; fi ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
    *)    echo "$HOME/.profile" ;;
  esac
}

# ── Add PATH entries to RC file if missing ───────────────────────────────────
ensure_path_entries() {
  local rc_file="$1" android_home="$2"
  local entries=(
    "export PATH=\"${android_home}/platform-tools:\$PATH\""
    "export PATH=\"${android_home}/emulator:\$PATH\""
  )
  touch "$rc_file"
  for entry in "${entries[@]}"; do
    if ! grep -Fxq "$entry" "$rc_file" 2>/dev/null; then
      echo "" >> "$rc_file"
      echo "# Added by LeafLens setup script" >> "$rc_file"
      echo "$entry" >> "$rc_file"
      log_info "Added to ${rc_file}: ${entry}"
    else
      log_ok "Already in ${rc_file}: ${entry}"
    fi
  done
}

# ── Install mise if missing ─────────────────────────────────────────────────
install_mise() {
  if command -v mise &>/dev/null; then
    log_ok "mise ready ($(mise --version))"
    return
  fi

  log_info "mise not found — installing..."

  if [[ "$IS_WINDOWS" == "true" ]] && command -v scoop &>/dev/null; then
    scoop install mise
  elif [[ "$OS" == "Darwin" ]] && command -v brew &>/dev/null; then
    brew install mise
  else
    curl -fsSL https://mise.run | sh
  fi

  for dir in "$MISE_DATA/bin" "$HOME/.local/bin"; do
    if [[ -x "$dir/mise" ]]; then export PATH="$dir:$PATH"; break; fi
  done

  if ! command -v mise &>/dev/null; then
    log_error "mise installation failed."
    exit 1
  fi

  eval "$(mise activate bash 2>/dev/null)" || true
  if [[ -d "$MISE_DATA/shims" ]]; then
    export PATH="$MISE_DATA/shims:$PATH"
  fi

  log_ok "mise installed ($(mise --version))"
}

# ── Find project root ───────────────────────────────────────────────────────
find_project_root() {
  local dir="$1"
  while [[ "$dir" != "" && "$dir" != "/" ]]; do
    if [[ -f "$dir/.mise.toml" ]]; then echo "$dir"; return 0; fi
    dir="$(dirname "$dir")"
  done
  log_error "No .mise.toml found from $(pwd) upward."
  exit 1
}

# ── mise trust + install ────────────────────────────────────────────────────
install_mise_tools() {
  cd "$1"
  mise trust 2>/dev/null || true
  log_info "Installing project toolchain via mise..."
  mise install || true  # android-sdk may fail on windows-arm64
}

# ── Manual android-sdk install for Windows ARM64 ────────────────────────────
# Mise's vfox android-sdk plugin post-install hook uses mkdir -p via CMD,
# which doesn't understand the -p flag on Windows. The installation fails
# and mise deletes everything. We install it manually instead.
install_android_sdk_manually() {
  local sdk_version="20.0"
  local sdk_dir="$MISE_DATA/installs/android-sdk/$sdk_version"

  # Check if already installed correctly
  if [[ -x "$sdk_dir/cmdline-tools/$sdk_version/bin/sdkmanager" ]]; then
    return 0
  fi

  if [[ "$IS_WINDOWS" != "true" || "$IS_ARM64" != "true" ]]; then
    # Not on windows-arm64 — check if mise installed it, if not, error
    if ! [[ -x "$sdk_dir/cmdline-tools/$sdk_version/bin/sdkmanager" ]]; then
      log_error "android-sdk failed to install. Run 'mise install' and check errors."
      exit 1
    fi
    return 0
  fi

  log_info "Windows ARM64 detected — installing Android SDK manually (mise vfox bug workaround)..."
  log_info "Downloading commandlinetools..."

  local zip_url="https://dl.google.com/android/repository/commandlinetools-win-14742923_latest.zip"
  local zip_file
  zip_file="$(mktemp).zip"

  # Download
  if command -v curl &>/dev/null; then
    curl -fsSL -o "$zip_file" "$zip_url"
  elif command -v wget &>/dev/null; then
    wget -q -O "$zip_file" "$zip_url"
  else
    log_error "Neither curl nor wget found. Cannot download Android SDK."
    exit 1
  fi

  log_info "Extracting to $sdk_dir..."

  # Extract to a temp location
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if command -v unzip &>/dev/null; then
    unzip -q "$zip_file" -d "$tmp_dir"
  elif command -v busybox &>/dev/null && busybox unzip 2>&1 | head -1; then
    busybox unzip -q "$zip_file" -d "$tmp_dir"
  else
    log_error "No unzip command found. Install unzip via: scoop install unzip"
    exit 1
  fi

  # mise's expected structure: cmdline-tools/<version>/bin/, cmdline-tools/<version>/lib/
  mkdir -p "$sdk_dir/cmdline-tools/$sdk_version"
  mv "$tmp_dir/cmdline-tools/"* "$sdk_dir/cmdline-tools/$sdk_version/"

  # Cleanup
  rm -rf "$tmp_dir" "$zip_file"

  # Verify
  if [[ -x "$sdk_dir/cmdline-tools/$sdk_version/bin/sdkmanager" ]]; then
    log_ok "Android SDK manually installed at: $sdk_dir"
  else
    log_error "Manual android-sdk installation failed."
    ls -la "$sdk_dir/cmdline-tools/$sdk_version/bin/" 2>/dev/null || true
    exit 1
  fi
}

# ── Android SDK extras via sdkmanager ──────────────────────────────────────
install_sdk_extras() {
  if ! command -v sdkmanager &>/dev/null; then
    log_error "sdkmanager not in PATH."
    log_error "Expected at: $(resolve_android_home 2>/dev/null || echo '?')/cmdline-tools/20.0/bin/sdkmanager"
    exit 1
  fi

  yes | sdkmanager --licenses 2>/dev/null || true

  for pkg in "${SDK_PACKAGES[@]}"; do
    if sdkmanager --list 2>/dev/null | grep -qE "^[[:space:]]*${pkg}[[:space:]]+.*Installed"; then
      log_ok "SDK package already installed: ${pkg}"
      continue
    fi
    log_info "Installing SDK package: ${pkg}..."
    sdkmanager "$pkg"
    log_ok "Installed: ${pkg}"
  done
}

# ── Create AVD ──────────────────────────────────────────────────────────────
create_avd() {
  if ! command -v avdmanager &>/dev/null; then
    log_error "avdmanager not found in PATH"
    exit 1
  fi
  if avdmanager list avd -c 2>/dev/null | grep -q "^${AVD_NAME}$"; then
    log_ok "AVD '${AVD_NAME}' already exists"
    return
  fi
  echo "no" | avdmanager create avd -n "$AVD_NAME" -k "$AVD_TARGET" -d "pixel_8" -f
  log_ok "AVD '${AVD_NAME}' created"
}

# ── Run ─────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║        LeafLens — Environment Setup              ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
  echo ""

  if [[ "$IS_WINDOWS" == "true" ]]; then
    log_info "Detected Windows (Git Bash)"
  fi

  install_mise

  PROJECT_ROOT="$(find_project_root "$(pwd)")"
  log_info "Project root: ${PROJECT_ROOT}"

  install_mise_tools "$PROJECT_ROOT"

  # Manual android-sdk install for windows-arm64 (mise vfox bug)
  install_android_sdk_manually

  ANDROID_HOME="$(resolve_android_home)"
  export ANDROID_HOME
  log_ok "ANDROID_HOME=${ANDROID_HOME}"

  # Add cmdline-tools to PATH so sdkmanager/avdmanager resolve
  export PATH="$ANDROID_HOME/cmdline-tools/20.0/bin:$PATH"

  install_sdk_extras
  create_avd

  RC_FILE="$(detect_rc)"
  log_info "Detected shell RC: ${RC_FILE}"
  ensure_path_entries "$RC_FILE" "$ANDROID_HOME"

  echo ""
  log_ok "All done."
  log_info "Restart your terminal or run: source ${RC_FILE}"
  log_info "Then:  emulator -avd ${AVD_NAME}"
  log_info "       adb devices"
  echo ""
}

main "$@"
