#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  backup-rice.sh — full backup of the Hyprland setup
#  Usage:  ./backup-rice.sh   (without sudo)
#  Result: ~/dotfiles-backup, then an optional commit + push to GitHub
# ─────────────────────────────────────────────────────────────
set -uo pipefail

DEST="$HOME/dotfiles-backup"
DATE="$(date '+%Y-%m-%d %H:%M')"
# Machine name (rotten-laptop, rotten-desktop…): system files and package
# lists are stored in system/<machine>/ and packages/<machine>/
HOST="$(cat /etc/hostname 2>/dev/null || uname -n)"
SYS="$DEST/system/$HOST"
PKG="$DEST/packages/$HOST"

# ── 0. Checks ────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    echo "!! Run this script WITHOUT sudo (it asks for the password when needed)."
    exit 1
fi
for cmd in git pacman; do
    if ! command -v "$cmd" >/dev/null; then
        echo "==> $cmd missing, installing..."
        sudo pacman -S --needed --noconfirm "$cmd"
    fi
done

echo "==> Backing up to $DEST (machine: $HOST)"
mkdir -p "$DEST/home" "$SYS" "$PKG"

# Copy an item from /home, keeping its path
save_home() {
    local src="$1" rel
    if [[ ! -e "$src" ]]; then
        echo "   (missing, skipped) $src"
        return
    fi
    rel="${src#"$HOME"/}"
    mkdir -p "$DEST/home/$(dirname "$rel")"
    rm -rf "$DEST/home/$rel"
    cp -a "$src" "$DEST/home/$rel"
    echo "   ok  $src"
}

# Copy a system item (read with sudo), keeping its path
save_system() {
    local src="$1" rel
    if ! sudo test -e "$src"; then
        echo "   (missing, skipped) $src"
        return
    fi
    rel="${src#/}"
    sudo mkdir -p "$SYS/$(dirname "$rel")"
    sudo rm -rf "${SYS:?}/$rel"
    sudo cp -a "$src" "$SYS/$rel"
    echo "   ok  $src"
}

# ── 1. User config ───────────────────────────────────────────
echo "==> User config"
# Serpantinum itself (~/.local/share/serpantinum, ~/.local/state/serpantinum)
# is NOT saved: it is installed by its own installer, each machine may run a
# different version, and the code changes are reproduced by scripts/patch-*.py
HOME_ITEMS=(
    "$HOME/.config/hypr"              # Hyprland: borders, animations, keybinds, rules
    "$HOME/.config/kitty"             # terminal
    "$HOME/.config/fastfetch"         # including perso.jsonc
    "$HOME/.config/cava"
    "$HOME/.config/starship.toml"
    "$HOME/.config/eza"               # ls colors (eza)
    "$HOME/.config/nvim"              # LazyVim
    "$HOME/.config/nano"              # nano colors
    "$HOME/.config/environment.d"     # session variables (GTK_THEME…)
    "$HOME/.config/pipewire"          # virtual "Music" sink and "Microphone (Nebula)" source
    "$HOME/.local/share/applications" # launcher entries (Neovim in kitty…)
    "$HOME/.config/oh-my-posh"
    "$HOME/.config/gtk-3.0"
    "$HOME/.config/gtk-4.0"
    "$HOME/.config/Kvantum"           # Nebula theme (Dolphin & Qt apps)
    "$HOME/.config/kdeglobals"        # KDE colors used by Dolphin
    "$HOME/.config/dolphinrc"         # Dolphin settings (Nebula color scheme)
    "$HOME/.local/share/color-schemes" # Nebula color scheme
    "$HOME/.config/qt5ct"
    "$HOME/.config/qt6ct"
    "$HOME/.config/matugen"
    "$HOME/.zshrc"                    # fastfetch, eza, selection keys, clear
    "$HOME/.zshenv"
    "$HOME/.p10k.zsh"
    "$HOME/.local/bin"                # personal scripts and commands
    "$HOME/.local/share/icons/ChromaS"   # cursor (Chroma S)
    "$HOME/Pictures/Wallpapers"
)
for item in "${HOME_ITEMS[@]}"; do
    save_home "$item"
