#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  nebula-kvantum.sh — creates the "Nebula" Kvantum theme
#  (based on KvArcDark) and enables it for Qt apps (Dolphin…)
#  Usage:  ./nebula-kvantum.sh   (without sudo)
# ─────────────────────────────────────────────────────────────
set -euo pipefail

BASE="/usr/share/Kvantum/KvArcDark"
DEST="$HOME/.config/Kvantum/Nebula"
CONF="$DEST/Nebula.kvconfig"
SVG="$DEST/Nebula.svg"

[[ $EUID -eq 0 ]] && { echo "!! Run this script without sudo."; exit 1; }
[[ -d "$BASE" ]] || { echo "!! $BASE not found (is kvantum installed?)"; exit 1; }

# ── 1. Copy the base theme ───────────────────────────────────
mkdir -p "$DEST"
cp "$BASE/KvArcDark.kvconfig" "$CONF"
cp "$BASE/KvArcDark.svg" "$SVG"
echo "==> Base theme copied"

# ── 2. Nebula palette (replaces the Arc Dark colors) ─────────
#   Arc Dark   → Nebula
#   #2f343f    → #0d0b1f  deep night blue (bars, dark backgrounds)
#   #383c4a    → #12102a  window background
#   #404552    → #1a1638  content areas (file lists)
#   #4b5162    → #2a2360  buttons, borders
#   #5294e2    → #00e5ff  accent / selection (cyan)
#   #d3dae3    → #ffffff  text (pure white)
#   + Arc's remaining blue-greys → night purples, #58acff → light cyan
for f in "$CONF" "$SVG"; do
    sed -i \
        -e 's/#2f343f/#0d0b1f/gI' \
        -e 's/#383c4a/#12102a/gI' \
        -e 's/#404552/#1a1638/gI' \
        -e 's/#4b5162/#2a2360/gI' \
        -e 's/#5294e2/#00e5ff/gI' \
        -e 's/#d3dae3/#ffffff/gI' \
        -e 's/#22252e/#0f0d24/gI' \
        -e 's/#2d303b/#14112e/gI' \
        -e 's/#111217/#08071a/gI' \
        -e 's/#343844/#1a1638/gI' \
        -e 's/#3c404e/#1f1a45/gI' \
        -e 's/#444a58/#262052/gI' \
        -e 's/#474d5d/#2a2360/gI' \
        -e 's/#4d5367/#2f2868/gI' \
        -e 's/#505666/#332b70/gI' \
        -e 's/#92959d/#8f86b8/gI' \
        -e 's/#58acff/#5cf0ff/gI' \
        "$f"
done
echo "==> Nebula colors applied"

