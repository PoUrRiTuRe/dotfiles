#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  make-cheatsheet.py — Nebula cheatsheet of every shortcut
#  Reads the descriptions of home/.config/hypr/config/keybinds.lua (run with
#  a stub "hl" object in the lua interpreter) and keybinds-extra.tsv, writes
#  assets/cheatsheet.html, then renders assets/cheatsheet.png with a
#  Chromium-based browser in headless mode (chromium, brave, chrome).
#  The page is sized in vw units: it keeps its layout at any resolution.
#  Usage:  python3 scripts/make-cheatsheet.py   (needs: lua, a Chromium browser)
# ─────────────────────────────────────────────────────────────
import html, os, re, shutil, subprocess, sys, tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent if (HERE.parent / "home/.config/hypr").is_dir() else Path.home() / "dotfiles-backup"
KEYBINDS = REPO / "home/.config/hypr/config/keybinds.lua"
EXTRA = REPO / "home/.config/hypr/keybinds-extra.tsv"
OUT_HTML = REPO / "assets/cheatsheet.html"
OUT_PNG = REPO / "assets/cheatsheet.png"

STUB = r'''
local any = setmetatable({}, { __index = function(t) return t end, __call = function(t) return t end })
hl = { dsp = any, gesture = function() end,
       bind = function(keys, _, opts)
         if opts and opts.description then io.write(keys, "\t", opts.description, "\n") end
       end }
_G.mainMod, _G.terminal = "SUPER", "kitty"
dofile(arg[1])
'''

# Column layout of the page: sections in display order
COLUMNS = [
    ["Windows", "Help", "Session"],
    ["Workspaces", "Apps", "Screenshots"],
    ["Serpantinum", "Terminal"],
    ["Media", "Shell", "Touchpad"],
]

ARROWS = {"Left": "←", "Right": "→", "Up": "↑", "Down": "↓"}
PRETTY = {
    "RETURN": "Enter", "Escape": "Esc", "TAB": "Tab", "SPACE": "Space",
    "mouse:272": "Left click", "mouse:273": "Right click", "BACKSPACE": "Backspace",
    "DELETE": "Delete", "HOME": "Home", "END": "End",
    "XF86PowerOff": "Power", "switch:on:Lid Switch": "Lid closed",
    "XF86AudioMicMute": "Mic mute", "XF86MonBrightnessUp": "Brightness +",
    "XF86MonBrightnessDown": "Brightness −", "3 FINGERS SWIPE": "3-finger swipe",
}


def read_binds():
    if not shutil.which("lua"):
        sys.exit("!! lua is missing: sudo pacman -S lua")
    with tempfile.NamedTemporaryFile("w", suffix=".lua", delete=False) as f:
        f.write(STUB)
        stub = f.name
    try:
        out = subprocess.run(["lua", stub, str(KEYBINDS)], capture_output=True, text=True, check=True).stdout
    finally:
        os.unlink(stub)
    binds = [tuple(line.split("\t", 1)) for line in out.splitlines() if "\t" in line]
    for line in EXTRA.read_text(encoding="utf-8").splitlines():
        if line and not line.startswith("#") and "\t" in line:
            binds.append(tuple(line.split("\t", 1)))
    return binds


def collapse(binds):
    """Merge the obvious families (arrows, workspace numbers) and drop the
    media-key duplicates, so that the page stays readable."""
    sections, seen = {}, set()
    merges = [
        # (description regex, merged keys, merged description)
        (r"Windows: focus the window", "SUPER + ←↑→↓", "focus a window"),
        (r"Windows: move the window (left|right|up|down)", "SUPER + CTRL + ←↑→↓", "move the window (also to the other monitor)"),
        (r"Windows: (shrink|grow) the", "SUPER + SHIFT + ←↑→↓", "resize the window"),
        (r"Workspaces: go to workspace \d+", "SUPER + 1 … 0", "go to workspace 1 – 10"),
        (r"Workspaces: send the window to workspace \d+", "SUPER + SHIFT + 1 … 0", "send the window to workspace 1 – 10"),
        (r"Shell: select one character", "SHIFT + ←→", "select character by character"),
        (r"Shell: select one word", "CTRL + SHIFT + ←→", "select word by word"),
        (r"Shell: jump one word", "CTRL + ←→", "jump word by word"),
    ]
    for keys, desc in binds:
        if desc.endswith("(media key)"):
            continue
        for pattern, mkeys, mdesc in merges:
            if re.match(pattern, desc):
                keys, desc = mkeys, desc.split(": ", 1)[0] + ": " + mdesc
                break
        if (keys, desc) in seen:
            continue
        seen.add((keys, desc))
        section, _, text = desc.partition(": ")
        sections.setdefault(section, []).append((keys, text))
    return sections


def keycaps(keys):
    parts = []
    for part in [p.strip() for p in keys.split(" + ")]:
        label = PRETTY.get(part, ARROWS.get(part, part))
        cls = "key super" if part == "SUPER" else "key"
        parts.append(f'<span class="{cls}">{html.escape(label)}</span>')
    return '<span class="plus">+</span>'.join(parts)


