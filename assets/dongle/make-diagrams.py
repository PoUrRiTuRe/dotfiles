"""Generate the Nebula-style step diagrams of docs/zmk-dongle.md.

Usage: python3 assets/dongle/make-diagrams.py assets/dongle
"""
import os, sys

OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)

W, H = 960, 540
CYAN, MAGENTA, TEXT, DIM, CARD = "#00f0ff", "#e600ff", "#d6def5", "#7d86a8", "#12162e"
FONT = "JetBrains Mono, DejaVu Sans Mono, monospace"


def frame(step, title, body, caption):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" font-family="{FONT}">
  <defs>
    <radialGradient id="g1" cx="85%" cy="0%" r="70%"><stop offset="0" stop-color="{MAGENTA}" stop-opacity=".22"/><stop offset="1" stop-color="{MAGENTA}" stop-opacity="0"/></radialGradient>
    <radialGradient id="g2" cx="0%" cy="100%" r="70%"><stop offset="0" stop-color="{CYAN}" stop-opacity=".18"/><stop offset="1" stop-color="{CYAN}" stop-opacity="0"/></radialGradient>
    <linearGradient id="title" x1="0" x2="1"><stop offset="0" stop-color="{CYAN}"/><stop offset="1" stop-color="{MAGENTA}"/></linearGradient>
    <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="{CYAN}"/></marker>
  </defs>
  <rect width="{W}" height="{H}" fill="#070914"/>
  <rect width="{W}" height="{H}" fill="url(#g1)"/>
  <rect width="{W}" height="{H}" fill="url(#g2)"/>
  <circle cx="58" cy="52" r="26" fill="none" stroke="{MAGENTA}" stroke-width="2.5"/>
  <text x="58" y="61" text-anchor="middle" font-size="26" font-weight="700" fill="{MAGENTA}">{step}</text>
  <text x="100" y="62" font-size="27" font-weight="700" fill="url(#title)" letter-spacing="2">{title}</text>
  <g>{body}</g>
  <rect x="40" y="{H - 78}" width="{W - 80}" height="50" rx="12" fill="{CARD}" stroke="{CYAN}" stroke-opacity=".35"/>
  <text x="{W / 2}" y="{H - 46}" text-anchor="middle" font-size="17" fill="{TEXT}">{caption}</text>
