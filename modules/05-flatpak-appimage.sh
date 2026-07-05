#!/usr/bin/env bash
# 05-flatpak-appimage.sh — enable Flatpak (Flathub) and AppImage support (FUSE + Gearlever)
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "Flatpak support"

apt_install flatpak gnome-software-plugin-flatpak

if flatpak remote-list | grep -q '^flathub'; then
  log_skip "Flathub remote"
else
  log_info "Adding Flathub remote"
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

log_section "AppImage support (FUSE + Gearlever)"

# Ubuntu 22.04+ ships libfuse2t64 / libfuse2 depending on release; try both.
apt_install libfuse2t64 2>/dev/null || apt_install libfuse2

# Gearlever itself is installed as a flatpak in the apps module (07-apps.sh),
# since it's listed there too. We just make sure the runtime prerequisite
# (FUSE) is present here so AppImages can mount/run correctly regardless of
# install order.

log_info "Flatpak + AppImage prerequisites complete. Gearlever will be installed in the apps module."