# Set a key in a section of the .kvconfig (created if missing)
set_key() {
    local section="$1" key="$2" value="$3"
    awk -v s="[$section]" -v k="$key" -v v="$value" '
        BEGIN { insec=0; done=0 }
        /^\[/ {
            if (insec && !done) { print k "=" v; done=1 }
            insec = ($0 == s)
        }
        insec && $0 ~ "^" k "=" { if (!done) { print k "=" v; done=1 }; next }
        { print }
        END {
            if (!done) {
                if (!insec) print "\n" s
                print k "=" v
            }
        }' "$CONF" > "$CONF.tmp" && mv "$CONF.tmp" "$CONF"
}

# ── 3. Transparency (Hyprland blurs the background) ──────────
set_key "%General" "composite" "true"
set_key "%General" "translucent_windows" "true"
set_key "%General" "reduce_window_opacity" "18"
set_key "%General" "reduce_menu_opacity" "10"
set_key "%General" "transparent_dolphin_view" "true"
set_key "%General" "blurring" "false"          # blur is done by Hyprland
set_key "%General" "popup_blurring" "false"

# ── 4. General colors (text, selection, links) ───────────────
set_key "GeneralColors" "window.color" "#12102a"
set_key "GeneralColors" "base.color" "#1a1638"
set_key "GeneralColors" "alt.base.color" "#161330"
set_key "GeneralColors" "button.color" "#2a2360"
set_key "GeneralColors" "text.color" "#ffffff"
set_key "GeneralColors" "window.text.color" "#ffffff"
set_key "GeneralColors" "button.text.color" "#ffffff"
set_key "GeneralColors" "disabled.text.color" "#6f6a8f"
set_key "GeneralColors" "highlight.color" "#00e5ff"
set_key "GeneralColors" "inactive.highlight.color" "#0097a8"
set_key "GeneralColors" "highlight.text.color" "#0d0b1f"
set_key "GeneralColors" "link.color" "#ff2bd6"
set_key "GeneralColors" "link.visited.color" "#b8a8ff"
set_key "GeneralColors" "progress.indicator.text.color" "#0d0b1f"
echo "==> Transparency and colors set"

# ── 5. Enable Nebula in Kvantum ──────────────────────────────
mkdir -p "$HOME/.config/Kvantum"
printf '[General]\ntheme=Nebula\n' > "$HOME/.config/Kvantum/kvantum.kvconfig"

# ── 6. qt6ct: Kvantum style + dark Breeze icons ──────────────
mkdir -p "$HOME/.config/qt6ct"
cat > "$HOME/.config/qt6ct/qt6ct.conf" << 'EOF'
[Appearance]
custom_palette=false
icon_theme=breeze-dark
standard_dialogs=default
style=kvantum

[Interface]
activate_item_on_single_click=1
EOF
echo "==> Kvantum + qt6ct configured"

# ── 7. KDE colors (kdeglobals) ───────────────────────────────
# Dolphin takes part of its colors (file names, side panel, status bar)
# from ~/.config/kdeglobals, not from Kvantum.
KDEG="$HOME/.config/kdeglobals"
[[ -f "$KDEG" && ! -f "$KDEG.bak" ]] && cp "$KDEG" "$KDEG.bak" && echo "   (sauvegarde : kdeglobals.bak)"
python3 - "$KDEG" << 'PY'
import configparser, sys, os
path = sys.argv[1]
cp = configparser.ConfigParser(interpolation=None, strict=False, delimiters=("=",))
cp.optionxform = str
if os.path.exists(path):
    cp.read(path, encoding="utf-8")

night, window, view, alt = "13,11,31", "18,16,42", "26,22,56", "22,19,48"
button, white, lav = "42,35,96", "255,255,255", "184,168,255"
cyan, magenta = "0,229,255", "255,43,214"
common = {
    "ForegroundNormal": white, "ForegroundInactive": lav, "ForegroundActive": cyan,
    "ForegroundLink": magenta, "ForegroundVisited": lav, "ForegroundNegative": "255,56,96",
    "ForegroundNeutral": "255,200,60", "ForegroundPositive": "0,255,150",
    "DecorationFocus": cyan, "DecorationHover": magenta,
}
groups = {
    "Colors:Window": window, "Colors:View": view, "Colors:Button": button,
    "Colors:Header": window, "Colors:Header][Inactive": window,
    "Colors:Tooltip": night, "Colors:Complementary": night,
}
for name, bg in groups.items():
    if not cp.has_section(name):
        cp.add_section(name)
    cp[name]["BackgroundNormal"] = bg
    cp[name]["BackgroundAlternate"] = alt if name == "Colors:View" else bg
    for k, v in common.items():
        cp[name][k] = v
sel = "Colors:Selection"
if not cp.has_section(sel):
    cp.add_section(sel)
cp[sel].update({k: v for k, v in common.items()})
cp[sel]["BackgroundNormal"] = cyan
cp[sel]["BackgroundAlternate"] = "0,151,168"
cp[sel]["ForegroundNormal"] = night
cp[sel]["ForegroundActive"] = night
if not cp.has_section("Icons"):
    cp.add_section("Icons")
cp["Icons"]["Theme"] = "breeze-dark"
with open(path, "w", encoding="utf-8") as fh:
    cp.write(fh, space_around_delimiters=False)
PY
echo "==> KDE colors (kdeglobals) set"

# ── 8. Diagnostics: remaining colors in the SVG ──────────────
echo
echo "==> Most frequent colors in the theme:"
grep -oiE '#[0-9a-f]{6}' "$SVG" | tr 'A-F' 'a-f' | sort | uniq -c | sort -rn | head -15
echo
echo "Restart Dolphin to see the result."
