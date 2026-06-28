#!/usr/bin/env bash
# setup.sh — SorinSage Ubuntu setup, main runner
#
# Usage:
#   ./setup.sh              # interactive, asks before each step
#   ./setup.sh --yes        # non-interactive, runs everything
#   ./setup.sh --only 04    # run only module(s) matching the given prefix(es)
#
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

export SORINSAGE_NONINTERACTIVE=0
ONLY_FILTER=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y)
      export SORINSAGE_NONINTERACTIVE=1
      shift
      ;;
    --only)
      ONLY_FILTER+=("$2")
      shift 2
      ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      log_error "Unknown argument: $1"
      exit 1
      ;;
  esac
done

require_not_root
require_ubuntu

MODULES=(
  "00-system-update.sh:System update (apt update && upgrade)"
  "01-desnap.sh:De-snap Ubuntu"
  "02-gnome-settings.sh:GNOME settings"
  "03-fonts.sh:Fonts (Atkinson Hyperlegible via apt + Fedora-style rendering)"
  "04-gnome-extensions.sh:GNOME extensions"
  "05-flatpak-appimage.sh:Flatpak + AppImage support"
  "06-dev-tools.sh:Development tools (PyCharm, Arduino IDE, VS Code, Zed, PlatformIO, git extensions)"
  "07-apps.sh:Applications (Firefox, GIMP, Inkscape, Kdenlive, etc.)"
  "08-zsh.sh:zsh + oh-my-zsh (set as default shell)"
)

log_section "SorinSage Setup"
log_info "Running on: $(lsb_release -ds 2>/dev/null || echo 'unknown distro')"

for entry in "${MODULES[@]}"; do
  file="${entry%%:*}"
  desc="${entry#*:}"
  prefix="${file%%-*}"

  if [[ ${#ONLY_FILTER[@]} -gt 0 ]]; then
    match=0
    for f in "${ONLY_FILTER[@]}"; do
      [[ "$prefix" == "$f" || "$file" == "$f" ]] && match=1
    done
    [[ $match -eq 0 ]] && continue
  fi

  run_module "$desc" "${SCRIPT_DIR}/modules/${file}"
done

log_section "Done"
log_info "Some changes (GNOME extensions, font rendering, panel) may need a logout/login to fully apply."
