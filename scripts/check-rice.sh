#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  check-rice.sh — check-up after a Serpantinum update (or any update)
#  Looks for everything an update is known to reset and says how to fix it:
#    - Hyprland config replaced (monitors per machine, keybinds…)
#    - Serpantinum code patches gone (top bar, lock screen fingerprint)
#    - SDDM greeter switched back to material-you
#    - Serpantinum settings changed (Quick Actions, bar, idle)
#    - kitty / fastfetch / cava configs replaced
#    - cursor theme out of sync, kernel updated without a reboot
#  Usage:  ~/check-rice.sh          (report only, changes nothing)
#          ~/check-rice.sh --fix    (also re-applies the user-level patches)
#  Without sudo: system fixes are printed as commands to run.
# ─────────────────────────────────────────────────────────────
set -uo pipefail

REPO="$HOME/dotfiles-backup"
HOST="$(cat /etc/hostname 2>/dev/null || uname -n)"
SERP="$HOME/.local/share/serpantinum/src/quickshell"
FIX=false
[[ "${1:-}" == "--fix" ]] && FIX=true

[[ $EUID -eq 0 ]] && { echo "!! Run this script without sudo."; exit 1; }
[[ -d "$REPO" ]] || { echo "!! Repository not found: $REPO"; exit 1; }

PROBLEMS=0
ok()   { echo "   ok  $1"; }
warn() { echo "   !!  $1"; PROBLEMS=$((PROBLEMS + 1)); }
hint() { echo "       → $1"; }

# Patch script: the copy in ~ (installed by save-all.sh), else the repository one
patch_script() {
    if [[ -f "$HOME/$1" ]]; then echo "$HOME/$1"; else echo "$REPO/scripts/$1"; fi
}

# ── 1. Machine and Hyprland config ───────────────────────────
echo "==> Machine: $HOST"
HYPR="$HOME/.config/hypr"
if [[ -f "$HYPR/config/hosts/$HOST.lua" ]]; then
    ok "monitor file config/hosts/$HOST.lua"
else
    warn "no config/hosts/$HOST.lua: monitors fall back to automatic (60 Hz, random layout)"
    hint "hostname changed? sudo hostnamectl set-hostname <rotten-laptop|rotten-desktop>"
fi

echo "==> Hyprland config"
if grep -q 'config/hosts/' "$HYPR/config/monitors.lua" 2>/dev/null; then
    ok "monitors.lua loads the machine file"
else
    warn "monitors.lua is not ours (replaced by an install / reinstall?)"
fi
if grep -q 'hl.dsp.focus({ workspace = i })' "$HYPR/config/keybinds.lua" 2>/dev/null; then
    ok "keybinds.lua: native workspace keys"
else
    warn "keybinds.lua is not ours (replaced by an install / reinstall?)"
fi
if grep -q 'hyprland-gui' "$HYPR/hyprland.lua" 2>/dev/null; then
    warn "hyprland.lua loads hyprland-gui.lua (GUI tool): it overrides the monitors"
fi
DIFF=$(diff -rq "$REPO/home/.config/hypr" "$HYPR" 2>/dev/null | head -10)
if [[ -z "$DIFF" ]]; then
    ok "~/.config/hypr identical to the repository"
else
    warn "~/.config/hypr differs from the repository:"
    printf '        %s\n' "$DIFF"
    hint "compare: diff -ru $REPO/home/.config/hypr ~/.config/hypr"
    hint "restore: cp -a $REPO/home/.config/hypr/. ~/.config/hypr/ && hyprctl reload"
    [[ -d "$HOME/.config/hypr_backup" ]] && hint "the installer's backup is in ~/.config/hypr_backup/"
fi
if command -v hyprctl >/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    ERRORS=$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d')
    if [[ -z "$ERRORS" || "$ERRORS" == *"no errors"* ]]; then
        ok "no Hyprland config errors"
    else
        warn "Hyprland config errors:"
        printf '        %s\n' "$ERRORS"
    fi
    echo "   ..  monitors: $(hyprctl monitors 2>/dev/null | awk '/^Monitor /{n=$2} /^\t[0-9]+x[0-9]+@/{printf "%s %s  ", n, $1}')"
fi

# ── 2. Serpantinum ───────────────────────────────────────────
echo "==> Serpantinum"
VERSION=$(grep -h '^SERPANTINUM_VERSION=' "$HOME/.local/state/serpantinum/version" 2>/dev/null | cut -d= -f2 | tr -d '"')
echo "   ..  version: ${VERSION:-unknown}"

if [[ ! -d "$SERP" ]]; then
    warn "Serpantinum not found in ~/.local/share/serpantinum"
else
    if grep -q 'effMaxRight' "$SERP/bar/TopBar.qml" 2>/dev/null; then
        ok "top bar patch (patch-topbar.py)"
    else
        warn "top bar patch missing (reset by the update)"
        if $FIX; then
            python3 "$(patch_script patch-topbar.py)"
        else
            hint "python3 $(patch_script patch-topbar.py)"
        fi
    fi

    # Lock screen fingerprint: only on machines with the fingerprint PAM file
    if [[ -f /etc/pam.d/serpantinum-fprint ]]; then
        if grep -q 'fprintPam' "$SERP/lock/Lock.qml" 2>/dev/null; then
            ok "lock screen fingerprint patch (patch-lock.py)"
        else
            warn "lock screen fingerprint patch missing (reset by the update)"
            if $FIX; then
                python3 "$(patch_script patch-lock.py)"
            else
                hint "python3 $(patch_script patch-lock.py)"
            fi
        fi
    fi
