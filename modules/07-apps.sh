#!/usr/bin/env bash
# 07-apps.sh — Firefox, creative/media apps, utilities
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "Applications"

# ---- apt-available creative/media/utility apps ------------------------------
apt_install gimp inkscape vlc transmission-gtk timeshift

# ---- Icon theme -------------------------------------------------------------
# yaru-theme-icon ships all Yaru color variants including Yaru-sage-dark,
# which is set via gsettings in 02-gnome-settings.sh.
apt_install yaru-theme-icon

# ---- Flatpak apps (better upstream cadence / avoids snap entirely) ----------
# Firefox here is Mozilla's own official Flathub build (org.mozilla.firefox)
# — the real rapid-release browser, not the ESR/transitional-dummy mess that
# comes with trying to get a plain Firefox .deb on Ubuntu.
flatpak_install \
  org.mozilla.firefox \
  org.kde.kdenlive \
  fr.handbrake.ghb \
  org.strawberrymusicplayer.strawberry \
  org.localsend.localsend_app \
  it.mijorus.gearlever

log_section "Fonts (Nerd Fonts via Embellish)"

# Embellish — GTK4/libadwaita Nerd Font installer/manager (install, remove,
# update Nerd Fonts). This is a GUI app; open it afterwards to pick which
# Nerd Fonts you actually want (e.g. for terminal/Zed/VS Code use).
flatpak_install io.github.getnf.embellish

log_info "Apps step complete"
