#!/usr/bin/env bash
# 08-zsh.sh — install zsh, install oh-my-zsh, set zsh as the default login shell
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_section "zsh"

apt_install zsh git curl

log_section "oh-my-zsh"

OMZ_DIR="${HOME}/.oh-my-zsh"

if [[ -d "$OMZ_DIR" ]]; then
  log_skip "oh-my-zsh (already installed at ${OMZ_DIR})"
else
  log_info "Installing oh-my-zsh"
  # --unattended: skips the interactive prompts and skips auto-launching a
  # new zsh shell at the end (which would otherwise hang a scripted run).
  # --keep-zshrc: avoids clobbering an existing .zshrc if one is already
  # present from a previous partial setup.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

log_section "Theme"

ZSHRC="${HOME}/.zshrc"

if [[ -f "$ZSHRC" ]]; then
  if grep -qx 'ZSH_THEME="bira"' "$ZSHRC"; then
    log_skip "ZSH_THEME (already set to bira)"
  elif grep -q '^ZSH_THEME=' "$ZSHRC"; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="bira"/' "$ZSHRC"
    log_info "Set ZSH_THEME to bira"
  else
    echo 'ZSH_THEME="bira"' >> "$ZSHRC"
    log_info "Added ZSH_THEME=\"bira\" to ${ZSHRC}"
  fi
else
  log_warn "${ZSHRC} not found — oh-my-zsh install may not have completed correctly"
fi

log_section "Default shell"

ZSH_PATH="$(command -v zsh)"

if [[ "${SHELL:-}" == "$ZSH_PATH" ]]; then
  log_skip "default shell (already zsh)"
elif [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$ZSH_PATH" ]]; then
  log_skip "default shell (already zsh per /etc/passwd)"
else
  log_info "Setting zsh as the default shell for ${USER}"
  if grep -qx "$ZSH_PATH" /etc/shells; then
    sudo chsh -s "$ZSH_PATH" "$USER"
    log_info "Default shell changed to ${ZSH_PATH}. Log out/in for it to take effect."
  else
    log_warn "${ZSH_PATH} is not listed in /etc/shells — adding it, then setting as default"
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    sudo chsh -s "$ZSH_PATH" "$USER"
  fi
fi

log_info "zsh step complete. Log out/in (or open a new terminal) to start using zsh + oh-my-zsh."
