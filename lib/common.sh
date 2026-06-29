#!/usr/bin/env bash
# lib/common.sh — shared helpers for sorinsage-setup modules
# Sourced by setup.sh before any module runs. Do not execute directly.

set -uo pipefail

# ---- colors -----------------------------------------------------------
readonly C_RESET='\033[0m'
readonly C_BLUE='\033[1;34m'
readonly C_GREEN='\033[1;32m'
readonly C_YELLOW='\033[1;33m'
readonly C_RED='\033[1;31m'

# ---- logging ------------------------------------------------------------
log_section() { echo -e "\n${C_BLUE}==>${C_RESET} ${1}"; }
log_info()    { echo -e "${C_GREEN}  -${C_RESET} ${1}"; }
log_warn()    { echo -e "${C_YELLOW}  !${C_RESET} ${1}"; }
log_error()   { echo -e "${C_RED}  x${C_RESET} ${1}" >&2; }
log_skip()    { echo -e "${C_YELLOW}  skip${C_RESET} ${1} (already present)"; }

# ---- sanity --------------------------------------------------------------
require_not_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    log_error "Run this as your normal user, not root. The script will sudo when it needs to."
    exit 1
  fi
}

require_ubuntu() {
  if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
    log_warn "This doesn't look like Ubuntu. Continuing anyway, but expect rough edges."
  fi
}

# ---- apt helpers -------------------------------------------------------
apt_install() {
  # Usage: apt_install pkg1 pkg2 ...
  local pkgs=("$@")
  local to_install=()
  for p in "${pkgs[@]}"; do
    if dpkg -s "$p" &>/dev/null; then
      log_skip "$p"
    else
      to_install+=("$p")
    fi
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    log_info "Installing: ${to_install[*]}"
    sudo apt-get install -y "${to_install[@]}"
  fi
}

apt_repo_add_once() {
  # Usage: apt_repo_add_once <ppa-or-repo-line> <sources-list-name>
  local repo="$1"
  if ! grep -rq "$repo" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    sudo add-apt-repository -y "$repo"
    return 0
  fi
  return 1
}

# ---- flatpak helpers -----------------------------------------------------
flatpak_install() {
  # Usage: flatpak_install <app.id> [app.id ...]
  for app_id in "$@"; do
    if flatpak info "$app_id" &>/dev/null; then
      log_skip "$app_id"
    else
      log_info "Installing flatpak: $app_id"
      flatpak install -y --noninteractive flathub "$app_id"
    fi
  done
}

# ---- gnome extension helpers ----------------------------------------------
gext_is_installed() {
  local uuid="$1"
  gnome-extensions list 2>/dev/null | grep -qx "$uuid"
}

gext_enable() {
  local uuid="$1"
  if gext_is_installed "$uuid"; then
    gnome-extensions enable "$uuid" 2>/dev/null \
      && log_info "Enabled extension: $uuid" \
      || log_warn "Could not enable $uuid (may need a session restart)"
  else
    log_warn "$uuid not installed yet — install it via extensions.gnome.org or the Extension Manager flatpak, then re-run this module"
  fi
}

# ---- gsettings helper (idempotent by nature, just wraps for logging) -----
gset() {
  # Usage: gset <schema> <key> <value>
  local schema="$1" key="$2" value="$3"
  if gsettings set "$schema" "$key" "$value" 2>/dev/null; then
    log_info "${schema} ${key} -> ${value}"
  else
    log_warn "Failed to set ${schema} ${key} (schema may not be installed)"
  fi
}

# ---- step runner with confirmation skip ------------------------------------
run_module() {
  # Usage: run_module "Description" path/to/module.sh
  local desc="$1" path="$2"
  log_section "$desc"
  if [[ "${SORINSAGE_NONINTERACTIVE:-0}" != "1" ]]; then
    read -r -p "    Run this step? [Y/n] " reply
    reply=${reply:-Y}
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      log_warn "Skipped: $desc"
      return 0
    fi
  fi
  bash "$path"
}
