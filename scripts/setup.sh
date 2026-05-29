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
case "$OS" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=true ;;
esac

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
    | grep -v "^$MISE_DATA/installs/android-sdk$" | head -1)"
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
      if [[ "$OS" == "Darwin" ]]; then
        echo "$HOME/.bash_profile"
      else
        echo "$HOME/.bashrc"
      fi
      ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
    *)    echo "$HOME/.profile" ;;
  esac
}

# ── Add PATH entries to RC file if missing ───────────────────────────────────
ensure_path_entries() {
  local rc_file="$1"
  local android_home="$2"
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
    if [[ -x "$dir/mise" ]]; then
      export PATH="$dir:$PATH"
      break
    fi
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
    if [[ -f "$dir/.mise.toml" ]]; then
      echo "$dir"
      return 0
    fi
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
  mise install || true  # Don't exit — some tools may need manual fixup
}

# ── Fix android-sdk cmdline-tools structure broken by mise on Windows ───────
# Windows ARM64: mise's vfox post-install hook fails to version-nest the
# cmdline-tools directory. It extracts to cmdline-tools/bin/sdkmanager but
# the hook expects cmdline-tools/20.0/bin/sdkmanager. Fix by moving files.
fix_android_sdk_structure() {
  local sdk_root="$MISE_DATA/installs/android-sdk"
  local sdk_dir
  sdk_dir="$(find "$sdk_root" -maxdepth 1 -type d -name "*" 2>/dev/null \
    | grep -v "^$sdk_root$" | head -1 || true)"

  if [[ -z "$sdk_dir" ]]; then
    return 0  # Not installed yet, nothing to fix
  fi

  # Check if sdkmanager is already at the expected path
  local cmdline_version_dir
  cmdline_version_dir="$(find "$sdk_dir/cmdline-tools" -maxdepth 1 -type d -name "*" 2>/dev/null \
    | grep -v "^$sdk_dir/cmdline-tools$" | head -1 || true)"

  if [[ -n "$cmdline_version_dir" && -f "$cmdline_version_dir/bin/sdkmanager" ]]; then
    return 0  # Already correct structure
  fi

  # Check if sdkmanager exists at the wrong path (no version subdir)
  if [[ -f "$sdk_dir/cmdline-tools/bin/sdkmanager" ]]; then
    log_warn "android-sdk cmdline-tools missing version subdirectory (Windows ARM64 vfox bug)"
    log_info "Fixing directory structure..."

    # Determine the version from the directory name (e.g., "20.0")
    local sdk_version
    sdk_version="$(basename "$sdk_dir")"

    mkdir -p "$sdk_dir/cmdline-tools/$sdk_version"
    # Move all contents of cmdline-tools into the version subdir
    # (excluding the version subdir itself)
    for item in "$sdk_dir/cmdline-tools/"*; do
      local name
      name="$(basename "$item")"
      if [[ "$name" != "$sdk_version" ]]; then
        mv "$item" "$sdk_dir/cmdline-tools/$sdk_version/"
      fi
    done

    if [[ -f "$sdk_dir/cmdline-tools/$sdk_version/bin/sdkmanager" ]]; then
      log_ok "android-sdk directory structure fixed"
      # Re-run mise trust to verify and mark as installed
      mise trust 2>/dev/null || true
    else
      log_error "Could not fix android-sdk structure. sdkmanager not found."
      ls -la "$sdk_dir/cmdline-tools/" 2>/dev/null || true
      exit 1
    fi
  fi
}

# ── Android SDK extras via sdkmanager ──────────────────────────────────────
install_sdk_extras() {
  if ! command -v sdkmanager &>/dev/null; then
    log_error "sdkmanager not in PATH after mise install."
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

  # Fix android-sdk structure if mise broke it (Windows ARM64)
  fix_android_sdk_structure

  ANDROID_HOME="$(resolve_android_home)"
  export ANDROID_HOME
  log_ok "ANDROID_HOME=${ANDROID_HOME}"

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
