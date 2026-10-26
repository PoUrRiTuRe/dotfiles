# ⌨️ Lily58 keyboard

Wireless Lily58 (two nice!nano v2 + two nice!view, Kailh Choc hotswap) running ZMK. The keymap and the firmware live in their own repository: [rotten_lily58_keymap_config](https://github.com/PoUrRiTuRe/rotten_lily58_keymap_config) (`config/lily58.keymap`). GitHub Actions builds the `.uf2` files there.

## Layers

`LOWER` and `RAISE` are held with the thumbs. Dimmed keys fall through to the base layer.

![Base layer](../assets/keymap/base.svg)

![Lower layer](../assets/keymap/lower.svg)

![Raise layer](../assets/keymap/raise.svg)

- **Bluetooth**: `Lower + 1/2/3` select the desktop / laptop / work profiles, `Lower + Esc` clears the **active** profile (see [Re-pair a ZMK Bluetooth keyboard](arch-notes.md#re-pair-a-zmk-bluetooth-keyboard)).
- **Encoder** (if fitted): volume up / down on every layer.
- ZMK Studio is enabled: a keymap changed live in Studio is stored on the keyboard and can differ from the file (and from these pictures).

To redraw the pictures after a keymap change:

```bash
python3 assets/keymap/make-keymap.py ~/rotten_lily58_keymap_config/config/lily58.keymap assets/keymap
```

## Screens

Custom `nice_view_rotten` shield in the keymap repository:

![Screens preview](../assets/keymap/screens.gif)

*Preview only, not contractual 😄: drawn on a computer with approximate fonts and shapes. The real screen uses the firmware's own fonts; the Bluetooth rings, numbers, battery and link icons are ZMK's stock ones.*

- **Left half**: battery, output, Bluetooth profiles and layer as on the stock screen; the classic **bongo cat** replaces the WPM graph. It taps **like in a mirror**: keys of the left half use the paw on the right of the screen (the cat's left paw), keys of the right half the paw on the left. For the **two top rows** the paw reaches a bit **further from its body**; the bottom rows and thumbs use the original position. Each new press lifts the paw for a moment and taps again; paws up when typing stops, then its idle animation.
- **Right half**: battery and link as on the stock screen; a **spinning wireframe cube** (light lines on the dark screen) replaces the art. It loops every 14.4 s without a jump.

Back to the stock screens: `nice_view` instead of `nice_view_rotten` in its `build.yaml`. To redraw the preview: `python3 tools/preview.py screens.gif` in the keymap repository, then copy it to `assets/keymap/`.

## Flashing

1. Keymap repository → **Actions** → latest green run → download the `firmware` artifact.
2. Plug a half in, double-tap its reset button: a USB drive appears.
3. Copy that half's `.uf2` onto it (`lily58_left…` or `lily58_right…`); it reboots by itself. Repeat for the other half.

A ZMK dongle (both halves become peripherals) is described in [zmk-dongle.md](zmk-dongle.md).