fi

# Settings that matter, compared with the repository copy (location excluded)
SETTINGS="$HOME/.config/serpantinum/settings.json"
if [[ -f "$SETTINGS" && -f "$REPO/home/.config/serpantinum/settings.json" ]]; then
    python3 - "$SETTINGS" "$REPO/home/.config/serpantinum/settings.json" << 'PY'
import json, sys
local = json.load(open(sys.argv[1], encoding="utf-8"))
repo = json.load(open(sys.argv[2], encoding="utf-8"))
gen = local.get("general", {})
problems = []
if gen.get("quickactions", True) is not False:
    problems.append("Quick Actions is enabled again (edge panel over games): SUPER + H > General > Quickactions")
for section in ("bar", "idle"):
    if section in repo and local.get(section) != repo.get(section):
        problems.append(f'"{section}" differs from the repository (reset, or changed on purpose?)')
if problems:
    for p in problems:
        print(f"   !!  settings.json: {p}")
    sys.exit(1)
print("   ok  settings.json (Quick Actions off, bar and idle as in the repository)")
PY
    [[ $? -ne 0 ]] && PROBLEMS=$((PROBLEMS + 1))
fi

# kitty / fastfetch / cava: replaced by an install / reinstall
for cfg in kitty fastfetch cava; do
    [[ -d "$REPO/home/.config/$cfg" ]] || continue
    if diff -rq "$REPO/home/.config/$cfg" "$HOME/.config/$cfg" >/dev/null 2>&1; then
        ok "$cfg config"
    else
        warn "$cfg config differs from the repository"
        hint "diff -ru $REPO/home/.config/$cfg ~/.config/$cfg"
    fi
done

# ── 3. SDDM greeter ──────────────────────────────────────────
echo "==> SDDM greeter"
CURRENT=$(grep -h '^Current=' /etc/sddm.conf /etc/sddm.conf.d/*.conf 2>/dev/null | tail -1 | cut -d= -f2)
if [[ "$CURRENT" == "nebula" ]]; then
    ok "theme: nebula"
else
    warn "theme: ${CURRENT:-default} instead of nebula (the installer's SDDM option resets it)"
    hint "sudo sed -i 's/^Current=.*/Current=nebula/' /etc/sddm.conf.d/10-material-you.conf"
fi
if [[ ! -d /usr/share/sddm/themes/nebula ]]; then
    warn "/usr/share/sddm/themes/nebula is missing"
    hint "sudo cp -a $REPO/system/$HOST/usr/share/sddm/themes/nebula /usr/share/sddm/themes/"
elif [[ -f /etc/pam.d/serpantinum-fprint ]] && ! grep -q 'fpState' /usr/share/sddm/themes/nebula/Main.qml 2>/dev/null; then
    warn "greeter fingerprint animation missing"
    hint "sudo python3 $(patch_script patch-greeter.py)"
fi

# ── 4. Cursor (must be the same everywhere) ──────────────────
echo "==> Cursor"
CURSOR_OK=true
grep -q '"XCURSOR_THEME", "ChromaS"' "$HYPR/config/env.lua" 2>/dev/null || { warn "env.lua: XCURSOR_THEME is not ChromaS"; CURSOR_OK=false; }
grep -q 'XCURSOR_THEME=ChromaS' "$HOME/.config/environment.d/cursor.conf" 2>/dev/null || { warn "environment.d/cursor.conf: not ChromaS"; CURSOR_OK=false; }
grep -q 'Inherits=ChromaS' "$HOME/.icons/default/index.theme" 2>/dev/null || { warn "~/.icons/default/index.theme: not ChromaS"; CURSOR_OK=false; }
if command -v gsettings >/dev/null; then
    GS=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null)
    if [[ -n "$GS" && "$GS" != "'ChromaS'" ]]; then
        warn "gsettings cursor-theme is $GS"
        hint "gsettings set org.gnome.desktop.interface cursor-theme 'ChromaS'"
        CURSOR_OK=false
    fi
fi
$CURSOR_OK && ok "ChromaS everywhere"

# ── 5. Kernel ────────────────────────────────────────────────
echo "==> Kernel"
if [[ -d "/usr/lib/modules/$(uname -r)" ]]; then
    ok "running kernel $(uname -r) has its modules"
else
    warn "kernel updated without a reboot: modules of $(uname -r) are gone (VPN, USB drives… can fail)"
    hint "reboot"
fi

# ── Summary ──────────────────────────────────────────────────
echo
if (( PROBLEMS == 0 )); then
    echo "==> All good."
else
    echo "==> $PROBLEMS problem(s) found. Fix them, then run ~/save-all.sh."
    $FIX && echo "    (--fix re-applied the user-level patches: reload Serpantinum with SUPER + R)"
fi
(( PROBLEMS == 0 ))
