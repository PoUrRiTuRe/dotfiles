#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────
#  make-cursors.py — builds the Bibata-Nebula-Cross cursor theme
#   • base: Bibata Modern Classic (black, white outline)
#   • main pointer: Bibata's "crosshair" cursor
#   • white outline → animated RGB outline (Chroma S style, ~2.3 s per loop)
#   • busy cursor: hourglass + crosshair + Chroma S rainbow ring
#  Usage:
#    python3 make-cursors.py <Bibata-Modern-Classic dir> <ChromaS dir> <output dir>
#  Requires: python-pillow (sudo pacman -S python-pillow)
# ─────────────────────────────────────────────────────────────
import colorsys
import os
import shutil
import struct
import sys

from PIL import Image, ImageDraw

SIZES = (24, 32, 48)        # sizes kept (same as Chroma S)
CYCLE_MS = 2300             # duration of one color loop
FRAMES = 40                 # frames per loop (RGB outline)
BUSY_FRAMES = 70            # frames per loop (busy cursor, smoother ring)
BUSY_NAMES = ("wait", "progress", "left_ptr_watch")  # watch, half-busy… are symlinks


# ── Reading / writing the Xcursor format ──────────────────────
def load(path):
    data = open(os.path.realpath(path), "rb").read()
    if data[:4] != b"Xcur":
        raise ValueError(f"not an Xcursor file: {path}")
    _, _, count = struct.unpack_from("<III", data, 4)
    images = []
    for i in range(count):
        kind, size, pos = struct.unpack_from("<III", data, 16 + i * 12)
        if kind != 0xFFFD0002:
            continue
        _, _, _, _, w, h, xh, yh, delay = struct.unpack_from("<9I", data, pos)
        pixels = data[pos + 36 : pos + 36 + w * h * 4]
        images.append(dict(size=size, xh=xh, yh=yh, delay=delay,
                           im=Image.frombytes("RGBA", (w, h), pixels, "raw", "BGRA")))
    return images


def save(path, images):
    toc, chunks = [], []
    offset = 16 + 12 * len(images)
    for x in images:
        im = x["im"].convert("RGBA")
        chunk = struct.pack("<9I", 36, 0xFFFD0002, x["size"], 1, im.width, im.height,
                            x["xh"], x["yh"], x["delay"]) + im.tobytes("raw", "BGRA")
        toc.append(struct.pack("<III", 0xFFFD0002, x["size"], offset))
        chunks.append(chunk)
        offset += len(chunk)
    with open(path, "wb") as f:
        f.write(b"Xcur" + struct.pack("<III", 16, 0x10000, len(images)))
        f.write(b"".join(toc) + b"".join(chunks))


# ── RGB outline ──────────────────────────────────────────────
def outline_mask(im):
    """White pixels connected to the shape's edge = the outline (not the
    white symbols inside the colored badges)."""
    w, h = im.size
    px = im.load()

    def whiteish(p):
        r, g, b, a = p
        return a > 0 and min(r, g, b) > 150 and max(r, g, b) - min(r, g, b) < 40

    def near_transparent(x, y):
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                nx, ny = x + dx, y + dy
                if not (0 <= nx < w and 0 <= ny < h) or px[nx, ny][3] < 128:
                    return True
        return False

    stack = [(x, y) for y in range(h) for x in range(w)
             if whiteish(px[x, y]) and near_transparent(x, y)]
    mask = set(stack)
    while stack:
        x, y = stack.pop()
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in mask and whiteish(px[nx, ny]):
                mask.add((nx, ny))
                stack.append((nx, ny))
    return mask


def recolor(im, mask, hue):
    out = im.copy()
    px = out.load()
    r0, g0, b0 = colorsys.hsv_to_rgb(hue, 1.0, 1.0)
    for x, y in mask:
        r, g, b, a = px[x, y]
        k = max(r, g, b) / 255  # keep the anti-aliasing
        px[x, y] = (int(r0 * 255 * k), int(g0 * 255 * k), int(b0 * 255 * k), a)
    return out


def static_frames(images):
    """One image per kept size (the first one if the cursor is already animated)."""
    by_size = {}
    for x in images:
        by_size.setdefault(x["size"], x)
    return [by_size[s] for s in SIZES if s in by_size]


