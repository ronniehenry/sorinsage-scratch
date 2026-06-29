# sorinsage-setup

Modular post-install setup script for Ubuntu 26.04 LTS (GNOME), built for the
SorinSage workstation.

## Usage

```bash
chmod +x setup.sh modules/*.sh lib/common.sh   # already done if you unzip in place
./setup.sh                # interactive — confirms before each module
./setup.sh --yes          # non-interactive — runs every module
./setup.sh --only 04      # run a single module by its numeric prefix
./setup.sh --only 04 --only 06   # run multiple specific modules
```

Run as your normal user — the script calls `sudo` itself where needed; it
will refuse to run as root.

## Module order

| # | Module | What it does |
|---|--------|---------------|
| 00 | `00-system-update.sh` | `apt update && apt upgrade -y` |
| 01 | `01-desnap.sh` | Removes snapd entirely, purges leftover snap dirs, pins snapd so it can't sneak back in |
| 02 | `02-gnome-settings.sh` | **Placeholder scaffold** — gsettings grouped by category (interface, window management, peripherals, privacy, Nautilus, power, extension prefs). Edit the values to match your live config. |
| 03 | `03-fonts.sh` | Installs Atkinson Hyperlegible via apt (`fonts-atkinson-hyperlegible`, `-ttf` — lives in Ubuntu's `universe` repo, no Google Fonts download needed), sets it as the system/document/titlebar font, then applies Fedora-style font *rendering* (hintslight, rgb subpixel, lcddefault) via `~/.config/fontconfig/fonts.conf` + matching gsettings |
| 04 | `04-gnome-extensions.sh` | Installs `gext` (gnome-extensions-cli) via pipx, installs + enables Blur My Shell, Just Perfection, Rounded Window Corners Reborn, AppIndicator Support |
| 05 | `05-flatpak-appimage.sh` | Flatpak + Flathub remote; FUSE for AppImage support (Gearlever itself installs in 07) |
| 06 | `06-dev-tools.sh` | VS Code (MS apt repo), Zed (official installer), PyCharm Community + Arduino IDE (flatpak), PlatformIO + git-related VS Code extensions |
| 07 | `07-apps.sh` | GIMP, Inkscape, VLC, Transmission, Timeshift (apt) + Firefox, Kdenlive, HandBrake, Strawberry, LocalSend, Gearlever (flatpak) + Embellish (Nerd Font installer/manager, flatpak) + Papirus icons with teal folders |
| 08 | `08-zsh.sh` | Installs zsh + oh-my-zsh (unattended install, keeps any existing `.zshrc`), sets `ZSH_THEME` to `bira`, sets zsh as your default login shell via `chsh` |

## Notes

- **Firefox installs as the official Mozilla flatpak** (`org.mozilla.firefox`
  on Flathub) rather than via apt. This sidesteps the PPA/pinning mess
  entirely — Ubuntu's own `firefox` apt package is just a transitional dummy
  pointing at the snap, and there's no real rapid-release `.deb` available
  for this Ubuntu release any other way. Profile data lives under
  `~/.var/app/org.mozilla.firefox/` instead of `~/.mozilla/`, which matters
  if you ever migrate an old profile in.
- **Module 02 is intentionally a placeholder.** You chose to scaffold rather
  than paste a dconf dump, so review every `gset` line before trusting it —
  some values are reasonable guesses, not your actual current config.
- **Atkinson Hyperlegible comes from apt, not Google Fonts.** It's packaged
  in Ubuntu's `universe` repo (`fonts-atkinson-hyperlegible` /
  `-ttf`), so module 03 never touches fonts.google.com — just `apt install`.
  If you'd rather not have it set as your *system* font automatically, delete
  or comment out the three `gset ... font-name` lines in `03-fonts.sh`; the
  font will still be installed and selectable manually.
- **zsh becomes your default shell after module 08** — this only takes
  effect on your *next* login (new terminal tabs in an already-open GNOME
  session may still show bash until you fully log out/in). The theme is set
  to `bira` (a built-in oh-my-zsh theme — no extra download); change it later
  by editing `ZSH_THEME` in `~/.zshrc`. Plugins are left at whatever oh-my-zsh
  defaults to — add your own in the `plugins=(...)` line afterward.
- Idempotent by design: re-running is safe. `apt_install` and `flatpak_install`
  skip anything already present; gsettings/extension calls just re-apply the
  same value.
- A logout/login (or GNOME Shell restart on Xorg via `Alt+F2` → `r`) is
  recommended after modules 02–04 to see everything take effect.
- If you ever want to pull your **current live** gsettings to replace the
  placeholders in 02, dump them with:
  ```bash
  dconf dump /org/gnome/ > ~/gnome-dconf-backup.ini
  ```
  and pick out the keys you actually rely on.
