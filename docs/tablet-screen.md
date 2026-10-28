# 📱 Tablet as a third monitor (Sunshine + Moonlight)

An Android tablet becomes a third Hyprland monitor over Wi-Fi, with the whole Nebula theme (Serpantinum bar, wallpaper, borders, cursor), mouse **and** touch at the same time. When the stream stops, the virtual monitor disappears and the tablet is a normal tablet again (e-reader in the evening…).

How it works:

- **Hyprland** creates a virtual (headless) monitor named `TABLET`: 2000×1200 @ 120 Hz, scale 1.25, right of the main monitor (`config/hosts/rotten-desktop.lua`).
- **Sunshine** (on the PC) streams that monitor; **Moonlight** (on the tablet) shows it and sends touch back.
- Sunshine's "Nebula tablet" app runs `tablet-screen on` when Moonlight starts it and `tablet-screen off` when the session is quit (`prep-cmd` in `~/.config/sunshine/apps.json`): nothing to type.

## Setup (once)

```bash
~/setup-tablet.sh
```

It installs Sunshine (`sunshine-bin`, AUR), copies `sunshine.conf` / `apps.json` from this repository, enables Sunshine's user service and prints the steps left:

1. Open `https://localhost:47990`, accept the self-signed certificate, create the Sunshine login.
2. The monitor to stream is already set in `sunshine.conf`: `output_name = TABLET` (Sunshine matches the output **name**; a number such as `2` silently falls back to the first monitor). With the wlr capture, the web UI shows no monitor list. Check with `journalctl --user -u app-dev.lizardbyte.app.Sunshine -b | grep 'Selected monitor'` during a session: `[]` (no description) is `TABLET`.
3. On the tablet: install **Moonlight**, add the PC (same network), type the PIN shown by Moonlight in Sunshine's **PIN** tab.
4. Moonlight settings: resolution **native** (2000×1200), **120 FPS**, **touchscreen** mode (not trackpad).
5. Pick a wallpaper for the new monitor once with `SUPER + P` (Serpantinum stores it per monitor).

## Every day

- **Start**: open Moonlight on the tablet, tap **Nebula tablet**.
- **Stop**: in Moonlight, **Quit session** (long press on the app). Simply leaving Moonlight only pauses the stream: the monitor stays until the session is quit.
- By hand: `tablet-screen on`, `tablet-screen off`, `tablet-screen status`.

## Notes

- `capture = wlr` in `sunshine.conf`: the only Sunshine capture method that sees Hyprland's virtual monitors. `encoder = vaapi` uses the AMD GPU.
- Touch is mapped to `TABLET` by `input.touchdevice.output` in the host file; the PC mouse reaches the tablet by crossing the right edge of the main monitor.
- Moonlight cannot find or reach the PC: with **ufw** active, open Sunshine's ports (`setup-tablet.sh` prints the command): `sudo ufw allow 47984:47990/tcp && sudo ufw allow 48010/tcp && sudo ufw allow 47998:48000/udp && sudo ufw allow 48010/udp`. Both devices must be on the same home network (school / public Wi-Fi usually isolates devices). Add the PC in Moonlight with its IP from `ip -4 -br addr`.
- No touch / mouse from the tablet: `sudo usermod -aG input $USER`, then log out and back in.
- Black or stuttering stream: lower Moonlight to 60 FPS or the bitrate first; check `journalctl --user -u <sunshine unit> -b` for errors.
- Another tablet: change the mode / scale of the `TABLET` rule in the host file and Moonlight's resolution.
