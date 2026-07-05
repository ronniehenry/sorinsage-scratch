#!/usr/bin/env bash
# 06-dev-tools.sh — VS Code, Zed
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "Development tools"

# Ensure prerequisites are present before any download/install steps.
# curl is needed for the Zed installer; wget and gpg for the VS Code repo.
apt_install curl wget gpg apt-transport-https

# ---- VS Code (Microsoft's official apt repo, since it's snap-free) --------
if ! command -v code &>/dev/null; then
  log_info "Adding Microsoft VS Code apt repo"
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
  rm -f /tmp/packages.microsoft.gpg
  sudo apt-get update
  apt_install code
else
  log_skip "VS Code"
fi

# ---- Zed (official install script, .deb-equivalent, no snap) ---------------
if ! command -v zed &>/dev/null; then
  log_info "Installing Zed via official install script"
  curl -fsSL https://zed.dev/install.sh | sh
else
  log_skip "Zed"
fi

# NOTE: Arduino IDE is intentionally not installed here — download the
# AppImage directly from arduino.cc and manage it with Gearlever (installed
# in 07-apps.sh) instead.

# NOTE: VS Code extensions are intentionally not installed here — sign into
# GitHub Settings Sync in VS Code after this script runs, so the predefined
# extension set (PlatformIO, GitLens, etc.) will sync down on its own.

log_info "Dev tools step complete"
