#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  nebula-colors.sh — "Nebula" KDE color scheme for Dolphin
#  Dolphin picks its own color scheme (light Breeze by default outside
#  Plasma): give it a real one and force it.
#  Usage:  ./nebula-colors.sh   (without sudo)
# ─────────────────────────────────────────────────────────────
set -euo pipefail
[[ $EUID -eq 0 ]] && { echo "!! Run this script without sudo."; exit 1; }

SCHEME_DIR="$HOME/.local/share/color-schemes"
mkdir -p "$SCHEME_DIR"

python3 - "$SCHEME_DIR/Nebula.colors" "$HOME/.config/kdeglobals" "$HOME/.config/dolphinrc" << 'PY'
import configparser, sys, os

scheme_path, kdeglobals, dolphinrc = sys.argv[1:4]

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

def load(path):
    cp = configparser.ConfigParser(interpolation=None, strict=False, delimiters=("=",))
    cp.optionxform = str
    if os.path.exists(path):
        cp.read(path, encoding="utf-8")
    return cp

def fill(cp):
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
    for k, v in common.items():
        cp[sel][k] = v
    cp[sel]["BackgroundNormal"] = cyan
    cp[sel]["BackgroundAlternate"] = "0,151,168"
    cp[sel]["ForegroundNormal"] = night
    cp[sel]["ForegroundActive"] = night

def save(cp, path):
    with open(path, "w", encoding="utf-8") as fh:
        cp.write(fh, space_around_delimiters=False)

# 1. The color scheme file
scheme = load(scheme_path)
fill(scheme)
for sec in ("General", "ColorEffects:Disabled", "ColorEffects:Inactive"):
    if not scheme.has_section(sec):
        scheme.add_section(sec)
scheme["General"]["Name"] = "Nebula"
scheme["General"]["ColorScheme"] = "Nebula"
scheme["ColorEffects:Inactive"]["Enable"] = "false"   # no dimming of inactive windows
save(scheme, scheme_path)

# 2. kdeglobals: Nebula as the system color scheme
kg = load(kdeglobals)
fill(kg)
if not kg.has_section("General"):
    kg.add_section("General")
kg["General"]["ColorScheme"] = "Nebula"
save(kg, kdeglobals)

# 3. dolphinrc: force Nebula in Dolphin
dr = load(dolphinrc)
if not dr.has_section("UiSettings"):
    dr.add_section("UiSettings")
dr["UiSettings"]["ColorScheme"] = "Nebula"
save(dr, dolphinrc)
PY
echo "==> Nebula color scheme created and forced in Dolphin"

# 4. "Dark" preference for apps that ask the system
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null \
    && echo "==> System preference: dark"

echo "Restart Dolphin to see the result."
