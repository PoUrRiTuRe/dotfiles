# Roadmap — "Nebula" Hyprland rice

> Arch Linux · Hyprland 0.56 (Lua config) · Serpantinum · cyan / magenta theme
> Machines: `rotten-laptop` (ThinkPad P53) · `rotten-desktop` (desktop PC, planned)
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
- [ ] **To test**: lid closed on battery → wake-up without freeze. Otherwise: `HandleLidSwitch=lock`

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

### 🎯 Cursor: Bibata + RGB outline
- [x] `Bibata-Nebula-Cross` theme: **Bibata Modern Classic** (black, rounded, white outline) with its own **crosshair** as the main pointer
- [x] **Animated RGB outline** on every cursor (~2.3 s per loop), in the style of the Windows *Chroma* pack
- [x] **Busy** cursor (`wait`, `progress`, `left_ptr_watch`): hourglass + crosshair + Chroma's spinning rainbow ring
- [x] Built by `scripts/make-cursors.py`, sizes 24 / 32 / 48
- [x] The previous Chroma S theme is still installed

### 🖥️ Two machines
- [x] Hostnames `rotten-laptop` and `rotten-desktop` (hyphens: `_` is not valid in a hostname)
- [x] Hyprland: `config/monitors.lua` loads `config/hosts/<hostname>.lua`; unknown hostname → automatic setup
- [x] `backup-rice.sh` stores `system/<hostname>/` and `packages/<hostname>/` (including `/etc/fstab`); `home/` is shared
- [x] `save-all.sh` installs changes made on the other machine but **never overwrites** a file modified locally in the meantime
- Storage: **laptop** = 2 NVMe drives (system + separate `/home`) · **desktop** = 1 TB NVMe (system and `/home`) + 3 TB NTFS data disk mounted on `/mnt/data`
- [x] Desktop: Arch + Serpantinum installed, `nvidia-580xx-dkms` driver (GTX 1080 Ti) with `linux-headers`, `kms` hook removed
- [x] Desktop monitors in `hosts/rotten-desktop.lua`: iiyama PL2770H (HDMI-A-2, 1920x1080 @ 165 Hz, left) + MSI G32CQ5P (DP-2, 2560x1440 @ 165 Hz, right)
- [x] **Workspaces spanning both monitors**: workspace N = pair (N on the MSI, N + 10 on the iiyama); `SUPER + N`, `SUPER + SHIFT + N` and `SUPER + Tab` act on both screens (Lua functions in the host file, `keybinds.lua` skips its own workspace keys)
- [x] Desktop: MSI set as the XWayland primary monitor (`xrandr --primary` at startup) so games open on it
- [x] kitty font: `JetBrainsMono Nerd Font` (the only JetBrains package installed on both machines)
- [ ] Desktop: `ntfs3` line in `/etc/fstab` for the data disk

### 🎚️ Audio routing (Voicemeeter replacement)
- [x] Voicemeeter setup translated to PipeWire (`pipewire.conf.d/10-nebula-mixer.conf`): **Music** virtual sink → headset, **Microphone (Nebula)** virtual source = microphone + 5 dB
- [x] EQ, compressor and gate were disabled in Voicemeeter: nothing to reproduce
- [x] Cleaner and louder microphone: RNNoise noise suppression (`noise-suppression-for-voice`), 80 Hz high-pass, warmth / clarity shelves approximating the Voicemeeter color panel, +5 dB gain
- [ ] Tune the EQ by ear (Gain values in the filter chain)

### 🌐 Repository in English
- [x] Code comments, script messages, README and this roadmap translated to English

---

## 🔍 Open points

- [ ] **`~` shows `master ?`** in the prompt: the home folder is a git repository (probably by mistake). Check with `ls -la ~/.git` **without deleting anything**
- [ ] **`hyprpolkitagent` at startup**: check after a reboot with `pgrep -a hyprpolkitagent`
- [ ] **Keyring** not unlocked after a fingerprint login (browser password store)
- [ ] **kitty `fullscreen_state` rule**: remove once kitty fixes the bug
- [ ] **System files translated in the repository** (SDDM theme, logind, suspend service): copy them back to the system once, otherwise the next backup restores the old comments

## ✨ Ideas

- [ ] LazyVim: `:LazyExtras` → `lang.java`
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
| `save-all.sh` | One-command backup: pulls GitHub **and installs changed config and scripts into `~`** (system files are only listed), moves downloaded files, copies the scripts, runs the backup |
| `backup-rice.sh` | Copies everything to `~/dotfiles-backup`, then commit + push |
| `nebula-kvantum.sh` | Creates the Nebula Kvantum theme for Dolphin |
| `nebula-colors.sh` | Creates the Nebula KDE color scheme and forces it in Dolphin |
| `make-cursors.py` | Builds the Bibata-Nebula-Cross cursor theme |
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
| `~/.local/share/icons/Bibata-Nebula-Cross/` | current cursor |
| `~/.local/share/icons/ChromaS/` | previous cursor |
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
