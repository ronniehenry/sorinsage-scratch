#!/usr/bin/env bash
# 06-dev-tools.sh — PyCharm, Arduino IDE, VS Code, Zed + PlatformIO/git VS Code extensions
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "Development tools"

# ---- VS Code (Microsoft's official apt repo, since it's snap-free) --------
if ! command -v code &>/dev/null; then
  log_info "Adding Microsoft VS Code apt repo"
  sudo apt-get install -y wget gpg apt-transport-https
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

# ---- PyCharm Community (flatpak — cleanest non-snap path) -------------------
flatpak_install com.jetbrains.PyCharm-Community

# ---- Arduino IDE (flatpak — official Arduino flatpak, avoids snap/AppImage churn) --
flatpak_install cc.arduino.IDE2

log_section "VS Code extensions"

if command -v code &>/dev/null; then
  VSCODE_EXTENSIONS=(
    platformio.platformio-ide
    eamodio.gitlens
    github.vscode-pull-request-github
    mhutchie.git-graph
    donjayamanne.githistory
    ms-vscode.cpptools
    ms-python.python
  )
  for ext in "${VSCODE_EXTENSIONS[@]}"; do
    if code --list-extensions | grep -qix "$ext"; then
      log_skip "$ext"
    else
      log_info "Installing VS Code extension: $ext"
      code --install-extension "$ext" --force
    fi
  done
else
  log_warn "VS Code binary not found on PATH yet — re-run this module after a fresh shell, or install extensions manually."
fi

log_info "Dev tools step complete"
