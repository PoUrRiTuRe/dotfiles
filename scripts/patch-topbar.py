#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  patch-topbar.py — the top bar lines up against the SUPER+E panel
#
#  When the system panel is open ("sys" state), Serpantinum packs every
#  module to the left. Instead, this patch:
#    - re-centers the clock in the remaining space
#    - lines the indicators (Wi-Fi, BT, battery…) up against the panel
#
#  Usage:  python3 patch-topbar.py            (apply)
#          python3 patch-topbar.py --restore  (restore the original)
#  Setting: SYS_PANEL_RESERVE = space left for the panel, in pixels
# ─────────────────────────────────────────────────────────────
import sys, shutil, pathlib

SYS_PANEL_RESERVE = 510

path = pathlib.Path.home() / ".local/share/serpantinum/src/quickshell/bar/TopBar.qml"
backup = path.with_name("TopBar.qml.orig")

if "--restore" in sys.argv:
    if not backup.exists():
        sys.exit("!! No TopBar.qml.orig backup: nothing to restore.")
    shutil.copy2(backup, path)
    print("==> Original TopBar.qml restored. Reload Serpantinum (SUPER + R).")
    sys.exit(0)

src = path.read_text(encoding="utf-8")
if "effMaxRight" in src:
    sys.exit("==> Already patched. (--restore to go back to the original)")

edits = [
    # 1. New right limit: the left edge of the panel when it is open
    (
        "    property real rawCNaturalX: {",
        "    // [nebula] Space reserved for the SUPER+E panel: the bar lines up against it\n"
        f"    property real sysPanelReserve: {SYS_PANEL_RESERVE}\n"
        "    property real effMaxRight: layoutState === \"sys\" ? (screenMaxRight - sysPanelReserve) : screenMaxRight\n"
        "\n"
        "    property real rawCNaturalX: {",
    ),
    # 2. Clock: re-centered in the remaining space (instead of packed to the left)
    (
        '        if (layoutState === "sys") return screenMinLeft + lWidthTarget + lcGap;',
        '        if (layoutState === "sys") return (effMaxRight - cWidthTarget) / 2;',
    ),
    # 3. Right limit of the clock
    (
        "    property real absMaxC: (rWidthTarget > 0) ? (screenMaxRight - rWidthTarget - crGap - cWidthTarget) : (screenMaxRight - cWidthTarget)",
        "    property real absMaxC: (rWidthTarget > 0) ? (effMaxRight - rWidthTarget - crGap - cWidthTarget) : (effMaxRight - cWidthTarget)",
    ),
    # 4. Indicators: lined up against the panel (instead of stuck to the clock)
    (
        "            return Math.min(screenMaxRight - rWidthTarget, cFinalX + cWidthTarget + crGap);",
        "            return effMaxRight - rWidthTarget;",
    ),
]

for old, new in edits:
    n = src.count(old)
    if n != 1:
        sys.exit(f"!! Expected line found {n} times (instead of once): Serpantinum may have changed.\n   {old.strip()}\n   Nothing was modified.")
    src = src.replace(old, new)

if not backup.exists():
    shutil.copy2(path, backup)
    print(f"==> Original saved: {backup.name}")
path.write_text(src, encoding="utf-8")
print("==> TopBar.qml patched. Reload Serpantinum (SUPER + R), then open SUPER + E.")
