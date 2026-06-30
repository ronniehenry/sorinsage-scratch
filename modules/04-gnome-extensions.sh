#!/usr/bin/env bash
# 04-gnome-extensions.sh — install gnome-extensions-cli + Tweaks/Extension Manager GUIs, enable the SorinSage extension set
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "GNOME extensions"

# Extension UUIDs (from extensions.gnome.org). gnome-extensions-cli (gext) can
# install by UUID without needing the browser connector.
declare -A EXTENSIONS=(
  ["blur-my-shell@aunetx"]="Blur my Shell"
  ["just-perfection-desktop@just-perfection"]="Just Perfection"
  ["rounded-window-corners@fxgn"]="Rounded Window Corners Reborn"
  ["appindicatorsupport@rgcjonas.gmail.com"]="AppIndicator and KStatusNotifierItem Support"
)

apt_install pipx gnome-shell-extension-manager gnome-tweaks

if ! command -v gext &>/dev/null; then
  log_info "Installing gnome-extensions-cli (gext) via pipx"
  pipx install gnome-extensions-cli --system-site-packages
  pipx ensurepath
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if command -v gext &>/dev/null; then
  for uuid in "${!EXTENSIONS[@]}"; do
    if gext_is_installed "$uuid"; then
      log_skip "${EXTENSIONS[$uuid]} ($uuid)"
    else
      log_info "Installing ${EXTENSIONS[$uuid]} ($uuid)"
      gext install "$uuid" || log_warn "gext failed for $uuid — install manually via Extension Manager"
    fi
  done
else
  log_warn "gext unavailable — open 'Extension Manager' (installed above) and add these manually:"
  for uuid in "${!EXTENSIONS[@]}"; do
    log_warn "  - ${EXTENSIONS[$uuid]}: $uuid"
  done
fi

log_info "Enabling extensions"
for uuid in "${!EXTENSIONS[@]}"; do
  gext_enable "$uuid"
done

log_info "GNOME extensions step complete. A Shell restart (Alt+F2, 'r', Enter on Xorg; logout/login on Wayland) may be needed for full effect."
