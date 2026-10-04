#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  save-all.sh — one-command backup
#   1. pull changes from GitHub (including the other machine's)
#      and install them into ~ (config + scripts)
#   2. move downloaded files (scripts, README…) to their place
#   3. copy the scripts from ~ into the repository (scripts/)
#   4. run backup-rice.sh (answer "y" at the end to push)
#  Usage:  ~/save-all.sh   (without sudo)
# ─────────────────────────────────────────────────────────────
set -uo pipefail

REPO="$HOME/dotfiles-backup"
HOST="$(cat /etc/hostname 2>/dev/null || uname -n)"
DL="$HOME/Downloads"
SCRIPTS=(backup-rice.sh save-all.sh patch-lock.py patch-greeter.py patch-topbar.py
         kde-cleanup-preview.sh nebula-kvantum.sh nebula-colors.sh)

[[ $EUID -eq 0 ]] && { echo "!! Run this script without sudo."; exit 1; }
cd "$REPO" || { echo "!! Repository not found: $REPO"; exit 1; }

# Replace a file by copy + rename: the running file (save-all.sh itself)
# is never modified in place
install_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst.tmp-save-all" && mv -f "$dst.tmp-save-all" "$dst"
}

# Install a file from the repository into ~, unless it was modified here
# since the last backup (with two machines, nothing is silently overwritten)
#   $1 = path in the repository, $2 = destination
install_from_repo() {
    local f="$1" dst="$2"
    if [[ -e "$dst" ]] && ! cmp -s "$dst" "$REPO/$f" \
       && ! git show "$BEFORE:$f" 2>/dev/null | cmp -s - "$dst"; then
        echo "   !!  $dst changed here AND on GitHub: kept as is"
        echo "       (GitHub version: $REPO/$f, merge it by hand)"
        return 1
    fi
    install_file "$REPO/$f" "$dst"
}

# ── 1. GitHub first, to avoid conflicts ──────────────────────
echo "==> Pulling changes from GitHub"
BEFORE=$(git rev-parse HEAD)
if ! git pull --rebase; then
    echo "!! git pull failed (conflict?). Nothing else was done."
    exit 1
fi

# Files changed on GitHub (not the ones changed locally)
CHANGED=$(git diff --name-only --diff-filter=AMR "$BEFORE"...@{u} 2>/dev/null)
if [[ -n "$CHANGED" ]]; then
    echo "==> Installing changes from GitHub"
    SYSTEM_CHANGED=()
    while IFS= read -r f; do
        case "$f" in
            # The repository copy has no location: keep the local one
            home/.config/serpantinum/settings.json)
                echo "   !!  $f: apply by hand (the repository copy has no location)" ;;
            home/*)
                install_from_repo "$f" "$HOME/${f#home/}" \
                    && echo "   ok  ~/${f#home/}" ;;
            scripts/*)
                name="${f#scripts/}"
                if [[ " ${SCRIPTS[*]} " == *" $name "* ]]; then
                    install_from_repo "$f" "$HOME/$name" \
                        && chmod +x "$HOME/$name" && echo "   ok  ~/$name"
                fi ;;
            # System files: only the ones for this machine
            system/"$HOST"/*)
                SYSTEM_CHANGED+=("/${f#system/"$HOST"/}") ;;
        esac
    done <<< "$CHANGED"
    if (( ${#SYSTEM_CHANGED[@]} )); then
        echo "   !!  System files changed (copy them with sudo, see the README):"
        printf '        %s\n' "${SYSTEM_CHANGED[@]}"
    fi
fi

# ── 2. Downloaded files → their place ────────────────────────
echo "==> Moving downloaded files"
for f in "${SCRIPTS[@]}"; do
    if [[ -f "$DL/$f" ]]; then
        mv "$DL/$f" "$HOME/$f"
        echo "   ok  $f → ~/"
    fi
done
chmod +x "$HOME"/*.sh 2>/dev/null

for f in README.md ROADMAP.md CLAUDE.md; do
    if [[ -f "$DL/$f" ]]; then
        mv "$DL/$f" "$REPO/$f"
        echo "   ok  $f → repository"
    fi
done

# ── 3. Scripts → scripts/ in the repository ──────────────────
echo "==> Copying scripts into the repository"
mkdir -p "$REPO/scripts"
for f in "${SCRIPTS[@]}"; do
    [[ -f "$HOME/$f" ]] && cp "$HOME/$f" "$REPO/scripts/" && echo "   ok  $f"
done

# ── 4. Full backup (commit + push at the end) ────────────────
echo "==> Running backup-rice.sh"
"$HOME/backup-rice.sh"

# ── Check ────────────────────────────────────────────────────
echo
echo "==> Final state"
git -C "$REPO" log --oneline -1
git -C "$REPO" status -sb | head -1
