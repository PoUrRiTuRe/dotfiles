#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  save-all.sh — sauvegarde en une commande
#   1. récupère les modifs de GitHub (celles de Claude Code compris)
#      et les installe dans ~ (config + scripts)
#   2. range les fichiers téléchargés depuis Claude (scripts, README…)
#   3. copie tes scripts dans le dépôt (dossier scripts/)
#   4. lance backup-rice.sh (réponds « o » à la fin pour envoyer)
#  Usage : ~/save-all.sh   (sans sudo)
# ─────────────────────────────────────────────────────────────
set -uo pipefail

REPO="$HOME/dotfiles-backup"
HOST="$(cat /etc/hostname 2>/dev/null || uname -n)"
DL="$HOME/Downloads"
SCRIPTS=(backup-rice.sh save-all.sh patch-lock.py patch-greeter.py patch-topbar.py
         menage-apercu.sh nebula-kvantum.sh nebula-colors.sh)

[[ $EUID -eq 0 ]] && { echo "!! Lance ce script sans sudo."; exit 1; }
cd "$REPO" || { echo "!! Dépôt introuvable : $REPO"; exit 1; }

# Remplace un fichier par copie + renommage : le fichier en cours
# d'exécution (save-all.sh lui-même) n'est jamais modifié sur place
install_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst.tmp-save-all" && mv -f "$dst.tmp-save-all" "$dst"
}

# Installe un fichier du dépôt dans ~, sauf si tu l'as modifié ici depuis
# la dernière sauvegarde (utile avec deux PC : rien n'est écrasé en douce)
#   $1 = chemin dans le dépôt, $2 = destination
install_from_repo() {
    local f="$1" dst="$2"
    if [[ -e "$dst" ]] && ! cmp -s "$dst" "$REPO/$f" \
       && ! git show "$BEFORE:$f" 2>/dev/null | cmp -s - "$dst"; then
        echo "   !!  $dst modifié ici ET sur GitHub : gardé tel quel"
        echo "       (version GitHub : $REPO/$f, à fusionner à la main)"
        return 1
    fi
    install_file "$REPO/$f" "$dst"
}

# ── 1. GitHub d'abord, pour éviter les conflits ──────────────
echo "==> Récupération des modifs de GitHub"
BEFORE=$(git rev-parse HEAD)
if ! git pull --rebase; then
    echo "!! git pull a échoué (conflit ?). Rien d'autre n'a été fait."
    exit 1
fi

# Fichiers changés sur GitHub (pas ceux que tu as modifiés ici)
CHANGED=$(git diff --name-only --diff-filter=AMR "$BEFORE"...@{u} 2>/dev/null)
if [[ -n "$CHANGED" ]]; then
    echo "==> Installation des modifs venues de GitHub"
    SYSTEM_CHANGED=()
    while IFS= read -r f; do
        case "$f" in
            # La copie du dépôt n'a pas la position : on garde la tienne
            home/.config/serpantinum/settings.json)
                echo "   !!  $f : à reporter à la main (le dépôt n'a pas ta position)" ;;
            home/*)
                install_from_repo "$f" "$HOME/${f#home/}" \
                    && echo "   ok  ~/${f#home/}" ;;
            scripts/*)
                name="${f#scripts/}"
                if [[ " ${SCRIPTS[*]} " == *" $name "* ]]; then
                    install_from_repo "$f" "$HOME/$name" \
                        && chmod +x "$HOME/$name" && echo "   ok  ~/$name"
                fi ;;
            # Fichiers système : seulement ceux de cette machine
            system/"$HOST"/*)
                SYSTEM_CHANGED+=("/${f#system/"$HOST"/}") ;;
        esac
    done <<< "$CHANGED"
    if (( ${#SYSTEM_CHANGED[@]} )); then
        echo "   !!  Fichiers système changés (à copier avec sudo, voir la conversation) :"
        printf '        %s\n' "${SYSTEM_CHANGED[@]}"
    fi
fi

# ── 2. Fichiers téléchargés → leur place ─────────────────────
echo "==> Rangement des fichiers téléchargés"
for f in "${SCRIPTS[@]}"; do
    if [[ -f "$DL/$f" ]]; then
        mv "$DL/$f" "$HOME/$f"
        echo "   ok  $f → ~/"
    fi
done
chmod +x "$HOME"/*.sh 2>/dev/null

for f in README.md feuille-de-route-rice.md CLAUDE.md; do
    if [[ -f "$DL/$f" ]]; then
        mv "$DL/$f" "$REPO/$f"
        echo "   ok  $f → dépôt"
    fi
done

# ── 3. Scripts → dossier scripts/ du dépôt ───────────────────
echo "==> Copie des scripts dans le dépôt"
mkdir -p "$REPO/scripts"
for f in "${SCRIPTS[@]}"; do
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
