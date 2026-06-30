#!/usr/bin/env bash
# 02-gnome-settings.sh — apply SorinSage GNOME gsettings
#
# This is a SCAFFOLD. Fill in / uncomment the values that match your actual
# setup — these are placeholders grouped by category based on what we've
# discussed (calm, minimal, sage/teal aesthetic,
# MX Master 3S + Attack Shark V5 dual-mouse use).
#
# Tip: to pull your CURRENT live values for any key, run:
#   gsettings get <schema> <key>
# and paste the result in below to lock in what you already have.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "GNOME settings"

# ---- Interface / appearance ----------------------------------------------
gset org.gnome.desktop.interface color-scheme 'prefer-dark'
gset org.gnome.desktop.interface icon-theme 'Yaru-sage-dark'
# Note: yaru-theme-icon (which ships Yaru-sage-dark) is installed in 07-apps.sh.
# gsettings stores the preference now; GNOME applies it once the package lands.
# gset org.gnome.desktop.interface gtk-theme 'YOUR_GTK_THEME'
gset org.gnome.desktop.interface cursor-theme 'Adwaita'
gset org.gnome.desktop.interface clock-show-weekday true
gset org.gnome.desktop.interface enable-hot-corners false

# ---- Window management / behavior -----------------------------------------
gset org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gset org.gnome.desktop.wm.preferences focus-mode 'click'
gset org.gnome.mutter center-new-windows true
gset org.gnome.mutter edge-tiling true

# ---- Workspaces -------------------------------------------------------------
gset org.gnome.mutter dynamic-workspaces true
gset org.gnome.desktop.wm.preferences num-workspaces 4

# ---- Touchpad / mouse -------------------------------------------------------
# Relevant given your MX Master 3S (dev/video editing) + Attack Shark V5 (casual/gaming)
gset org.gnome.desktop.peripherals.mouse accel-profile 'default'
gset org.gnome.desktop.peripherals.touchpad tap-to-click true
gset org.gnome.desktop.peripherals.touchpad natural-scroll true

# ---- Privacy -----------------------------------------------------------------
gset org.gnome.desktop.privacy remember-recent-files true
gset org.gnome.desktop.privacy old-files-age 'uint32 30'

# ---- Nautilus (Files) ---------------------------------------------------------
gset org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gset org.gnome.nautilus.list-view use-tree-view true

# ---- Power -----------------------------------------------------------------
gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gset org.gnome.desktop.session idle-delay 'uint32 600'

# ---- Extension-specific settings (placeholders — fill in once 04 runs) -----
# Rounded Window Corners Reborn — usually configured via its own GUI prefs,
# not plain gsettings; open the Extension Manager / extension settings after
# module 04 to tune corner radius, smoothing, and skip lists.

log_warn "This module is a placeholder scaffold — review and edit the gsettings keys above to match your live config before relying on it."
log_info "GNOME settings step complete"