def rgb_cursor(images):
    delay = CYCLE_MS // FRAMES
    out = []
    for base in static_frames(images):
        if len(images) > len(set(x["size"] for x in images)):
            # already animated: keep its animation as is
            out += [x for x in images if x["size"] == base["size"]]
            continue
        mask = outline_mask(base["im"])
        for i in range(FRAMES):
            out.append(dict(base, delay=delay, im=recolor(base["im"], mask, i / FRAMES)))
    return out


# ── Busy cursor: hourglass + crosshair + RGB ring ─────────────
def hourglass(size):
    big = size * 4
    im = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    w = big * 0.62
    x0 = (big - w) / 2
    grey, dark = (150, 150, 150, 255), (40, 40, 40, 255)
    d.rectangle([x0, 0, x0 + w, big * 0.1], fill=grey, outline=dark, width=max(1, big // 24))
    d.rectangle([x0, big * 0.9, x0 + w, big], fill=grey, outline=dark, width=max(1, big // 24))
    d.polygon([(x0 + w * 0.1, big * 0.1), (x0 + w * 0.9, big * 0.1), (big / 2, big / 2)],
              fill=grey, outline=dark)
    d.polygon([(big / 2, big / 2), (x0 + w * 0.9, big * 0.9), (x0 + w * 0.1, big * 0.9)],
              fill=grey, outline=dark)
    return im.resize((size, size), Image.LANCZOS)


def busy_cursor(cross_images, ring_images):
    delay = CYCLE_MS // BUSY_FRAMES
    ring_src = [x for x in ring_images if x["size"] == max(r["size"] for r in ring_images)]
    ring_delay = ring_src[0]["delay"] or 33
    out = []
    for base in static_frames(cross_images):
        s = base["size"]
        mask = outline_mask(base["im"])
        glass = hourglass(round(s * 0.34))
        ring_size = round(s * 0.5)
        for i in range(BUSY_FRAMES):
            t = i * delay
            frame = Image.new("RGBA", (s, s), (0, 0, 0, 0))
            frame.alpha_composite(recolor(base["im"], mask, i / BUSY_FRAMES))
            frame.alpha_composite(glass, (0, 0))
            ring = ring_src[(t // ring_delay) % len(ring_src)]["im"]
            ring = ring.crop(ring.getbbox()).resize((ring_size, ring_size), Image.LANCZOS)
            frame.alpha_composite(ring, (s - ring_size, s - ring_size))
            out.append(dict(size=s, xh=base["xh"], yh=base["yh"], delay=delay, im=frame))
    return out


# ── Main ─────────────────────────────────────────────────────
def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__ or "usage: make-cursors.py <Bibata> <ChromaS> <output>")
    bibata, chroma, out_dir = (os.path.abspath(p) for p in sys.argv[1:])
    src, dst = os.path.join(bibata, "cursors"), os.path.join(out_dir, "cursors")
    if os.path.exists(out_dir):
        shutil.rmtree(out_dir)
    os.makedirs(dst)

    names = sorted(os.listdir(src))
    for name in names:  # real files first, symlinks afterwards
        path = os.path.join(src, name)
        if os.path.islink(path):
            continue
        if name == "left_ptr":
            images = load(os.path.join(src, "crosshair"))  # the crosshair becomes the main pointer
        else:
            images = load(path)
        save(os.path.join(dst, name), rgb_cursor(images))

    cross = load(os.path.join(src, "crosshair"))
    ring = load(os.path.join(chroma, "cursors", "wait"))
    busy = busy_cursor(cross, ring)
    for name in BUSY_NAMES:
        target = os.path.join(dst, name)
        if os.path.islink(target) or os.path.exists(target):
            os.remove(target)
        save(target, busy)

    for name in names:
        path = os.path.join(src, name)
        target = os.path.join(dst, name)
        if os.path.islink(path) and not os.path.exists(target):
            os.symlink(os.readlink(path), target)

    with open(os.path.join(out_dir, "index.theme"), "w") as f:
        f.write("[Icon Theme]\nName=Bibata-Nebula-Cross\n"
                "Comment=Bibata Modern Classic (ful1e5, GPL-3.0): crosshair main pointer, "
                "animated RGB outline, Chroma-style busy cursor\nInherits=hicolor\n")
    lic = os.path.join(bibata, "..", "LICENSE")
    if os.path.exists(lic):
        shutil.copy(lic, out_dir)
    print(f"ok  theme created in {out_dir}")


if __name__ == "__main__":
    main()
