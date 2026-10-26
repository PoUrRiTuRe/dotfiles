"""Draw the Lily58 layers of the ZMK keymap as Nebula-style SVGs (docs/lily58.md).

Usage: python3 assets/keymap/make-keymap.py <path/to/lily58.keymap> assets/keymap
(the keymap lives in the rotten_lily58_keymap_config repository, config/lily58.keymap)
"""
import os
import re
import sys
from html import escape

CYAN, MAGENTA, TEXT, DIM, CARD, BG = "#00f0ff", "#e600ff", "#d6def5", "#5d6688", "#12162e", "#070914"
FONT = "JetBrains Mono, DejaVu Sans Mono, monospace"
U = 58                     # one key unit, in pixels
KEY = 0.9                  # key size inside its unit

# Left half geometry (key units): column stagger, outer → inner
STAGGER = [0.5, 0.38, 0.12, 0, 0.12, 0.25]
INNER = (6.05, 2.75)                                  # "[" / "]" key beside the bottom row
THUMBS = [(2.5, 4.1), (3.5, 4.12), (4.5, 4.3)]        # three straight thumb keys
BIG_THUMB = (5.8, 4.3, 30)                          # 1.5u thumb key: x, y, rotation
HALF_W = 7.2
GAP = 2.6
WIDTH = 2 * HALF_W + GAP

# ── Key labels ────────────────────────────────────────────────
SHIFTED = {"N1": ("1", "!"), "N2": ("2", "@"), "N3": ("3", "#"), "N4": ("4", "$"), "N5": ("5", "%"),
           "N6": ("6", "^"), "N7": ("7", "&"), "N8": ("8", "*"), "N9": ("9", "("), "N0": ("0", ")"),
           "GRAVE": ("`", "~"), "MINUS": ("-", "_"), "EQUAL": ("=", "+"), "LBKT": ("[", "{"),
           "RBKT": ("]", "}"), "BSLH": ("\\", "|"), "SEMI": (";", ":"), "SQT": ("'", '"'),
           "SINGLE_QUOTE": ("'", '"'), "COMMA": (",", "<"), "DOT": (".", ">"), "FSLH": ("/", "?"),
           "SLASH": ("/", "?")}
NAMES = {"ESC": "Esc", "TAB": "Tab", "SPACE": "Space", "RET": "Enter", "ENTER": "Enter",
         "BACKSPACE": "Bksp", "BSPC": "Bksp", "DEL": "Del", "LEFT_SHIFT": "Shift", "LSHIFT": "Shift",
         "LSHFT": "Shift", "RSHFT": "Shift", "RIGHT_SHIFT": "Shift", "LCTRL": "Ctrl", "LEFT_CONTROL": "Ctrl",
         "RCTRL": "Ctrl", "LALT": "Alt", "LEFT_ALT": "Alt", "RALT": "AltGr", "LGUI": "Super", "RGUI": "Super",
         "QUESTION": "?", "EXCL": "!", "AT": "@", "HASH": "#", "DOLLAR": "$", "PRCNT": "%", "CARET": "^",
         "AMPS": "&", "KP_MULTIPLY": "*", "ASTRK": "*", "LPAR": "(", "RPAR": ")", "TILDE": "~",
         "LESS_THAN": "<", "GREATER_THAN": ">", "KP_PLUS": "+", "PLUS": "+", "LBRC": "{", "RBRC": "}",
         "PIPE": "|", "UNDERSCORE": "_", "DOUBLE_QUOTES": '"', "LEFT_ARROW": "←", "RIGHT_ARROW": "→",
         "UP_ARROW": "↑", "DOWN_ARROW": "↓", "C_AC_PRINT": "Print", "PSCRN": "PrtSc",
         "C_VOL_UP": "Vol+", "C_VOL_DN": "Vol-", "C_MUTE": "Mute", "C_PP": "Play"}
BT_NAMES = ["desktop", "laptop", "work", "phone"]


def parse(path):
    src = open(path, encoding="utf-8").read()
    src = re.sub(r"//[^\n]*", "", src)
    layers = []
    for m in re.finditer(r"(\w+)\s*\{[^{}]*?display-name\s*=\s*\"([^\"]+)\"[^{}]*?bindings\s*=\s*<([^>]*)>", src):
        tokens = re.findall(r"&\w+(?:\s+[A-Z0-9_()]+)*", m.group(3))
        layers.append((m.group(2), [t.split() for t in tokens]))
    return layers


def label(binding, names):
    """(main, shifted, kind) for one binding; kind: key, layer, bt, trans."""
    b = binding[0]
    if b == "&trans":
        return None
    if b == "&mo":
        return (names[int(binding[1])].upper(), "", "layer")
    if b == "&bt":
        if binding[1] == "BT_CLR":
            return ("BT clr", "", "bt")
        n = int(binding[2])
        return (f"BT {n + 1}", BT_NAMES[n] if n < len(BT_NAMES) else "", "bt")
    if b == "&kp":
        code = binding[1]
        if code in SHIFTED:
            return SHIFTED[code] + ("key",)
        if len(code) == 1:
            return (code, "", "key")
        return (NAMES.get(code, code), "", "key")
    return (" ".join(binding)[1:], "", "key")


