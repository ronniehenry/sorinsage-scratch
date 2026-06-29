#!/usr/bin/env bash
# 01-desnap.sh — remove snapd and prevent it from coming back
# (snap-default apps like Firefox get reinstalled via apt/flatpak in later modules)
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "De-snapping Ubuntu"

if ! command -v snap &>/dev/null; then
  log_skip "snapd (not installed)"
else
  log_info "Removing installed snaps"
  # Remove snaps in reverse dependency order; core/snapd last.
  snap list 2>/dev/null | awk 'NR>1 {print $1}' | grep -v '^core' | grep -v '^snapd$' | while read -r snapname; do
    [[ -n "$snapname" ]] && sudo snap remove --purge "$snapname"
  done
  for core_snap in $(snap list 2>/dev/null | awk 'NR>1 && /^core/{print $1}'); do
    sudo snap remove --purge "$core_snap"
  done
  sudo snap remove --purge snapd 2>/dev/null || true

  log_info "Purging snapd package"
  sudo apt-get purge -y snapd
  sudo apt-mark hold snapd

  log_info "Cleaning up leftover snap directories"
  rm -rf "${HOME}/snap"
  sudo rm -rf /snap /var/snap /var/lib/snapd
fi

log_info "Blocking snapd from being reinstalled as a dependency"
cat <<'EOF' | sudo tee /etc/apt/preferences.d/no-snap.pref >/dev/null
Package: snapd
Pin: release *
Pin-Priority: -1
EOF

log_info "Desnap complete. Firefox will be installed via flatpak in the apps module (no PPA needed)."
