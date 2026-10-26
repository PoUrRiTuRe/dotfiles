# Roadmap — "Nebula" Hyprland rice

> Arch Linux · Hyprland 0.56 (Lua config) · Serpantinum · cyan / magenta theme
> Machines: `rotten-laptop` (ThinkPad P53) · `rotten-desktop` (desktop PC, RX 5700 XT)
> Backup: `scripts/save-all.sh` → `scripts/backup-rice.sh` → this repository

---

## ✅ Foundations

- [x] **kitty opened fullscreen** → kitty bug ([#10442](https://github.com/kovidgoyal/kitty/issues/10442)), worked around with a `fullscreen_state = "0 0"` window rule
- [x] **Ctrl + ← / →** printed "D" in zsh → `bindkey` in `.zshrc`
- [x] **Slow SDDM greeter** → misplaced `pam_fprintd` line in `/etc/pam.d/sddm`
- [x] **Fingerprint on the greeter** → password first, then fingerprint (empty field + Enter, then the finger)
- [x] **`nebula` SDDM theme** → neon clock, dark cards, nebula background
- [x] **fastfetch overwritten** by matugen → the real config lives in `perso.jsonc`
- [x] **`SUPER + number` latency** → native Hyprland dispatchers instead of `serpantinum msg`
- [x] **Backup** → `backup-rice.sh` + GitHub repository (SSH key, git identity)
- [x] **"NVIDIA control panel" colors** → `nvidia-like.glsl` shader (brightness 60 / contrast 65 / vibrance 85)
- [x] **README** with screenshots

---

## ✅ Main steps

### 1. 🎧 Bluetooth
- [x] Headphones paired (Paired / Bonded / Trusted), automatic reconnection
- [x] `/var/lib/bluetooth` backed up (without the cache of nearby devices)

### 2. 💬 Notifications
- [x] The **Silent** mode of the `SUPER + E` panel was blocking pop-ups

### 3. 🌈 Window borders
- [x] Cyan → magenta gradient, 2 px, continuous rotation at constant speed (`linear` curve)
- [x] Smooth fade on focus change (`smooth` curve)
- [x] Border config grouped in `settings.lua`

### 4. 🛟 Restore points ⏭️
- [x] Handled by separate rsync scripts (system drive → second drive)

### 5. 📦 `backup-rice.sh`
- [x] User config + system files + package lists
- [x] Refuses `sudo`, installs `git` if needed, offers to push to GitHub

### 6. 🔁 `restore-rice.sh` ❌
- Dropped: each shell (Serpantinum, Caelestia, DMS) ships its own config. The README documents a manual install instead.

### 7. 🗂️ "Nebula" Dolphin
- [x] Kvantum (based on KvArcDark), translucent windows blurred by Hyprland
- [x] **Nebula** KDE color scheme: white text, cyan selection, magenta links
- [x] `QT_QPA_PLATFORMTHEME=qt6ct` **and** `QT_STYLE_OVERRIDE=kvantum` in `env.lua`

### 8. 🧹 KDE Plasma and GNOME cleanup
- [x] `hyprpolkitagent` installed (there was no polkit agent)
- [x] 42 useful packages protected, **327 packages removed (~2 GB)**
- [x] Follow-up fix: `zbar` reinstalled (required by Serpantinum screenshots)
- [x] Follow-up fix: `ark` (+ `unrar`) reinstalled for Dolphin's "Compress / Extract" menu; added to the protected list of `kde-cleanup-preview.sh`
- [x] The greeter only offers Hyprland

### 9. 📂 `ls` colors
- [x] `eza` + Nebula theme (`~/.config/eza/theme.yml`), aliases `ls` / `ll` / `la` / `lt`
- [x] kitty zoom: `Ctrl + =` / `Ctrl + -` / `Ctrl + 0`
- Dark-cyan hidden folders: dropped (eza can't color a folder by name)

### 10. 📝 LazyVim
- [x] Neovim + LazyVim (official starter) + tools (ripgrep, fd, fzf, lazygit)
- [x] Launch from `SUPER + D`: `nvim.desktop` → `kitty nvim %F` (the launcher ignores `Terminal=true`)

### 11. 🌙 Dark GTK windows
- [x] GTK settings inherited from KDE replaced (`gtk-3.0` / `gtk-4.0`)
- [x] `GTK_THEME=Adwaita:dark` in `env.lua` **and** `~/.config/environment.d/gtk.conf` (for the portal)
- [x] Papirus-Dark icons with cyan folders (`gsettings` + `papirus-folders`)
- [x] Nebula colors for nano (readable error messages)

### 12. 📐 Top bar with `SUPER + E`
- [x] `patch-topbar.py`: clock re-centered, indicators lined up against the panel
- ⚠️ Re-run after a Serpantinum update

---

## ✅ Later changes

### ⌨️ Bluetooth split keyboard (ZMK)
- [x] Paired with `bluetoothctl` + `agent KeyboardDisplay`: type the 6-digit passkey **on the keyboard** + Enter
- [x] **Lost pairing**: a **gear** icon instead of the Wi-Fi-like icon on the keyboard screen means the active ZMK profile has no pairing (the keyboard lost its key while the PC still saw it as connected)
- [x] Fixed by pairing again: `remove` → `agent KeyboardDisplay` → `scan on` → `pair` → `trust` → `connect`
- [x] Root cause in the keymap: **Lower + Esc = `BT_CLR`** (clears the pairing), Lower + 2…5 = empty profiles
- [ ] Move the Bluetooth keys to an Adjust layer (Lower + Raise), then flash both halves
- ℹ️ Only the **left** half (central) talks to the PC; the right half talks to the left one

### 🔀 Next / previous workspace
- [x] `SUPER + Tab` / `SUPER + Shift + Tab`
- [x] Fixed: `"+1"` kept creating workspaces (up to 48) → `"e+1"` / `"e-1"`: open workspaces only, wrapping around

### 🧹 Full `clear`
- [x] `clear` = real reset (scrollback wiped) + fastfetch
- [x] Safety net: the content is saved first to `~/.cache/terminal-logs/` (last 20, **never pushed to GitHub**)
- [x] `Ctrl + L` bound to the same reset
- [x] kitty: `allow_remote_control yes` (needed for the safety net)
- [x] `less` installed (missing for `git log` and `man`)

### 🎮 Steam games
- [x] `steam`, `lib32-nvidia-utils`, `lib32-vulkan-icd-loader`
- [x] Single active GPU (NVIDIA, BIOS setting) → no `prime-run` needed
- [x] Steam Play enabled for all titles, **Proton Experimental** by default
- Useful tools: `protontricks` (Windows components for a game), `protonup-qt` (GE-Proton builds)

### 😴 Sleep and frozen screen
- [x] Cause: `PreserveVideoMemoryAllocations=1` **without** the NVIDIA sleep services → frozen screen on wake-up
- [x] `nvidia-suspend`, `nvidia-resume`, `nvidia-hibernate` enabled
- [x] Serpantinum (`settings.json`): automatic screen-off and sleep **disabled** (dim and lock kept)
- [x] Even with the services, wake-up could fail (`Failed to apply atomic modeset`): driver issue under Wayland
- [x] Sleep came from the **lid / sleep key** (logind), not from Serpantinum
- [x] `/etc/systemd/logind.conf.d/no-suspend.conf`: sleep key ignored; lid on AC = nothing system-side; lid on battery = suspend
- [x] Serpantinum's lock screen ignores logind's lock signal → Hyprland locks on `switch:on:Lid Switch`
- [x] NVIDIA sleep fix: `hyprland-suspend` / `hyprland-resume` pause Hyprland during sleep
- [x] Tested: lid closed on battery → wake-up without freeze

### ⌨️ Text-editor-style zsh
- [x] Delete, Ctrl + Delete, Ctrl + Backspace, Home / End
- [x] Selection: Shift + ←/→, Ctrl + Shift + ←/→ (kitty: `no_op` to free these keys), Ctrl + A, typing replaces the selection
- [x] Same selection color for keyboard and mouse ("neon" cyan)
- [x] Lesson: pasting into nano once **truncated** `.zshrc` → long files are delivered as files and checked with `tail`

### 💾 Backup improvements
- [x] Serpantinum settings saved **without the location** (IP, GPS)
- [x] Enabled services (system and user) and `gsettings` saved

### 🔒 Fingerprint on the lock screen (`SUPER + L`)
- [x] Serpantinum has **no** fingerprint option (it only uses the `login` PAM service)
- [x] `/etc/pam.d/serpantinum-fprint` + `patch-lock.py`: the reader listens in parallel with the password field
- [x] Animation: pulsing cyan ring → magenta check mark, red shake if the finger is rejected
- ⚠️ Re-run after a Serpantinum update

### 🗜️ Archives in Dolphin
- [x] `ark` was removed by the KDE cleanup → no more "Compress / Extract" on right-click
- [x] `sudo pacman -S --needed ark 7zip unrar`
- [x] Outside Plasma, Dolphin doesn't pick up new plugins by itself: `killall dolphin && kbuildsycoca6 --noincremental`

### 🔌 SSH from kitty ("Error opening terminal: xterm-kitty")
- [x] Remote machines don't know kitty's terminal type → nano, htop, vim refuse to start
- [x] `.zshrc`: `alias ssh='TERM=xterm-256color ssh'` (also works with `sudo` on the remote side)

### 🎯 Cursor: back to Chroma S only
- [x] A Bibata-based theme with an RGB outline (`Bibata-Nebula-Cross`) was tried, then dropped: Chroma S is the only cursor theme
- [x] Mixed cursors across apps and monitors came from different settings in `env.lua` / GTK `settings.ini` / `gsettings`: all three now say `ChromaS`
- [x] Remaining wrong cursor over Serpantinum's surfaces (main monitor): Quickshell is a systemd service and doesn't see Hyprland's `XCURSOR_THEME` → `~/.config/environment.d/cursor.conf` + `~/.icons/default/index.theme`

### 🖥️ Two machines
- [x] Hostnames `rotten-laptop` and `rotten-desktop` (hyphens: `_` is not valid in a hostname)
- [x] Hyprland: `config/monitors.lua` loads `config/hosts/<hostname>.lua`; unknown hostname → automatic setup
- [x] `backup-rice.sh` stores `system/<hostname>/` and `packages/<hostname>/` (including `/etc/fstab`); `home/` is shared
- [x] `save-all.sh` installs changes made on the other machine but **never overwrites** a file modified locally in the meantime
- Storage: **laptop** = 2 NVMe drives (system + separate `/home`) · **desktop** = 1 TB NVMe (system and `/home`) + 3 TB NTFS data disk mounted on `/mnt/data`
- [x] Desktop: Arch + Serpantinum installed, `nvidia-580xx-dkms` driver (GTX 1080 Ti) with `linux-headers`, `kms` hook removed
- [x] Desktop monitors in `hosts/rotten-desktop.lua`: iiyama PL2770H (HDMI-A-2, 1920x1080 @ 165 Hz, left) + MSI G32CQ5P (DP-2, 2560x1440 @ 165 Hz, right)
- [x] ~~**Workspaces spanning both monitors**~~ (workspace N = N on the MSI + N + 10 on the iiyama): tried, then removed; each monitor has its own workspaces again (Hyprland default)
- [x] Desktop: hyprmod wrote its own monitor rule in `hyprland-gui.lua` (loaded last) with a 640 px gap between the screens → the cursor could not cross; monitor rules now only live in `hosts/rotten-desktop.lua`, iiyama at 180 Hz
- [x] ~~Desktop: logging out of Hyprland gave a black screen and a hard freeze (NVIDIA + SDDM)~~: gone with the NVIDIA card
- [x] First desktop backup; Serpantinum's code (`~/.local/share/serpantinum`, `~/.local/state/serpantinum`) removed from the backup: each machine may run a different version, the installer provides it and `patch-*.py` reapply the changes
- [x] Desktop: data disk mounted with `ntfs-3g` (`ntfs3` refuses it: damaged `$BadClus`, chkdsk not available anymore)
- [x] Desktop: MSI set as the XWayland primary monitor (`xrandr --primary` at startup) so games open on it
- [x] kitty font: `JetBrainsMono Nerd Font` (the only JetBrains package installed on both machines)
- [x] ~~Desktop: `ntfs3` line in `/etc/fstab`~~: `ntfs-3g` kept on purpose (`ntfs3` refuses the damaged volume)

### 🎚️ Audio routing (Voicemeeter replacement)
- [x] Voicemeeter setup translated to PipeWire (`pipewire.conf.d/10-nebula-mixer.conf`): **Music** virtual sink → headset, **Microphone (Nebula)** virtual source = microphone + 5 dB
- [x] EQ, compressor and gate were disabled in Voicemeeter: nothing to reproduce
- [x] Cleaner and louder microphone: RNNoise noise suppression (`noise-suppression-for-voice`), 80 Hz high-pass, warmth / clarity shelves approximating the Voicemeeter color panel, +5 dB gain
- [ ] Tune the EQ by ear (Gain values in the filter chain)

### 🌐 Repository in English
- [x] Code comments, script messages, README and this roadmap translated to English

### 🎮 Games and the Quick Actions panel
- [x] Quick actions panel (screen edges) opening over fullscreen games → first a `game-mode` script + `SUPER + G` (Serpantinum's `general.performance`), then removed: Quick Actions is simply disabled (`general.quickactions = false`)
- [x] Mouse clicks not reaching a Proton game on the right monitor (XWayland, monitor not at `0x0`) → Gamescope in Heroic (`Force Grab Cursor`); game removed since, Gamescope not kept
- [x] `save-all.sh` installs scripts of the repository that are missing from `~` (a new script was skipped because the running `save-all.sh` still had the old list)
- [x] A manual `git pull` before `save-all.sh` hid the new changes: they weren't installed and the backup pushed the old files from `~` back over them (desktop host file, keybinds, `.zshrc`, `save-all.sh`, Serpantinum settings). Files restored; `save-all.sh` now remembers the last commit each machine synced (`~/.local/state/save-all/last-sync`) and installs everything changed since
- [x] VPN aliases `vpn-on` / `vpn-off` / `vpn-status` in `.zshrc` (connection named `VPN`)
- [x] `check-rice.sh`: check-up after an update (Hyprland config, Serpantinum patches, SDDM theme, settings, kitty / fastfetch / cava, cursor, kernel) (since then it fixes by itself, see below)
- [x] Serpantinum 2.2.5 update: installer read; `Update` keeps `~/.config/hypr` and `settings.json`, but the SDDM option resets the greeter to `material-you`, and code patches must be re-applied (`patch-topbar.py` still applies to 2.2.5)

### 🔁 Desktop GPU swap (GTX 1080 Ti → RX 5700 XT)
- [x] NVIDIA legacy driver removed, Mesa + `vulkan-radeon` installed
- [x] Monitors matched by model (`desc:`) instead of port names, which changed with the card (`DP-2` / `HDMI-A-2` → `DP-3` / `HDMI-A-1`); the XWayland primary monitor resolves the port at runtime
- [x] `kms` back in `HOOKS`, `vulkan-nouveau` removed
- [x] Pitfall: the monitor file is picked from `/etc/hostname`; a renamed machine silently falls back to automatic monitors (60 Hz, wrong layout)

### 🔎 File search (everythingx)
- [x] `everythingx-bin` (AUR) + `everythingxd.service` indexer; noted in `docs/arch-notes.md` (first scan, restarts, `ntfs-3g` drives not watched in real time)

### 🔄 Serpantinum 2.2.7
- [x] Update with the SDDM option off: greeter kept on `nebula`
- [x] The top bar now lines up against the `SUPER + E` panel natively: `patch-topbar.py` and `check-rice.sh` detect it and skip the patch
- [x] `patch-lock.py` still applies to 2.2.7

### 📶 Desktop Wi-Fi / Bluetooth card
- [x] ASUS PCE-AX1800 (MediaTek MT7921, `mt7921e` in the kernel): Wi-Fi and Bluetooth work without extra drivers (Bluetooth needs the card's USB cable on an internal USB 2.0 header)
- [x] Ly had replaced SDDM as display manager on the desktop: SDDM re-enabled; `check-rice.sh` now checks `display-manager.service`
- [x] Wi-Fi on the 5 GHz band

### 🔄 Serpantinum 2.3.0
- [x] Fingerprint unlock is now built into the lock screen (`/etc/pam.d/serpantinum`): `patch-lock.py` and `check-rice.sh` detect it and skip the patch
- [x] `check-rice.sh` fixes by itself what needs no sudo (patches on older versions, Quick Actions / dock off, cursor `gsettings`, Serpantinum reload); `--check` only reports; `save-all.sh` runs it before every backup

### 🧹 Dock
- [x] A Serpantinum update re-enabled the dock on the laptop (bottom center): disabled (`dock.enabled = false`), `check-rice.sh` now checks it

### ⌨️ Lily58 on three computers
- [x] Profiles: Lower + 1 desktop, Lower + 2 personal laptop, Lower + 3 work laptop
- [x] "Connected but no key works" on the laptop: `input-hog profile accept failed` in the Bluetooth log, `uhid` couldn't load because the kernel had been updated without a reboot; reboot fixed it
- [x] Same Bluetooth address on every ZMK profile: always `remove` on the computer before pairing on a new profile (`docs/arch-notes.md`)
- [x] Personal and work laptops paired on profiles 2 and 3: switching between them works
- [ ] Pair the desktop on profile 1 (`remove` first)

### 📱 Tablet as a third monitor (desktop)
- [x] Virtual `TABLET` monitor (2000×1200 @ 120 Hz, scale 1.25) created / removed by `tablet-screen`, driven by Sunshine's `prep-cmd` (Moonlight start / quit)
- [x] `scripts/setup-tablet.sh` + `docs/tablet-screen.md`; Sunshine config backed up (`sunshine.conf`, `apps.json`, no credentials)
- [ ] First run when the tablet arrives: pick the `TABLET` display in Sunshine, check touch mapping and 120 FPS
- [ ] NZXT Capsule Elite microphone: set as default source, tune the "Microphone (Nebula)" gain by ear

### ⌨️ Shortcuts and cheatsheet
- [x] Every bind in `keybinds.lua` has a `description` ("Section: action"), the single source for the menu and the image
- [x] `SUPER + K`: searchable menu (`~/.local/bin/keybinds-menu`, `hyprctl binds -j` + `keybinds-extra.tsv`, fuzzel with a Nebula theme)
- [x] `assets/cheatsheet.png` generated by `scripts/make-cheatsheet.py` (HTML in vw units, rendered in headless Chromium)
- [x] New binds: `SUPER + SHIFT + S` screenshot, `SUPER + ALT + arrows / M` media and volume (keyboards without media keys), `SUPER + SHIFT + Esc` log out, `SUPER + SHIFT + N` notifications, `SUPER + SHIFT + B` blue light filter, `ALT + Tab`, `SUPER + SHIFT + C` center, `SUPER + SHIFT + P` pin, `SUPER + J` split, `SUPER + X` / `SUPER + SHIFT + X` scratchpad; `SUPER + L` no longer repeats
- [ ] Lily58 keymap: media, volume and Print keys on a layer (later, from the desktop)
- [ ] ZMK dongle for the Lily58: a third nice!nano v2 as central, both halves reflashed as peripherals; illustrated guide in `docs/zmk-dongle.md`. A nice!view is not plug-in on a bare nice!nano (adapter PCB or soldering)

### 📒 Guides (`docs/`)
- [x] `arch-notes.md`: personal notes cleaned up and generalized (rsync, NTFS drive, yay, kernel updates, monitors, GTK dark mode, fingerprint, ZMK pairing, Caelestia, WSL + Kali, resources)
- [x] `vpn-ikev2-eap.md`: strongSwan IKEv2 / EAP VPN with `nmcli`, for organizations that only document Ubuntu / Debian
- [x] VPN failure "did not start in time" traced to a kernel update without reboot (`xfrm_user` missing for the running kernel)

### 🔥 Desktop GPU hangs (RX 5700 XT)
- [x] Diagnosed: `ring gfx_0.0.0 timeout` in Hyprland → GPU reset (`VRAM is lost`) → Hyprland restarts in safe mode; only a full power-off recovers
- [x] First fix: GFXOFF disabled (`amdgpu.ppfeaturemask=0xfff73fff` in `/etc/kernel/cmdline`, `mkinitcpio -P`)
- [x] Temperatures fine (50 °C idle, no thermal event in the log); GFXOFF fix confirmed active in `/proc/cmdline`
- [x] New clue: the hang starts with a GPU **page fault from Hyprland** (`[gfxhub] page fault … Process Hyprland`, `GCVM_L2_PROTECTION_FAULT`), not from the game; not the anti-cheat
- [x] Test in progress: Hyprland color management off on the desktop (`hl.config({ render = { cm_enabled = false } })` at the end of `hosts/rotten-desktop.lua`, needs a re-login)
- [x] Shader cache for every game: `MESA_SHADER_CACHE_MAX_SIZE=12G` in `~/.config/environment.d/mesa.conf` (the NVIDIA-only `__GL_SHADER_DISK_CACHE_SIZE` launch option removed)
- [ ] If it still crashes, one at a time: (1) GameMode raising the GPU to `high` only while playing (`gamemode` + `lib32-gamemode`, `~/.config/gamemode.ini` with `[gpu] apply_gpu_optimisations=accept-responsibility`, `gpu_device=1`, `amd_performance_level=high`, launch option `gamemoderun %command%`); (2) test without the `nvidia-like.glsl` screen shader (the maintainer prefers to keep it for now); (3) a hardware fault of the card
- [ ] When the game freezes without crashing the session: `journalctl -k -b | grep -E "amdgpu.*(timeout|reset|fault)"`; no line = not the GPU (look at network / CPU)
- [ ] Once stable: save `/etc/kernel/cmdline` in `backup-rice.sh`

### ⌨️ Lily58 wishes
- [ ] Typeractive asked (hotswap, switches, RGB, dongle, warranty): waiting for the answer
- [x] PCB confirmed **hotswap** (Kailh Choc sockets under every key, "Lily58 PCB by kata0510, wireless-ified by Nice!keyboards"): no RGB LEDs
- [ ] Try other **Kailh Choc v1** switches (switch puller, pull straight up)
- [x] Custom nice!view screens in the keymap repository ([rotten_lily58_keymap_config](https://github.com/PoUrRiTuRe/rotten_lily58_keymap_config), `nice_view_rotten` shield): classic bongo cat instead of the WPM graph on the left half, spinning wireframe cube on the right half (rest of both screens unchanged)
- [x] Layer pictures (Nebula theme) in `docs/lily58.md`, drawn from the keymap by `assets/keymap/make-keymap.py`
- [x] Flashed: bongo cat approved; colors fixed for the dark screen (cat and cube in the light foreground color)
- [x] Color fix and bigger cube flashed: approved
- [x] Paws follow the half of the key, cube loops without a jump: flashed
- [x] ~~Paw reaching further for the top rows~~: dropped (looked like a glitch), original frames kept
- [x] Mirrored paws, double letters show two taps: flashed
- [x] Paw down at once and held with Ctrl, right screen with Arch logo / cube / atom in a ring: flashed, approved
- [x] Hold follows the last key only, visible lift when hammering a key: built (fixed a name clash on the first build)
- [x] Paired with the phone too, just for fun: Bluetooth profile 4 (`Lower + 4`)
- [x] Delete on the lower layer (left inner key, `[` on the base layer)
- [ ] ~~"croissant_croissant" Rick Roll prank on both screens~~: dropped (heavy for little use, battery)
- ℹ️ Battery: current settings kept (cube speed, screen off after 30 s idle). Give feedback after a while of use; if the battery drains too fast, then look at deep sleep (`CONFIG_ZMK_SLEEP=y`) or a slower cube
- [x] Right screen layout approved (mockup v3, atom in a ring) and built: Arch logo, cube, atom, same gap everywhere
- [ ] Maybe: the cube speeding up while typing on the right half
- ℹ️ Graphic changes on the screens: always show a mockup and wait for approval before changing the firmware
- ℹ️ With the dongle, both halves are peripherals: the bongo cat (which needs the key events of the central) would be replaced by the cube screen on both halves
- ℹ️ With the dongle as central, both halves become equal peripherals: the right half works without the left one
- [ ] Future keyboard: RGB that turns on only when asked **and** when the battery is above ~33 %; magnetic (Hall effect) low-profile switches with rapid trigger. Not possible on this PCB (no LEDs, no magnetic sensors); ZMK barely supports magnetic switches

---

## 🔍 Open points

- [ ] **`~` shows `master ?`** in the prompt: the home folder is a git repository (probably by mistake). Check with `ls -la ~/.git` **without deleting anything**
- [ ] **`hyprpolkitagent` at startup**: check after a reboot with `pgrep -a hyprpolkitagent`
- [ ] **kitty `fullscreen_state` rule**: remove once kitty fixes the bug
- [ ] **System files translated in the repository** (SDDM theme, logind, suspend service): copy them back to the system once, otherwise the next backup restores the old comments

## ✨ Ideas

- [ ] LazyVim: Nebula color scheme
- [ ] GTK windows: Nebula colors (`gtk.css`)

## 💤 Set aside

- Animated wallpaper (Wallpaper Engine)
- Timeshift (automatic snapshots before updates)
- Switching to fish
- Migrating to CachyOS
- Fingerprint on the greeter without pressing Enter

---

## 🧰 Scripts (`scripts/`)

| Script | Purpose |
|---|---|
| `check-rice.sh` | Check-up after an update (what was reset, how to fix it) |
| `save-all.sh` | One-command backup: pulls GitHub **and installs changed config and scripts into `~`** (system files are only listed), moves downloaded files, copies the scripts, runs the backup |
| `backup-rice.sh` | Copies everything to `~/dotfiles-backup`, then commit + push |
| `nebula-kvantum.sh` | Creates the Nebula Kvantum theme for Dolphin |
| `nebula-colors.sh` | Creates the Nebula KDE color scheme and forces it in Dolphin |
| `kde-cleanup-preview.sh` | Dry run of the KDE / GNOME cleanup, with a list of protected packages |
| `patch-topbar.py` | Fixes the Serpantinum top bar (`--restore` to undo) |
| `patch-lock.py` | Fingerprint + animation on the lock screen (`--restore` to undo) |
| `patch-greeter.py` | Fingerprint animation on the SDDM greeter (`--restore` to undo) |

## 📄 Modified files

| File | Why |
|---|---|
| `~/.config/hypr/config/keybinds.lua` | native workspaces, `SUPER + Tab`, `SUPER + F` → Dolphin |
| `~/.config/hypr/config/settings.lua` | borders, animations, shader, kitty rule |
| `~/.config/hypr/config/env.lua` | cursor, Qt (Dolphin), dark GTK, "Open with" menu |
| `~/.config/hypr/config/monitors.lua` + `hosts/` | monitors per machine |
| `~/.config/hypr/shaders/nvidia-like.glsl` | screen colors |
| `~/.config/kitty/kitty.conf` | zoom, scrollback copy, `allow_remote_control`, selection color, Ctrl + Shift + ←/→ freed |
| `~/.config/fastfetch/perso.jsonc` | fastfetch config |
| `~/.config/eza/theme.yml` | `ls` colors |
| `~/.config/nano/nanorc` | nano colors |
| `~/.config/nvim/` | LazyVim |
| `~/.config/Kvantum/`, `qt6ct/`, `kdeglobals`, `dolphinrc` | Dolphin theme |
| `~/.local/share/color-schemes/Nebula.colors` | KDE color scheme |
| `~/.config/gtk-3.0/`, `gtk-4.0/` | dark GTK windows, icons, cursor |
| `~/.config/environment.d/gtk.conf` | `GTK_THEME` for the portal |
| `~/.config/pipewire/pipewire.conf.d/10-nebula-mixer.conf` | virtual Music sink and Microphone (Nebula) source |
| `~/.local/share/applications/nvim.desktop` | Neovim from the launcher |
| `~/.local/share/icons/ChromaS/` | cursor |
| `~/.local/share/serpantinum/.../TopBar.qml` | fixed bar (via `patch-topbar.py`) |
| `~/.local/share/serpantinum/.../Lock.qml` | fingerprint + animation (via `patch-lock.py`) |
| `~/.zshrc` | fastfetch, eza, plugins, editing keys, selection, full `clear` + `Ctrl + L`, SSH alias |
| `~/.config/serpantinum/settings.json` | screen-off and sleep disabled (saved without the location) |
| `/etc/fstab` | mounted drives (per machine) |
| `/etc/pam.d/sddm`, `/etc/pam.d/sudo` | password + fingerprint |
| `/etc/pam.d/serpantinum-fprint` | fingerprint on the lock screen |
| `/etc/systemd/logind.conf.d/no-suspend.conf` | lid and sleep key: no suspend on AC |
| `/etc/systemd/system/hyprland-{suspend,resume}.service`, `/usr/local/bin/suspend-hyprland.sh` | Hyprland paused during sleep (NVIDIA freeze fix) |
| `/etc/sddm.conf.d/`, `/usr/share/sddm/themes/nebula/` | greeter |
| `/var/lib/bluetooth/` | Bluetooth pairings |
| `nvidia-suspend/resume/hibernate` services | wake-up from sleep (not a file: see README, "Services") |
| **`gsettings`** (not a file) | GTK: dark theme, Papirus icons, cursor → set by hand (see README) |
