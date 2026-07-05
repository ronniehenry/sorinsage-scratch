#!/usr/bin/env bash
# 01-system-extras.sh — firewall, restricted codecs, DVD support
#
# Run order matters here:
#   1. UFW enabled first (baseline security before apps install)
#   2. ubuntu-restricted-extras (MP3/AAC/codec support for VLC, Strawberry, etc.)
#   3. libdvd-pkg (DVD playback — depends on restricted-extras being present,
#      requires dpkg-reconfigure after install to compile the CSS library)
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "Firewall (UFW)"

apt_install ufw

if sudo ufw status | grep -q "Status: active"; then
  log_skip "UFW (already active)"
else
  log_info "Enabling UFW"
  sudo ufw enable
  log_info "UFW enabled — default policy: deny incoming, allow outgoing"
fi

log_section "Restricted extras (MP3, AAC, codecs, Microsoft fonts)"

# Pre-accept the Microsoft TrueType fonts EULA so apt doesn't hang
# waiting for interactive input during an unattended run.
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" \
  | sudo debconf-set-selections

apt_install ubuntu-restricted-extras

log_section "DVD playback support (libdvd-pkg)"

apt_install libdvd-pkg

# dpkg-reconfigure compiles libdvdcss from source after install.
# This step is always run (not just on first install) since re-running
# it on an already-configured system is safe and takes only a few seconds.
log_info "Running dpkg-reconfigure libdvd-pkg (compiles DVD CSS library)"
sudo dpkg-reconfigure -f noninteractive libdvd-pkg

log_info "System extras step complete"
