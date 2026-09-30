#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  patch-topbar.py — la barre du haut se cale contre le panneau SUPER+E
#
#  Quand le panneau système est ouvert (état « sys »), Serpantinum tasse
#  tous les modules à gauche. Ce patch fait à la place :
#    - horloge recentrée dans l'espace restant
#    - indicateurs (Wi-Fi, BT, batterie…) calés contre le panneau
#
#  Usage :  python3 patch-topbar.py            (applique)
#           python3 patch-topbar.py --restore  (remet l'original)
#  Réglage : SYS_PANEL_RESERVE = place laissée au panneau, en pixels
# ─────────────────────────────────────────────────────────────
import sys, shutil, pathlib

SYS_PANEL_RESERVE = 510

path = pathlib.Path.home() / ".local/share/serpantinum/src/quickshell/bar/TopBar.qml"
backup = path.with_name("TopBar.qml.orig")

if "--restore" in sys.argv:
    if not backup.exists():
        sys.exit("!! Pas de sauvegarde TopBar.qml.orig : rien à restaurer.")
    shutil.copy2(backup, path)
    print("==> TopBar.qml d'origine restauré. Recharge Serpantinum (SUPER + R).")
    sys.exit(0)

src = path.read_text(encoding="utf-8")
if "effMaxRight" in src:
    sys.exit("==> Déjà patché. (--restore pour revenir à l'original)")

edits = [
    # 1. Nouvelle limite droite : le bord gauche du panneau quand il est ouvert
    (
        "    property real rawCNaturalX: {",
        "    // [rotten] Place réservée au panneau SUPER+E : la barre se cale contre lui\n"
        f"    property real sysPanelReserve: {SYS_PANEL_RESERVE}\n"
        "    property real effMaxRight: layoutState === \"sys\" ? (screenMaxRight - sysPanelReserve) : screenMaxRight\n"
        "\n"
        "    property real rawCNaturalX: {",
    ),
    # 2. Horloge : recentrée dans l'espace restant (au lieu d'être tassée à gauche)
    (
        '        if (layoutState === "sys") return screenMinLeft + lWidthTarget + lcGap;',
        '        if (layoutState === "sys") return (effMaxRight - cWidthTarget) / 2;',
    ),
    # 3. Limite droite de l'horloge
    (
        "    property real absMaxC: (rWidthTarget > 0) ? (screenMaxRight - rWidthTarget - crGap - cWidthTarget) : (screenMaxRight - cWidthTarget)",
        "    property real absMaxC: (rWidthTarget > 0) ? (effMaxRight - rWidthTarget - crGap - cWidthTarget) : (effMaxRight - cWidthTarget)",
    ),
    # 4. Indicateurs : calés contre le panneau (au lieu d'être collés à l'horloge)
    (
        "            return Math.min(screenMaxRight - rWidthTarget, cFinalX + cWidthTarget + crGap);",
        "            return effMaxRight - rWidthTarget;",
    ),
]

for old, new in edits:
    n = src.count(old)
    if n != 1:
        sys.exit(f"!! Ligne attendue trouvée {n} fois (au lieu d'une) : Serpantinum a peut-être changé.\n   {old.strip()}\n   Rien n'a été modifié.")
    src = src.replace(old, new)

if not backup.exists():
    shutil.copy2(path, backup)
    print(f"==> Original sauvegardé : {backup.name}")
path.write_text(src, encoding="utf-8")
print("==> TopBar.qml patché. Recharge Serpantinum (SUPER + R) puis ouvre SUPER + E.")
