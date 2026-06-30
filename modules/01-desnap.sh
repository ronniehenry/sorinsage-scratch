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
  # Snap dependency order isn't predictable by name (e.g. 'bare' doesn't
  # match a 'core*' pattern but is still a base snap other snaps depend on).
  # Instead, repeatedly attempt removal of whatever's left until nothing
  # changes — this naturally clears leaf snaps first, then their bases.
  for attempt in 1 2 3 4 5; do
    remaining=$(snap list 2>/dev/null | awk 'NR>1 {print $1}')
    [[ -z "$remaining" ]] && break

    still_failing=0
    while read -r snapname; do
      [[ -z "$snapname" ]] && continue
      if sudo snap remove --purge "$snapname" 2>/tmp/snap-remove-err; then
        :
      else
        still_failing=1
      fi
    done <<< "$remaining"

    [[ "$still_failing" -eq 0 ]] && break
  done

  leftover=$(snap list 2>/dev/null | awk 'NR>1 {print $1}')
  if [[ -n "$leftover" ]]; then
    log_warn "Could not remove these snaps after ${attempt} passes: $(echo "$leftover" | tr '\n' ' ')"
    log_warn "Last error: $(cat /tmp/snap-remove-err 2>/dev/null)"
    log_warn "Continuing anyway — snapd will still be purged below, which usually clears remaining base/content snaps."
  fi
  rm -f /tmp/snap-remove-err

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
