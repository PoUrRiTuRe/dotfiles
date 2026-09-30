#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  nebula-colors.sh — jeu de couleurs KDE « Nebula » pour Dolphin
#  Dolphin choisit lui-même un jeu de couleurs (Breeze clair par défaut
#  hors de Plasma) : on lui en donne un vrai, et on le lui impose.
#  Usage : ./nebula-colors.sh   (sans sudo)
# ─────────────────────────────────────────────────────────────
set -euo pipefail
[[ $EUID -eq 0 ]] && { echo "!! Lance ce script sans sudo."; exit 1; }

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

# 1. Le fichier de jeu de couleurs
scheme = load(scheme_path)
fill(scheme)
for sec in ("General", "ColorEffects:Disabled", "ColorEffects:Inactive"):
    if not scheme.has_section(sec):
        scheme.add_section(sec)
scheme["General"]["Name"] = "Nebula"
scheme["General"]["ColorScheme"] = "Nebula"
scheme["ColorEffects:Inactive"]["Enable"] = "false"   # pas d'assombrissement des fenêtres inactives
save(scheme, scheme_path)

# 2. kdeglobals : Nebula comme jeu de couleurs du système
kg = load(kdeglobals)
fill(kg)
if not kg.has_section("General"):
    kg.add_section("General")
kg["General"]["ColorScheme"] = "Nebula"
save(kg, kdeglobals)

# 3. dolphinrc : impose Nebula à Dolphin
dr = load(dolphinrc)
if not dr.has_section("UiSettings"):
    dr.add_section("UiSettings")
dr["UiSettings"]["ColorScheme"] = "Nebula"
save(dr, dolphinrc)
PY
echo "==> Jeu de couleurs Nebula créé et imposé à Dolphin"

# 4. Préférence « sombre » pour les applis qui la demandent au système
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null \
    && echo "==> Préférence système : sombre"

echo "Relance Dolphin pour voir le résultat."
