#!/usr/bin/env bash
# 07-apps.sh — Firefox, creative/media apps, utilities
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "Applications"

# ---- Firefox (.deb via Mozilla PPA, pinned in 01-desnap.sh) -----------------
apt_install firefox

# ---- apt-available creative/media/utility apps ------------------------------
apt_install gimp inkscape vlc transmission-gtk timeshift

# ---- Flatpak apps (better upstream cadence / avoids snap entirely) ----------
flatpak_install \
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

log_section "Papirus icon theme + teal folders"
apt_install papirus-icon-theme

if ! command -v papirus-folders &>/dev/null; then
  log_info "Installing papirus-folders helper"
  wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/install.sh | sh
fi
if command -v papirus-folders &>/dev/null; then
  papirus-folders -C teal --theme Papirus-Dark
  log_info "Papirus folders set to teal"
fi

log_info "Apps step complete"