def render_html(sections):
    cols = []
    for column in COLUMNS:
        blocks = []
        for name in column:
            rows = sections.get(name, [])
            if not rows:
                continue
            items = "".join(
                f'<div class="row"><div class="keys">{keycaps(k)}</div><div class="desc">{html.escape(d)}</div></div>'
                for k, d in rows)
            blocks.append(f'<section><h2>{html.escape(name)}</h2>{items}</section>')
        cols.append(f'<div class="col">{"".join(blocks)}</div>')
    return f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Nebula shortcuts</title>
<style>
@font-face {{ font-family: "JBM"; src: local("JetBrainsMono Nerd Font"), local("JetBrains Mono"), url("fonts/JetBrainsMono-Regular.ttf"); }}
@font-face {{ font-family: "JBM"; font-weight: 700; src: local("JetBrainsMono Nerd Font Bold"), local("JetBrains Mono Bold"), url("fonts/JetBrainsMono-Bold.ttf"); }}
:root {{ --cyan: #00f0ff; --magenta: #e600ff; --text: #d6def5; --dim: #7d86a8; --card: rgba(18, 22, 46, .72); }}
* {{ box-sizing: border-box; margin: 0; }}
html {{ min-height: 56.25vw;
  background:
    radial-gradient(60vw 40vw at 85% 0%, rgba(230, 0, 255, .16), transparent 70%),
    radial-gradient(60vw 45vw at 0% 100%, rgba(0, 240, 255, .13), transparent 70%),
    #070914; }}
body {{
  font-family: "JBM", "DejaVu Sans Mono", monospace; color: var(--text);
  width: 100vw; padding: 1.4vw 1.8vw 1vw;
}}
header {{ display: flex; align-items: baseline; justify-content: space-between; margin-bottom: .9vw; }}
h1 {{ font-size: 1.75vw; font-weight: 700; letter-spacing: .08em;
      background: linear-gradient(90deg, var(--cyan), var(--magenta)); -webkit-background-clip: text; color: transparent; }}
header p {{ font-size: .78vw; color: var(--dim); }}
header p b {{ color: var(--cyan); }}
.grid {{ display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: .9vw; align-items: start; }}
.col {{ display: flex; flex-direction: column; gap: .9vw; }}
section {{ background: var(--card); border: .07vw solid rgba(0, 240, 255, .28); border-radius: .8vw; padding: .65vw .8vw .45vw;
           box-shadow: 0 0 1.4vw rgba(0, 240, 255, .06) inset; }}
h2 {{ font-size: .86vw; letter-spacing: .14em; text-transform: uppercase; color: var(--magenta); margin-bottom: .45vw; }}
.row {{ display: grid; grid-template-columns: 10.6vw 1fr; align-items: center; gap: .5vw; padding: .2vw 0;
        border-top: .05vw solid rgba(125, 134, 168, .14); }}
section .row:first-of-type {{ border-top: 0; }}
.keys {{ display: flex; flex-wrap: wrap; align-items: center; gap: .18vw; }}
.key {{ font-size: .66vw; font-weight: 700; padding: .12vw .36vw; border-radius: .3vw; white-space: nowrap;
        color: #e9f6ff; background: rgba(0, 240, 255, .1); border: .06vw solid rgba(0, 240, 255, .55); }}
.key.super {{ background: rgba(230, 0, 255, .14); border-color: rgba(230, 0, 255, .7); }}
.plus {{ font-size: .6vw; color: var(--dim); }}
.desc {{ font-size: .7vw; line-height: 1.3; }}
</style></head>
<body>
<header><h1>NEBULA · SHORTCUTS</h1>
<p>Search them all with <b>SUPER + K</b> · media keys do the same as SUPER + ALT</p></header>
<div class="grid">{"".join(cols)}</div>
</body></html>
'''


def find_browser():
    for name in ("chromium", "brave", "google-chrome-stable", "google-chrome", "chrome"):
        if shutil.which(name):
            return shutil.which(name)
    return os.environ.get("CHROME")


def main():
    sections = collapse(read_binds())
    OUT_HTML.parent.mkdir(parents=True, exist_ok=True)
    OUT_HTML.write_text(render_html(sections), encoding="utf-8")
    print(f"==> {OUT_HTML.relative_to(REPO)} written")

    browser = find_browser()
    if not browser:
        print("!! No Chromium-based browser found: open the HTML file and take a screenshot.")
        return
    args = [browser, "--headless=old" if "headless_shell" in browser else "--headless", "--disable-gpu", "--hide-scrollbars",
            "--force-device-scale-factor=2", "--window-size=1920,1080",
            f"--screenshot={OUT_PNG}", OUT_HTML.as_uri()]
    if os.geteuid() == 0:
        args.insert(1, "--no-sandbox")   # Chromium refuses to run as root otherwise
    subprocess.run(args, check=True, capture_output=True)
    print(f"==> {OUT_PNG.relative_to(REPO)} rendered (3840x2160)")


if __name__ == "__main__":
    main()
