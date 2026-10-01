#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  save-all.sh — sauvegarde en une commande
#   1. récupère les éventuelles modifs de GitHub
#   2. range les fichiers téléchargés depuis Claude (scripts, README…)
#   3. copie tes scripts dans le dépôt (dossier scripts/)
#   4. lance backup-rice.sh (réponds « o » à la fin pour envoyer)
#  Usage : ~/save-all.sh   (sans sudo)
# ─────────────────────────────────────────────────────────────
set -uo pipefail

REPO="$HOME/dotfiles-backup"
DL="$HOME/Downloads"

[[ $EUID -eq 0 ]] && { echo "!! Lance ce script sans sudo."; exit 1; }
cd "$REPO" || { echo "!! Dépôt introuvable : $REPO"; exit 1; }

# ── 1. GitHub d'abord, pour éviter les conflits ──────────────
echo "==> Récupération des modifs de GitHub"
if ! git pull --rebase; then
    echo "!! git pull a échoué (conflit ?). Rien d'autre n'a été fait."
    exit 1
fi

# ── 2. Fichiers téléchargés → leur place ─────────────────────
echo "==> Rangement des fichiers téléchargés"
for f in backup-rice.sh save-all.sh patch-lock.py patch-greeter.py patch-topbar.py \
         menage-apercu.sh nebula-kvantum.sh nebula-colors.sh; do
    if [[ -f "$DL/$f" ]]; then
        mv "$DL/$f" "$HOME/$f"
        echo "   ok  $f → ~/"
    fi
done
chmod +x "$HOME"/*.sh 2>/dev/null

for f in README.md feuille-de-route-rice.md; do
    if [[ -f "$DL/$f" ]]; then
        mv "$DL/$f" "$REPO/$f"
        echo "   ok  $f → dépôt"
    fi
done

# ── 3. Scripts → dossier scripts/ du dépôt ───────────────────
echo "==> Copie des scripts dans le dépôt"
mkdir -p "$REPO/scripts"
for f in backup-rice.sh save-all.sh patch-lock.py patch-greeter.py patch-topbar.py \
         menage-apercu.sh nebula-kvantum.sh nebula-colors.sh; do
    [[ -f "$HOME/$f" ]] && cp "$HOME/$f" "$REPO/scripts/" && echo "   ok  $f"
done

# ── 4. La sauvegarde complète (commit + push à la fin) ───────
echo "==> Lancement de backup-rice.sh"
"$HOME/backup-rice.sh"

# ── Vérification ─────────────────────────────────────────────
echo
echo "==> État final"
git -C "$REPO" log --oneline -1
git -C "$REPO" status -sb | head -1
