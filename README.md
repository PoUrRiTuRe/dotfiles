<div align="center">

# 🌌 rotten_dotfiles

**A neon cyan / magenta Hyprland rice, set against a nebula.**

*Arch Linux · Hyprland 0.56 (Lua config) · Serpantinum · ThinkPad P53*

</div>

---

## ✨ Features

| | Component | Details |
|---|---|---|
| 🔐 | **`nebula` SDDM greeter** | Custom cyan / magenta theme on a nebula wallpaper, neon clock with a glow, login with **password or fingerprint** |
| 🌈 | **Animated borders** | Cyan → magenta gradient that rotates continuously at a constant speed, with a smooth fade when focus changes |
| 🎯 | **Chroma S cursor** | Precision crosshair with an animated RGB outline (*Chroma Cursors S* pack by Glimy, converted from Windows), smoothed animation |
| 🎨 | **"NVIDIA-style" colors** | Screen shader replicating the NVIDIA Control Panel: brightness 60 / contrast 65 / digital vibrance 85 |
| ⚡ | **Instant workspaces** | `SUPER + 1…0` bound directly to Hyprland's dispatchers, no latency |
| 🖥️ | **Terminal** | kitty + zsh + starship + a custom fastfetch |
| 🎧 | **Bluetooth** | Saved pairings (Sony WH-1000XM4 headphones) |

---

## 🖼️ Preview

### Terminal & top bar

![Terminal and top bar](assets/terminal.png)

kitty with zsh, a starship prompt and a custom fastfetch, under Serpantinum's top bar (workspaces, media player, clock, weather, Wi-Fi, Bluetooth, battery).

### Greeter

![nebula SDDM greeter](assets/greeter.png)

The `nebula` SDDM theme: neon clock (cyan hours, magenta minutes, with a glow), dark translucent cards over the nebula wallpaper, and quick power / session actions. Log in by typing your password, **or** leave the field empty, press Enter and touch the fingerprint reader.

### Not pictured (it moves!)

- **Window borders**: a thin cyan → magenta gradient slowly spins around the focused window (one full turn every ~10 s, linear speed so it never jerks), and fades smoothly to grey when the window loses focus.
- **Cursor**: a small black precision crosshair whose outline cycles through RGB colors in a smooth loop (~2.3 s per cycle). Every other cursor state (link, text, busy, resize…) comes from the same Chroma pack and is animated too.
- **Colors**: the screen shader makes everything more vivid, like NVIDIA's *Digital Vibrance* on Windows, without burning already-saturated colors.

---

## 📁 Repository layout

```
dotfiles/
├── README.md
├── assets/                  # README screenshots
├── home/                    # everything that goes into ~
│   ├── .config/hypr/        # Hyprland: Lua config, keybinds, borders, shader
│   ├── .config/kitty/
│   ├── .config/fastfetch/   # perso.jsonc = the real config
│   ├── .config/cava/
│   ├── .config/starship.toml
│   ├── .local/share/serpantinum/
│   ├── .local/share/icons/ChromaS/
│   ├── .zshrc
│   └── Pictures/Wallpapers/
├── system/                  # system files (copy with care)
│   ├── etc/pam.d/sddm       # password first, then fingerprint
│   ├── etc/pam.d/sudo       # fingerprint for sudo
│   ├── etc/sddm.conf.d/     # enables the nebula theme
│   ├── usr/share/sddm/themes/nebula/
│   └── var/lib/bluetooth/   # pairings (only valid on this machine)
├── packages/
│   ├── pacman.txt           # installed official packages
│   └── aur.txt              # installed AUR packages
└── LAST_BACKUP.txt
```

The repository is kept up to date by the `backup-rice.sh` script (backup + commit + push).

---

## 📦 Requirements

For a fresh install of Arch Linux or an Arch-based distro (CachyOS, …).

### Required

| Package | Purpose |
|---|---|
| `hyprland` (≥ 0.56) | Compositor. **The config is written in Lua**: older versions won't read it |
| Serpantinum | Top bar, menus, notifications, matugen (see its own repository for installation) |
| `kitty` | Terminal |
| `zsh` · `starship` · `fastfetch` | Shell, prompt, system info on startup |
| `sddm` · `qt6-5compat` | Display manager + graphical effects used by the `nebula` theme |
| `pipewire` · `pipewire-pulse` · `wireplumber` | Audio (Bluetooth included) |
| `bluez` · `bluez-utils` | Bluetooth |
| `wl-clipboard` · `playerctl` | Clipboard and media controls |
| `ttf-jetbrains-mono-nerd` | Terminal font and icons |
| `git` · `openssh` | Clone and update this repository |