</svg>
'''


def nano(x, y, scale=1.0, label=True):
    """nice!nano v2 seen from above: USB-C on top, two pin rows."""
    w, h = 150 * scale, 300 * scale
    pins = "".join(
        f'<circle cx="{x + 14 * scale}" cy="{y + (40 + i * 20) * scale}" r="{4 * scale}" fill="#c9a227"/>'
        f'<circle cx="{x + w - 14 * scale}" cy="{y + (40 + i * 20) * scale}" r="{4 * scale}" fill="#c9a227"/>'
        for i in range(12))
    out = (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{10 * scale}" fill="#1b1f3d" stroke="{CYAN}" stroke-width="2"/>'
           f'<rect x="{x + w / 2 - 28 * scale}" y="{y - 14 * scale}" width="{56 * scale}" height="{26 * scale}" rx="{8 * scale}" fill="#9aa3c7"/>'
           f'<rect x="{x + w / 2 - 34 * scale}" y="{y + 110 * scale}" width="{68 * scale}" height="{68 * scale}" rx="{6 * scale}" fill="#0b0d1c" stroke="{DIM}"/>'
           f'<text x="{x + w / 2}" y="{y + 150 * scale}" text-anchor="middle" font-size="{12 * scale}" fill="{DIM}">nRF52840</text>'
           + pins)
    if label:
        out += f'<text x="{x + w / 2}" y="{y + h + 28 * scale}" text-anchor="middle" font-size="{16 * scale}" fill="{TEXT}">nice!nano v2</text>'
    return out


def case(x, y, w=210, h=360, open_top=True):
    gap = (f'<rect x="{x + w / 2 - 40}" y="{y - 3}" width="80" height="10" fill="#070914"/>' if open_top else "")
    return (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="22" fill="none" stroke="{MAGENTA}" stroke-width="3" stroke-dasharray="0"/>'
            + gap)


def arrow(x1, y1, x2, y2):
    return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{CYAN}" stroke-width="3" marker-end="url(#arrow)"/>'


def label(x, y, text, color=TEXT, size=16, anchor="start"):
    return f'<text x="{x}" y="{y}" font-size="{size}" fill="{color}" text-anchor="{anchor}">{text}</text>'


def half(x, y, mirror=False, name="LEFT"):
    """Simplified Lily58 half (6x4 keys + thumb row)."""
    keys = []
    for r in range(4):
        for c in range(6):
            kx = x + c * 34
            ky = y + r * 34 + (abs((5 - c) if mirror else c - 0) % 3) * 4
            keys.append(f'<rect x="{kx}" y="{ky}" width="28" height="28" rx="6" fill="#1b1f3d" stroke="{CYAN}" stroke-opacity=".6"/>')
    for t in range(4):
        tx = x + (40 if not mirror else 70) + t * 34
        keys.append(f'<rect x="{tx}" y="{y + 150}" width="28" height="28" rx="6" fill="#1b1f3d" stroke="{MAGENTA}" stroke-opacity=".7"/>')
    keys.append(label(x + 100, y + 205, name, DIM, 15, "middle"))
    return "".join(keys)


steps = []

# 1. Parts
body = (nano(90, 140, 0.9)
        + f'<rect x="330" y="150" width="150" height="230" rx="20" fill="none" stroke="{MAGENTA}" stroke-width="3"/>'
        + label(405, 410, "3D-printed case", TEXT, 16, "middle")
        + f'<path d="M560 260 h120" stroke="#9aa3c7" stroke-width="10" stroke-linecap="round"/>'
        + f'<rect x="540" y="248" width="34" height="24" rx="6" fill="#9aa3c7"/><rect x="670" y="248" width="34" height="24" rx="6" fill="#9aa3c7"/>'
        + label(622, 310, "short USB-C cable", TEXT, 16, "middle")
        + label(622, 334, "(or USB-C → A adapter)", DIM, 14, "middle")
        + f'<rect x="760" y="170" width="150" height="120" rx="14" fill="{CARD}" stroke="{DIM}" stroke-dasharray="6 5"/>'
        + label(835, 220, "optional:", DIM, 14, "middle") + label(835, 244, "nice!view", TEXT, 16, "middle")
        + label(835, 266, "needs an adapter", DIM, 13, "middle"))
steps.append(("1", "WHAT YOU NEED", body,
              "No battery, no soldering: the dongle is powered by the computer's USB port"))

# 2. Into the case
body = (case(360, 120, 240, 340) + nano(405, 160, 0.95, label=False)
        + arrow(250, 300, 390, 300) + label(110, 290, "chip side up", TEXT) + label(110, 314, "USB-C to the opening", TEXT)
        + arrow(480, 108, 480, 145) + label(500, 100, "opening for the USB-C port", CYAN, 15))
steps.append(("2", "INTO THE CASE", body,
              "Slide the nice!nano in, USB-C port facing the case opening; close the lid"))

# 3. Bootloader
body = (nano(160, 130, 1.0, label=False)
        + f'<circle cx="296" cy="190" r="8" fill="{MAGENTA}"/><circle cx="296" cy="210" r="8" fill="{MAGENTA}"/>'
        + label(318, 195, "GND", MAGENTA, 15) + label(318, 215, "RST", MAGENTA, 15)
        + f'<path d="M300 186 q22 14 0 28" fill="none" stroke="{CYAN}" stroke-width="3"/>'
        + label(520, 380, "pins marked GND and RST on the board", DIM, 14) + label(520, 402, "(the row that starts with B+)", DIM, 14)
        + label(520, 200, "1. Plug the dongle into the PC", TEXT, 18)
        + label(520, 240, "2. Bridge GND and RST twice, quickly", TEXT, 18)
        + label(548, 266, "(tweezers or a paperclip)", DIM, 15)
        + label(520, 306, "3. A USB drive appears (NICENANO)", TEXT, 18)
        + label(548, 332, "a new board may show it right away", DIM, 15))
steps.append(("3", "BOOTLOADER MODE", body,
              "Same as the halves' reset button pressed twice: the board waits for a .uf2 file"))

# 4. Flash order
rows = [("settings_reset.uf2", "dongle, left, right", "erases the old pairings"),
        ("dongle.uf2", "dongle", "the new central"),
        ("lily58_left.uf2", "left half", "now a peripheral"),
        ("lily58_right.uf2", "right half", "now a peripheral")]
body = ""
for i, (f, who, why) in enumerate(rows):
    y = 130 + i * 78
    body += (f'<rect x="80" y="{y}" width="800" height="62" rx="12" fill="{CARD}" stroke="{CYAN if i else MAGENTA}" stroke-opacity=".6"/>'
             + label(105, y + 39, f"{i + 1}", MAGENTA, 22)
             + label(140, y + 28, f, CYAN, 18) + label(140, y + 50, why, DIM, 14)
             + label(860, y + 39, who, TEXT, 16, "end"))
steps.append(("4", "FLASH, IN THIS ORDER", body,
              "Drag each .uf2 onto the board's USB drive: it reboots by itself when the copy ends"))

# 5. How it works
body = (half(70, 150, name="LEFT HALF") + half(690, 150, mirror=True, name="RIGHT HALF")
        + case(410, 170, 140, 210) + nano(440, 200, 0.55, label=False)
        + label(480, 410, "DONGLE", MAGENTA, 16, "middle")
        + f'<path d="M290 230 Q350 200 420 250" fill="none" stroke="{CYAN}" stroke-width="2.5" stroke-dasharray="7 6" marker-end="url(#arrow)"/>'
        + f'<path d="M680 230 Q610 200 545 250" fill="none" stroke="{CYAN}" stroke-width="2.5" stroke-dasharray="7 6" marker-end="url(#arrow)"/>'
        + label(355, 195, "2.4 GHz", CYAN, 14, "middle") + label(615, 195, "2.4 GHz", CYAN, 14, "middle")
        + arrow(480, 168, 480, 112) + label(480, 100, "USB → PC", TEXT, 16, "middle"))
steps.append(("5", "HOW IT WORKS", body,
              "Each half talks to the dongle: one works without the other"))

# 6. Daily use
body = (f'<rect x="90" y="140" width="330" height="230" rx="16" fill="{CARD}" stroke="{CYAN}" stroke-opacity=".5"/>'
        + label(255, 180, "DESKTOP", CYAN, 18, "middle")
        + f'<rect x="540" y="140" width="330" height="230" rx="16" fill="{CARD}" stroke="{MAGENTA}" stroke-opacity=".5"/>'
        + label(705, 180, "LAPTOP", MAGENTA, 18, "middle")
        + case(225, 220, 60, 90, open_top=False) + case(675, 220, 60, 90, open_top=False)
        + f'<path d="M300 260 Q480 200 660 260" fill="none" stroke="{TEXT}" stroke-width="2.5" stroke-dasharray="8 6" marker-end="url(#arrow)"/>'
        + label(480, 120, "move the dongle", TEXT, 16, "middle")
        + label(480, 420, "Switch computers = unplug, plug. Old firmware kept: reflash it to go back to Bluetooth.", DIM, 14, "middle"))
steps.append(("6", "EVERY DAY", body,
              "Typing works everywhere the dongle is plugged: login screen and BIOS included"))

for step, title, body, caption in steps:
    with open(os.path.join(OUT, f"step-{step}.svg"), "w", encoding="utf-8") as f:
        f.write(frame(step, title, body, caption))
print(f"{len(steps)} diagrams written to {OUT}")
