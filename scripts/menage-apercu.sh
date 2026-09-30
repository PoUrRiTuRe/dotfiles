#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  menage-apercu.sh — ESSAI À BLANC du ménage KDE Plasma / GNOME
#  Ne supprime RIEN. Il :
#    1. protège les paquets utiles (marqués « installés explicitement »)
#    2. calcule la liste de ce qui serait supprimé
#    3. affiche le résultat de pacman en mode aperçu
#  Usage : ./menage-apercu.sh   (sans sudo)
# ─────────────────────────────────────────────────────────────
set -uo pipefail
[[ $EUID -eq 0 ]] && { echo "!! Lance ce script sans sudo."; exit 1; }

DIR="$HOME/menage"
mkdir -p "$DIR"

# ── Paquets à GARDER (modifie cette liste si besoin) ─────────
cat > "$DIR/garder.txt" << 'EOF'
# Applis que tu utilises
evince
gnome-text-editor
gnome-calculator
gnome-disk-utility
wireshark-qt
# Dolphin et son thème
dolphin
kvantum
qt6ct
breeze-icons
kio-extras
ffmpegthumbs
kdegraphics-thumbnailers
archlinux-xdg-menu
plasma-activities
# Connexion, trousseau, empreinte
sddm
qt6-5compat
gnome-keyring
fprintd
polkit
hyprpolkitagent
# Réseau, Bluetooth, son, batterie (utilisés par Serpantinum)
networkmanager
bluez
bluez-utils
pipewire
pipewire-pulse
wireplumber
upower
power-profiles-daemon
# Clés USB, corbeille et disques (Dolphin, Evince)
udisks2
gvfs
# Utilitaires et polices utiles au quotidien
noto-fonts-emoji
unzip
socat
accountsservice
gst-plugins-base
gst-plugins-good
# Outils appelés par les scripts de Serpantinum
ddcutil
imagemagick
libqalculate
# Portails (fenêtres « Ouvrir un fichier », partage d'écran)
xdg-desktop-portal
xdg-desktop-portal-gtk
xdg-desktop-portal-hyprland
EOF

grep -v '^#' "$DIR/garder.txt" | sed '/^$/d' | sort -u > "$DIR/garder.list"

# ── 1. Protéger les paquets à garder qui sont installés ──────
INSTALLED_KEEP=$(comm -12 "$DIR/garder.list" <(pacman -Qq | sort))
echo "==> Protection de $(echo "$INSTALLED_KEEP" | wc -w) paquets (mot de passe ou empreinte)"
# shellcheck disable=SC2086
sudo pacman -D --asexplicit $INSTALLED_KEEP >/dev/null

# ── 2. Liste des candidats à la suppression ─────────────────
{
    pacman -Qqg plasma 2>/dev/null
    pacman -Qqg gnome 2>/dev/null
    printf '%s\n' plasma-meta gdm xdg-desktop-portal-gnome xdg-desktop-portal-kde polkit-kde-agent
} | sort -u | comm -12 - <(pacman -Qq | sort) | comm -23 - "$DIR/garder.list" > "$DIR/supprimer.txt"

echo "==> $(wc -l < "$DIR/supprimer.txt") paquets KDE / GNOME ciblés"

# ── 3. Aperçu de pacman (rien n'est supprimé) ────────────────
# shellcheck disable=SC2046
pacman -Rsp --print-format '%n' $(cat "$DIR/supprimer.txt") \
    > "$DIR/apercu.txt" 2> "$DIR/erreurs.txt"

echo "==> Au total, pacman supprimerait $(wc -l < "$DIR/apercu.txt") paquets (dépendances comprises)"
if [[ -s "$DIR/erreurs.txt" ]]; then
    echo "!! pacman signale des blocages :"
    cat "$DIR/erreurs.txt"
else
    echo "==> Aucun blocage signalé"
fi
echo
echo "Fichiers à m'envoyer :"
echo "   $DIR/apercu.txt   (liste complète de ce qui serait supprimé)"
echo "   $DIR/erreurs.txt  (blocages éventuels)"