### Optional

| Package | Purpose |
|---|---|
| `fprintd` | Fingerprint login and `sudo` |
| `hyprshade` *(AUR)* | Toggle the color shader on the fly |
| `cava` | Audio visualizer |
| `nvidia` · `nvidia-utils` | Drivers for NVIDIA GPUs |

```bash
sudo pacman -S --needed hyprland kitty zsh starship fastfetch sddm qt6-5compat \
  pipewire pipewire-pulse wireplumber bluez bluez-utils wl-clipboard playerctl \
  ttf-jetbrains-mono-nerd git openssh fprintd cava
yay -S hyprshade
```

> 💡 `packages/pacman.txt` and `packages/aur.txt` list **everything** that was installed, including fallback sessions (KDE, GNOME). Use them as a reference, not as a list to install in one go.

---

## 🚀 Installing on a fresh system

### 1. Clone the repository

```bash
git clone git@github.com:PoUrRiTuRe/dotfiles.git ~/dotfiles-backup
cd ~/dotfiles-backup
```

### 2. User config

Install **Serpantinum cleanly first**, then copy the config on top:

```bash
cp -a home/.config/hypr home/.config/kitty home/.config/fastfetch home/.config/cava ~/.config/
cp -a home/.config/starship.toml ~/.config/
cp -a home/.zshrc ~/
mkdir -p ~/.local/share/icons ~/Pictures
cp -a home/.local/share/icons/ChromaS ~/.local/share/icons/
cp -a home/Pictures/Wallpapers ~/Pictures/
chsh -s /usr/bin/zsh      # if zsh isn't the default shell (CachyOS uses fish)
```

> ⚠️ Don't copy `home/.local/share/serpantinum` over a newer version of Serpantinum. Reapply the tweaks by hand instead (see [Tweaks](#-tweaks)).

### 3. `nebula` SDDM greeter

```bash
sudo cp -a system/usr/share/sddm/themes/nebula /usr/share/sddm/themes/
sudo cp -a system/etc/sddm.conf.d /etc/
sudo systemctl enable sddm
```

### 4. Fingerprint *(optional)*

Don't replace the new distro's PAM files: **add** these two lines at the very top of the `auth` section of `/etc/pam.d/sddm`:

```
auth  [success=1 new_authtok_reqd=1 default=ignore]  pam_unix.so  try_first_pass likeauth nullok
auth  sufficient  pam_fprintd.so
```

Then enroll your finger with `fprintd-enroll`. At the greeter: password + Enter, **or** empty field + Enter, then your finger.

### 5. Bluetooth *(same machine only)*

```bash
sudo systemctl stop bluetooth
sudo cp -a system/var/lib/bluetooth/. /var/lib/bluetooth/
sudo systemctl enable --now bluetooth
```

### 6. Reboot 🎉

---

## 🔧 Tweaks

The changes that make this rice, to reapply if you switch shells or versions:

- **Latency-free workspaces**: in `keybinds.lua`, use `hl.dsp.focus({ workspace = i })` instead of `serpantinum msg workspace`.
- **Borders**: `border` (`smooth` curve) and `borderangle` (`linear` curve, `style = "loop"`) animations in `settings.lua`.
- **Colors**: `screen_shader` in `settings.lua` → `~/.config/hypr/shaders/nvidia-like.glsl`. The three values sit at the top of the file; run `hyprctl reload` after editing it.
- **Cursor**: `XCURSOR_THEME=ChromaS` and `XCURSOR_SIZE=32` in `env.lua`.
- **fastfetch**: matugen overwrites `config.jsonc`, so the real config is `perso.jsonc`, launched from `.zshrc` with `fastfetch --config`.
- **kitty**: `fullscreen_state = "0 0"` window rule, a workaround for the kitty bug that opens it maximized ([kitty#10442](https://github.com/kovidgoyal/kitty/issues/10442)). Remove it once the bug is fixed.

---

## 🙏 Credits

- [Hyprland](https://hyprland.org) · Serpantinum
- **Chroma Cursors S** cursors by **Glimy**, converted to the Linux format for personal use. Check the pack's license before making this repository public.
- `nebula` SDDM theme: modified from the `material-you` theme shipped with Serpantinum.
