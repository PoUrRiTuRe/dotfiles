#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  backup-rice.sh — sauvegarde complète du setup Hyprland (v2)
#  Usage : ./backup-rice.sh
#  Résultat : ~/dotfiles-backup, puis commit + push GitHub (optionnel)
# ─────────────────────────────────────────────────────────────
set -uo pipefail

DEST="$HOME/dotfiles-backup"
DATE="$(date '+%Y-%m-%d %H:%M')"
# Nom de la machine (rotten-laptop, rotten-desktop…) : les fichiers système
# et la liste des paquets sont rangés dans system/<machine>/ et packages/<machine>/
HOST="$(cat /etc/hostname 2>/dev/null || uname -n)"
SYS="$DEST/system/$HOST"
PKG="$DEST/packages/$HOST"

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

echo "==> Sauvegarde dans $DEST (machine : $HOST)"
mkdir -p "$DEST/home" "$SYS" "$PKG"

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
    sudo mkdir -p "$SYS/$(dirname "$rel")"
    sudo rm -rf "${SYS:?}/$rel"
    sudo cp -a "$src" "$SYS/$rel"
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
    "$HOME/.config/eza"               # couleurs de ls (eza)
    "$HOME/.config/nvim"              # LazyVim
    "$HOME/.config/nano"              # couleurs de nano
    "$HOME/.config/environment.d"     # variables de session (GTK_THEME…)
    "$HOME/.local/share/applications" # raccourcis du lanceur (Neovim dans kitty…)
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
    "$HOME/.local/share/icons/ChromaS"    # ancien curseur Chroma S (croix de précision)
    "$HOME/.local/share/icons/Bibata-Nebula-Cross" # curseur actuel : Bibata noir + croix
    "$HOME/Pictures/Wallpapers"
)
for item in "${HOME_ITEMS[@]}"; do
    save_home "$item"
done

# Réglages de Serpantinum (veille, barre, thème…) SANS la position
# (adresse IP, coordonnées GPS, code postal utilisés pour la météo)
SERP_SETTINGS="$HOME/.config/serpantinum/settings.json"
if [[ -f "$SERP_SETTINGS" ]]; then
    mkdir -p "$DEST/home/.config/serpantinum"
    python3 - "$SERP_SETTINGS" "$DEST/home/.config/serpantinum/settings.json" << 'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
data.get("general", {}).pop("location", None)
json.dump(data, open(sys.argv[2], "w", encoding="utf-8"), indent=2, ensure_ascii=False)
PY
    echo "   ok  $SERP_SETTINGS (sans la position)"
fi

# ── 2. Fichiers système modifiés ─────────────────────────────
echo "==> Fichiers système (mot de passe ou empreinte demandé)"
SYSTEM_ITEMS=(
    "/etc/pam.d/sddm"                 # login mot de passe puis empreinte
    "/etc/pam.d/sudo"                 # sudo avec empreinte
    "/etc/pam.d/serpantinum-fprint"   # empreinte sur l'écran de verrouillage (SUPER + L)
    "/etc/sddm.conf.d"                # thème SDDM actif (nebula)
    "/usr/share/sddm/themes/nebula"   # le thème nebula
    "/var/lib/bluetooth"              # appairages Bluetooth (casque WH-1000XM4, clavier Lily58)
    "/etc/systemd/logind.conf.d"      # capot / touche veille : pas de veille sur secteur
    "/usr/local/bin/suspend-hyprland.sh"           # gèle Hyprland pendant la veille (NVIDIA)
    "/etc/systemd/system/hyprland-suspend.service"
    "/etc/systemd/system/hyprland-resume.service"
)
for item in "${SYSTEM_ITEMS[@]}"; do
    save_system "$item"
done
sudo chown -R "$USER:$USER" "$SYS"
# Le cache Bluetooth liste tous les appareils croisés (voisins, téléphones...) :
# inutile, on ne garde que les appairages
rm -rf "$SYS"/var/lib/bluetooth/*/cache

# ── 3. Liste des paquets ─────────────────────────────────────
echo "==> Liste des paquets"
pacman -Qqen > "$PKG/pacman.txt"   # dépôts officiels
pacman -Qqem > "$PKG/aur.txt"      # AUR / hors dépôts

# Réglages qui ne sont pas des fichiers : services activés et gsettings
systemctl list-unit-files --state=enabled --no-legend > "$PKG/services-system.txt"
systemctl --user list-unit-files --state=enabled --no-legend > "$PKG/services-user.txt"
gsettings list-recursively org.gnome.desktop.interface > "$PKG/gsettings-interface.txt" 2>/dev/null
echo "   ok  services activés + gsettings"
echo "   ok  $(wc -l < "$PKG/pacman.txt") officiels, $(wc -l < "$PKG/aur.txt") AUR"

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
