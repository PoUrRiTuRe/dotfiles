#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  backup-rice.sh — sauvegarde complète du setup Hyprland (v2)
#  Usage : ./backup-rice.sh
#  Résultat : ~/dotfiles-backup, puis commit + push GitHub (optionnel)
# ─────────────────────────────────────────────────────────────
set -uo pipefail

DEST="$HOME/dotfiles-backup"
DATE="$(date '+%Y-%m-%d %H:%M')"

# ── 0. Vérifications ─────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    echo "!! Lance ce script SANS sudo (il demandera le mot de passe quand il faut)."
    exit 1
fi
for cmd in git pacman; do
    if ! command -v "$cmd" >/dev/null; then
        echo "==> $cmd manquant, installation..."
        sudo pacman -S --needed --noconfirm "$cmd"
    fi
done

echo "==> Sauvegarde dans $DEST"
mkdir -p "$DEST"/{home,system,packages}

# Copie un élément du /home en gardant son chemin
save_home() {
    local src="$1" rel
    if [[ ! -e "$src" ]]; then
        echo "   (absent, ignoré) $src"
        return
    fi
    rel="${src#"$HOME"/}"
    mkdir -p "$DEST/home/$(dirname "$rel")"
    rm -rf "$DEST/home/$rel"
    cp -a "$src" "$DEST/home/$rel"
    echo "   ok  $src"
}

# Copie un élément système (lecture en sudo) en gardant son chemin
save_system() {
    local src="$1" rel
    if ! sudo test -e "$src"; then
        echo "   (absent, ignoré) $src"
        return
    fi
    rel="${src#/}"
    sudo mkdir -p "$DEST/system/$(dirname "$rel")"
    sudo rm -rf "$DEST/system/$rel"
    sudo cp -a "$src" "$DEST/system/$rel"
    echo "   ok  $src"
}

# ── 1. Config utilisateur ────────────────────────────────────
echo "==> Config utilisateur"
HOME_ITEMS=(
    "$HOME/.config/hypr"              # Hyprland : bordure, animations, raccourcis, règles
    "$HOME/.config/kitty"             # terminal
    "$HOME/.config/fastfetch"         # dont perso.jsonc
    "$HOME/.config/cava"
    "$HOME/.config/starship.toml"
    "$HOME/.config/oh-my-posh"
    "$HOME/.config/gtk-3.0"
    "$HOME/.config/gtk-4.0"
    "$HOME/.config/Kvantum"           # thème Nebula (Dolphin & applis Qt)
    "$HOME/.config/kdeglobals"        # couleurs KDE utilisées par Dolphin
    "$HOME/.config/dolphinrc"         # réglages Dolphin (jeu de couleurs Nebula)
    "$HOME/.local/share/color-schemes" # jeu de couleurs Nebula
    "$HOME/.config/qt5ct"
    "$HOME/.config/qt6ct"
    "$HOME/.config/matugen"
    "$HOME/.local/share/serpantinum"  # shell/topbar + config matugen modifiée
    "$HOME/.local/state/serpantinum"
    "$HOME/.zshrc"                    # fastfetch perso + bindkey Ctrl+flèches
    "$HOME/.zshenv"
    "$HOME/.p10k.zsh"
    "$HOME/.local/bin"                # scripts et commandes perso (serpantinum ?)
    "$HOME/.local/share/icons/ChromaS"    # curseurs Chroma S (croix de précision)
    "$HOME/Pictures/Wallpapers"
)
for item in "${HOME_ITEMS[@]}"; do
    save_home "$item"
done

# ── 2. Fichiers système modifiés ─────────────────────────────
echo "==> Fichiers système (mot de passe ou empreinte demandé)"
SYSTEM_ITEMS=(
    "/etc/pam.d/sddm"                 # login mot de passe puis empreinte
    "/etc/pam.d/sudo"                 # sudo avec empreinte
    "/etc/sddm.conf.d"                # thème SDDM actif (nebula)
    "/usr/share/sddm/themes/nebula"   # le thème nebula
    "/var/lib/bluetooth"              # appairages Bluetooth (casque WH-1000XM4)
)
for item in "${SYSTEM_ITEMS[@]}"; do
    save_system "$item"
done
sudo chown -R "$USER:$USER" "$DEST/system"
# Le cache Bluetooth liste tous les appareils croisés (voisins, téléphones...) :
# inutile, on ne garde que les appairages
rm -rf "$DEST"/system/var/lib/bluetooth/*/cache

# ── 3. Liste des paquets ─────────────────────────────────────
echo "==> Liste des paquets"
pacman -Qqen > "$DEST/packages/pacman.txt"   # dépôts officiels
pacman -Qqem > "$DEST/packages/aur.txt"      # AUR / hors dépôts
echo "   ok  $(wc -l < "$DEST/packages/pacman.txt") officiels, $(wc -l < "$DEST/packages/aur.txt") AUR"

# ── 4. Nettoyage des dépôts git imbriqués ────────────────────
find "$DEST" -mindepth 2 -name ".git" -type d -prune -exec rm -rf {} +

# ── 5. Horodatage ────────────────────────────────────────────
echo "Dernière sauvegarde : $DATE" > "$DEST/LAST_BACKUP.txt"
echo "==> Sauvegarde terminée ($(du -sh "$DEST" | cut -f1))"

# ── 6. Envoi sur GitHub ──────────────────────────────────────
if [[ -d "$DEST/.git" ]]; then
    read -rp "==> Envoyer sur GitHub maintenant ? [o/N] " answer
    if [[ "$answer" =~ ^[oOyY]$ ]]; then
        cd "$DEST" || exit 1
        git add -A
        if git diff --cached --quiet; then
            echo "   Rien de nouveau depuis la dernière sauvegarde."
        else
            git commit -m "backup $DATE"
            git push
        fi
    fi
fi