done

# Serpantinum settings (idle, bar, theme…) WITHOUT the location
# (IP address, GPS coordinates and postcode used for the weather)
SERP_SETTINGS="$HOME/.config/serpantinum/settings.json"
if [[ -f "$SERP_SETTINGS" ]]; then
    mkdir -p "$DEST/home/.config/serpantinum"
    python3 - "$SERP_SETTINGS" "$DEST/home/.config/serpantinum/settings.json" << 'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
data.get("general", {}).pop("location", None)
json.dump(data, open(sys.argv[2], "w", encoding="utf-8"), indent=2, ensure_ascii=False)
PY
    echo "   ok  $SERP_SETTINGS (location removed)"
fi

# ── 2. Modified system files ─────────────────────────────────
echo "==> System files (password or fingerprint required)"
SYSTEM_ITEMS=(
    "/etc/fstab"                      # disks mounted at boot (/home on a second drive, data disk…)
    "/etc/pam.d/sddm"                 # login: password first, then fingerprint
    "/etc/pam.d/sudo"                 # sudo with fingerprint
    "/etc/pam.d/serpantinum-fprint"   # fingerprint on the lock screen (SUPER + L)
    "/etc/sddm.conf.d"                # active SDDM theme (nebula)
    "/usr/share/sddm/themes/nebula"   # the nebula theme
    "/var/lib/bluetooth"              # Bluetooth pairings (headphones, keyboard)
    "/etc/systemd/logind.conf.d"      # lid / sleep key: no suspend on AC
    "/usr/local/bin/suspend-hyprland.sh"           # pauses Hyprland during sleep (NVIDIA)
    "/etc/systemd/system/hyprland-suspend.service"
    "/etc/systemd/system/hyprland-resume.service"
)
for item in "${SYSTEM_ITEMS[@]}"; do
    save_system "$item"
done
sudo chown -R "$USER:$USER" "$SYS"
# The Bluetooth cache lists every device ever seen nearby (phones…):
# useless, only the pairings are kept
rm -rf "$SYS"/var/lib/bluetooth/*/cache

# ── 3. Package lists ─────────────────────────────────────────
echo "==> Package lists"
pacman -Qqen > "$PKG/pacman.txt"   # official repositories
pacman -Qqem > "$PKG/aur.txt"      # AUR / foreign packages

# Settings that aren't files: enabled services and gsettings
systemctl list-unit-files --state=enabled --no-legend > "$PKG/services-system.txt"
systemctl --user list-unit-files --state=enabled --no-legend > "$PKG/services-user.txt"
gsettings list-recursively org.gnome.desktop.interface > "$PKG/gsettings-interface.txt" 2>/dev/null
echo "   ok  enabled services + gsettings"
echo "   ok  $(wc -l < "$PKG/pacman.txt") official, $(wc -l < "$PKG/aur.txt") AUR"

# ── 4. Remove nested git repositories ────────────────────────
find "$DEST" -mindepth 2 -name ".git" -type d -prune -exec rm -rf {} +

# ── 5. Timestamp ─────────────────────────────────────────────
echo "Last backup: $DATE" > "$DEST/LAST_BACKUP.txt"
echo "==> Backup done ($(du -sh "$DEST" | cut -f1))"

# ── 6. Push to GitHub ────────────────────────────────────────
if [[ -d "$DEST/.git" ]]; then
    read -rp "==> Push to GitHub now? [y/N] " answer
    if [[ "$answer" =~ ^[yYoO]$ ]]; then
        cd "$DEST" || exit 1
        git add -A
        if git diff --cached --quiet; then
            echo "   Nothing new since the last backup."
        else
            git commit -m "backup $DATE"
            git push
        fi
    fi
fi
