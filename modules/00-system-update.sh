#!/usr/bin/env bash
# 00-system-update.sh — apt update, full upgrade, and autoremove orphaned packages
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "System update"

sudo apt-get update
sudo apt-get upgrade -y

log_info "Removing orphaned packages"
sudo apt-get autoremove -y

log_info "apt update/upgrade/autoremove complete"
