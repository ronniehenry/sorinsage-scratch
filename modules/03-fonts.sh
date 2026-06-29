#!/usr/bin/env bash
# 03-fonts.sh — Atkinson Hyperlegible (via apt, no Google Fonts download needed)
#               + Fedora-style font rendering (hinting/antialiasing)
#
# Atkinson Hyperlegible is packaged directly in Ubuntu's "universe" repo as
# fonts-atkinson-hyperlegible(-ttf), so this sidesteps the Google Fonts site
# entirely — no manual zip download, no browser, just apt.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "Atkinson Hyperlegible (apt, universe repo)"

# Make sure 'universe' is enabled — it's on by default on Ubuntu, but
# confirm rather than assume, since the package lives there, not in main.
if ! grep -rEq '^deb .*universe' /etc/apt/sources.list /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/*.list 2>/dev/null; then
  log_info "Enabling the 'universe' repo component"
  sudo add-apt-repository -y universe
  sudo apt-get update
fi

apt_install fonts-atkinson-hyperlegible fonts-atkinson-hyperlegible-ttf

log_info "Refreshing font cache"
fc-cache -f >/dev/null 2>&1

log_section "Setting Atkinson Hyperlegible as the system font"

gset org.gnome.desktop.interface font-name 'Atkinson Hyperlegible 11'
gset org.gnome.desktop.interface document-font-name 'Atkinson Hyperlegible 11'
gset org.gnome.desktop.wm.preferences titlebar-font 'Atkinson Hyperlegible Bold 11'
# Monospace stays as-is here on purpose — Atkinson Hyperlegible has no mono
# cut; pair it with whatever Nerd Font you pick via Embellish (07-apps.sh)
# for terminal/code editor use instead.

log_section "Font rendering (Fedora-style hinting/antialiasing)"
#
# Fedora ships fontconfig defaults close to:
#   antialias: true
#   hinting:   true
#   hintstyle: hintslight   (Ubuntu defaults to hintfull on Noto/DejaVu)
#   rgba:      rgb          (subpixel order; 'rgb' is the common panel order)
#   lcdfilter: lcddefault

FONTCONFIG_DIR="${HOME}/.config/fontconfig"
FONTCONFIG_FILE="${FONTCONFIG_DIR}/fonts.conf"

mkdir -p "$FONTCONFIG_DIR"

if [[ -f "$FONTCONFIG_FILE" ]] && grep -q "sorinsage-font-rendering" "$FONTCONFIG_FILE" 2>/dev/null; then
  log_skip "fontconfig rendering block (already applied)"
else
  log_info "Writing ${FONTCONFIG_FILE}"
  cat <<'EOF' > "$FONTCONFIG_FILE"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<!-- sorinsage-font-rendering: Fedora-style hinting/antialiasing -->
<fontconfig>
  <match target="font">
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
    <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
  </match>
</fontconfig>
EOF
fi

# GNOME also keeps its own antialiasing/hinting prefs in gsettings, which can
# override fontconfig in some apps (GTK in particular). Align those too.
gset org.gnome.desktop.interface font-antialiasing 'rgba'
gset org.gnome.desktop.interface font-hinting 'slight'

log_info "Fonts step complete. Log out/in (or restart GNOME Shell) for it to fully take effect."
