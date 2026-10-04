#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  kde-cleanup-preview.sh — DRY RUN of the KDE Plasma / GNOME cleanup
#  Removes NOTHING. It:
#    1. protects useful packages (marks them "explicitly installed")
#    2. computes the list of what would be removed
#    3. shows pacman's result in preview mode
#  Usage:  ./kde-cleanup-preview.sh   (without sudo)
# ─────────────────────────────────────────────────────────────
set -uo pipefail
[[ $EUID -eq 0 ]] && { echo "!! Run this script without sudo."; exit 1; }

DIR="$HOME/kde-cleanup"
mkdir -p "$DIR"

# ── Packages to KEEP (edit this list if needed) ──────────────
cat > "$DIR/keep.txt" << 'EOF'
# Apps in use
evince
gnome-text-editor
gnome-calculator
gnome-disk-utility
wireshark-qt
# Dolphin and its theme
dolphin
kvantum
qt6ct
breeze-icons
kio-extras
ffmpegthumbs
kdegraphics-thumbnailers
archlinux-xdg-menu
plasma-activities
# Archives: Dolphin "Compress / Extract" menu
ark
7zip
unrar
unzip
# Login, keyring, fingerprint
sddm
qt6-5compat
gnome-keyring
fprintd
polkit
hyprpolkitagent
# Network, Bluetooth, audio, battery (used by Serpantinum)
networkmanager
bluez
bluez-utils
pipewire
pipewire-pulse
wireplumber
upower
power-profiles-daemon
# USB drives, trash and disks (Dolphin, Evince)
udisks2
gvfs
# Everyday utilities and fonts
noto-fonts-emoji
socat
accountsservice
gst-plugins-base
gst-plugins-good
# Tools called by Serpantinum scripts
ddcutil
imagemagick
libqalculate
# Portals ("Open file" dialogs, screen sharing)
xdg-desktop-portal
xdg-desktop-portal-gtk
xdg-desktop-portal-hyprland
EOF

grep -v '^#' "$DIR/keep.txt" | sed '/^$/d' | sort -u > "$DIR/keep.list"

# ── 1. Protect the installed packages to keep ────────────────
INSTALLED_KEEP=$(comm -12 "$DIR/keep.list" <(pacman -Qq | sort))
echo "==> Protecting $(echo "$INSTALLED_KEEP" | wc -w) packages (password or fingerprint)"
# shellcheck disable=SC2086
sudo pacman -D --asexplicit $INSTALLED_KEEP >/dev/null

# ── 2. Removal candidates ────────────────────────────────────
{
    pacman -Qqg plasma 2>/dev/null
    pacman -Qqg gnome 2>/dev/null
    printf '%s\n' plasma-meta gdm xdg-desktop-portal-gnome xdg-desktop-portal-kde polkit-kde-agent
} | sort -u | comm -12 - <(pacman -Qq | sort) | comm -23 - "$DIR/keep.list" > "$DIR/remove.txt"

echo "==> $(wc -l < "$DIR/remove.txt") KDE / GNOME packages targeted"

# ── 3. pacman preview (nothing is removed) ───────────────────
# shellcheck disable=SC2046
pacman -Rsp --print-format '%n' $(cat "$DIR/remove.txt") \
    > "$DIR/preview.txt" 2> "$DIR/errors.txt"

echo "==> In total, pacman would remove $(wc -l < "$DIR/preview.txt") packages (dependencies included)"
if [[ -s "$DIR/errors.txt" ]]; then
    echo "!! pacman reports blockers:"
    cat "$DIR/errors.txt"
else
    echo "==> No blockers reported"
fi
echo
echo "Result files:"
echo "   $DIR/preview.txt  (full list of what would be removed)"
echo "   $DIR/errors.txt   (blockers, if any)"