# ── Geometry: 58 positions in keymap order ───────────────────
def positions():
    def left(c, r):
        return (c, STAGGER[c] + r, 0)

    def mirror(p):
        x, y, rot = p
        return (WIDTH - x - 1, y, -rot)

    pos = []
    for r in range(3):
        pos += [left(c, r) for c in range(6)] + [mirror(left(5 - c, r)) for c in range(6)]
    pos += [left(c, 3) for c in range(6)] + [(*INNER, 0), mirror((*INNER, 0))]
    pos += [mirror(left(5 - c, 3)) for c in range(6)]
    thumbs = [(x, y, 0) for x, y in THUMBS] + [BIG_THUMB]
    pos += thumbs + [mirror(t) for t in reversed(thumbs)]
    return pos


def key_svg(x, y, rot, lab, base_lab, thumb, big):
    w, h = KEY, (1.4 if big else KEY)
    px, py = 30 + (x + (1 - KEY) / 2) * U, 120 + (y + (1 - KEY) / 2) * U
    pw, ph = w * U, h * U
    cx, cy = px + pw / 2, py + ph / 2
    t = f' transform="rotate({rot} {cx:.1f} {cy:.1f})"' if rot else ""
    trans = lab is None
    main, shifted, kind = lab if lab else (base_lab or ("", "", "key"))
    stroke = MAGENTA if (thumb or kind == "layer") else CYAN
    color = DIM if trans else (MAGENTA if kind in ("layer", "bt") else TEXT)
    out = (f'<g{t}><rect x="{px:.1f}" y="{py:.1f}" width="{pw:.1f}" height="{ph:.1f}" rx="9" '
           f'fill="{CARD if not trans else BG}" stroke="{stroke}" stroke-opacity="{0.35 if trans else 0.8}" stroke-width="1.6"/>')
    size = 17 if len(main) <= 2 else (14 if len(main) <= 5 else 11)
    if shifted and kind == "bt":
        out += (f'<text x="{cx:.1f}" y="{cy - 1:.1f}" text-anchor="middle" font-size="{size}" fill="{color}">{escape(main)}</text>'
                f'<text x="{cx:.1f}" y="{cy + 15:.1f}" text-anchor="middle" font-size="10" fill="{CYAN}">{escape(shifted)}</text>')
    elif shifted:
        out += (f'<text x="{cx:.1f}" y="{cy - 6:.1f}" text-anchor="middle" font-size="12" fill="{DIM if trans else CYAN}">{escape(shifted)}</text>'
                f'<text x="{cx:.1f}" y="{cy + 13:.1f}" text-anchor="middle" font-size="{size}" fill="{color}">{escape(main)}</text>')
    else:
        out += f'<text x="{cx:.1f}" y="{cy + 5:.1f}" text-anchor="middle" font-size="{size}" fill="{color}">{escape(main)}</text>'
    return out + "</g>"


def layer_svg(name, bindings, base, names, footer):
    W, H = int(WIDTH * U + 60), int(6.2 * U + 150)
    body = []
    for i, ((x, y, rot), b) in enumerate(zip(positions(), bindings)):
        lab = label(b, names)
        base_lab = label(base[i], names) if lab is None else None
        thumb = i >= 50
        body.append(key_svg(x, y, rot, lab, base_lab, thumb, big=thumb and rot != 0))
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" font-family="{FONT}">
  <defs>
    <radialGradient id="g1" cx="85%" cy="0%" r="70%"><stop offset="0" stop-color="{MAGENTA}" stop-opacity=".22"/><stop offset="1" stop-color="{MAGENTA}" stop-opacity="0"/></radialGradient>
    <radialGradient id="g2" cx="0%" cy="100%" r="70%"><stop offset="0" stop-color="{CYAN}" stop-opacity=".18"/><stop offset="1" stop-color="{CYAN}" stop-opacity="0"/></radialGradient>
    <linearGradient id="title" x1="0" x2="1"><stop offset="0" stop-color="{CYAN}"/><stop offset="1" stop-color="{MAGENTA}"/></linearGradient>
  </defs>
  <rect width="{W}" height="{H}" rx="18" fill="{BG}"/>
  <rect width="{W}" height="{H}" rx="18" fill="url(#g1)"/>
  <rect width="{W}" height="{H}" rx="18" fill="url(#g2)"/>
  <text x="{W / 2}" y="70" text-anchor="middle" font-size="40" font-weight="700" fill="url(#title)" letter-spacing="6">{escape(name.upper())}</text>
  {"".join(body)}
  <text x="{W / 2}" y="{H - 26}" text-anchor="middle" font-size="14" fill="{DIM}">{escape(footer)}</text>
</svg>
'''


keymap, out = sys.argv[1], sys.argv[2]
layers = parse(keymap)
names = [n for n, _ in layers]
assert layers and all(len(b) == 58 for _, b in layers), [(n, len(b)) for n, b in layers]
os.makedirs(out, exist_ok=True)
for name, bindings in layers:
    with open(os.path.join(out, f"{name.lower()}.svg"), "w", encoding="utf-8") as f:
        footer = ("small legend = with Shift · LOWER / RAISE = hold" if name == names[0]
                  else f"hold {name.upper()} · dimmed keys = same as {names[0]}")
        f.write(layer_svg(name, bindings, layers[0][1], names, footer))
print(f"{len(layers)} layers written to {out}: " + ", ".join(names))
