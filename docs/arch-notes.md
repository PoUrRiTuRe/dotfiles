# 📒 Arch Linux notes

Short, tested recipes collected while building this rice. Replace the `<placeholders>` with your own values.

- [Back up `~` with rsync](#back-up--with-rsync)
- [Mount a second (NTFS) drive at boot](#mount-a-second-ntfs-drive-at-boot)
- [Install yay (AUR helper)](#install-yay-aur-helper)
- [Reboot after a kernel update](#reboot-after-a-kernel-update)
- [Monitors: hyprlang vs Lua config](#monitors-hyprlang-vs-lua-config)
- [Dark mode for GTK apps (Nautilus…)](#dark-mode-for-gtk-apps-nautilus)
- [Fingerprint reader](#fingerprint-reader)
- [Instant file search (everythingx)](#instant-file-search-everythingx)
- [Re-pair a ZMK Bluetooth keyboard](#re-pair-a-zmk-bluetooth-keyboard)
- [Switch from Serpantinum to another shell (Caelestia)](#switch-from-serpantinum-to-another-shell-caelestia)
- [Debian / Kali with a GUI on Windows (WSL)](#debian--kali-with-a-gui-on-windows-wsl)
- [University / company VPN (IKEv2, EAP)](#university--company-vpn-ikev2-eap)
- [Resources](#resources)

---

## Back up `~` with rsync

Always run a dry run first (`--dry-run` lists what would be copied, copies nothing):

```bash
rsync -avh --dry-run --progress ~/ /mnt/<drive>/<backup-folder>/
rsync -avh --progress ~/ /mnt/<drive>/<backup-folder>/
```

The trailing `/` on `~/` matters: it copies the *content* of the home folder, not a `home/<user>` folder inside the destination.

## Mount a second (NTFS) drive at boot

```bash
sudo pacman -S ntfs-3g
lsblk -f                      # or: sudo blkid — note the UUID of the partition
sudo mkdir -p /mnt/<drive>
sudo nano /etc/fstab
```

Add one line (`uid` / `gid` = your user, see `id`):

```
UUID=<uuid>  /mnt/<drive>  ntfs-3g  rw,uid=1000,gid=1000,umask=022,windows_names,nofail  0  0
```

- `nofail`: the system still boots if the drive is missing.
- `windows_names`: refuses file names Windows can't read.

Apply without rebooting:

```bash
sudo systemctl daemon-reload
sudo mount -a
```

If the kernel log says `volume is dirty` (Windows fast startup, unclean shutdown): `sudo pacman -S ntfsprogs && sudo ntfsfix -d /dev/<partition>`, then mount again. Use `ntfs-3g`, not the in-kernel `ntfs3` driver, on a volume that keeps being marked dirty.

## Install yay (AUR helper)

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd .. && rm -rf yay-bin
```

`yay` is for AUR packages; official packages (`nano`, `ntfs-3g`…) can stay on `pacman`.

## Reboot after a kernel update

When `pacman -Syu` updates `linux`, the modules of the **running** kernel are deleted. Until you reboot, anything that loads a new kernel module fails (VPN, some USB devices or file systems), often with confusing errors such as `Protocol not supported` or `Module not found`.

```bash
uname -r              # running kernel
ls /usr/lib/modules/  # installed kernels: if the running one is missing, reboot
```

With a DKMS driver (`nvidia-*-dkms`), check it was rebuilt for the new kernel before rebooting: `ls /usr/lib/modules/<new-version>/updates/dkms/` should list `nvidia*.ko*` (otherwise `sudo dkms autoinstall`).

## Monitors: hyprlang vs Lua config

Hyprland before 0.56 (and setups such as Omarchy) use `hyprland.conf`:

```ini
# monitor = <output>, <resolution@rate>, <position>, <scale>
monitor = , 2560x1440@165, auto, 1           # every monitor, fixed mode
monitor = , preferred, auto, 1               # every monitor, best mode
monitor = DP-2, preferred, auto, 1, transform, 1   # rotated (1 = 90°, 3 = 270°)
monitor = DP-3, disable                      # ghost / unused output
env = GDK_SCALE,1                            # 2 for 2x (HiDPI) screens
```

The Lua config of this repository (Hyprland 0.56) writes the same thing as:

```lua
hl.monitor({ output = "", mode = "2560x1440@165", position = "auto", scale = 1.0 })
```

Per-machine monitors live in `home/.config/hypr/config/hosts/<hostname>.lua`. List outputs and modes with `hyprctl monitors all`. Positions must touch (no gap), otherwise the cursor can't cross between screens.

## Dark mode for GTK apps (Nautilus…)

```bash
sudo pacman -S xdg-desktop-portal-gtk
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
nautilus -q    # restart Nautilus
```

GTK 4 / libadwaita apps follow `color-scheme`; GTK 3 apps follow `gtk-theme`. Outside GNOME, also see the *GTK dialogs* tweak in the [README](../README.md#-tweaks) (`GTK_THEME` for the portal).

## Fingerprint reader

```bash
sudo pacman -S fprintd
fprintd-enroll      # enroll a finger
fprintd-verify      # test it
```

Then add `pam_fprintd` to the PAM services you want (SDDM, sudo, lock screen): see [README step 6](../README.md#6-fingerprint-optional). Add lines, don't replace the distribution's PAM files.

## Instant file search (everythingx)

[everythingx](https://aur.archlinux.org/packages/everythingx-bin) is an "Everything"-like search for Linux. It has two parts: a daemon that indexes the disks into a database, and the search tool that only reads that database.

```bash
yay -S everythingx-bin
sudo systemctl enable --now everythingxd.service
journalctl -u everythingxd -f
```

`everythingxd` (`d` = daemon) is the indexer; `journalctl -f` follows its first scan.

- `Database does not exist /var/lib/everythingx/files.db` means the daemon never ran: enable `everythingxd.service`.
- The first scan takes a while, and so does every restart of the daemon: empty results right after a restart usually just mean the scan isn't finished. Check with `ls -lh /var/lib/everythingx/` (database size) and `tail /var/log/everythingxd.log`.
- Search from the terminal: `everythingx -name <term>` (or `ev`).
- Drives mounted with `ntfs-3g` (FUSE) are indexed, but changes on them aren't picked up in real time. Unmounted drives aren't indexed at all.
- Don't paste shell commands with a trailing `# comment` into an interactive zsh: without `setopt interactive_comments`, the `#` is passed to the command as an argument.

## Re-pair a ZMK Bluetooth keyboard

Example: a Lily58 that keeps failing to authenticate, or shows a **gear** icon (the active profile has no pairing).

```bash
bluetoothctl
```

then, one line at a time:

```
remove <keyboard-MAC>
agent KeyboardDisplay
default-agent
scan on
```

On the keyboard: select the profile dedicated to this computer (e.g. Lower + 1 = profile 0), then clear it (`BT_CLR`; Lower + Esc on the default Lily58 keymap). When the keyboard shows up again:

```
pair <keyboard-MAC>
```

Type the 6-digit code **on the keyboard**, then Enter. Finish with:

```
trust <keyboard-MAC>
connect <keyboard-MAC>
scan off
exit
```

Use one profile per computer: pairing a second computer on the same profile breaks the first one.

## Switch from Serpantinum to another shell (Caelestia)

Never run two shells at once: two bars and two notification daemons fight each other.

1. **Stop Serpantinum** and remove it from autostart: in this repository it is started by `hl.exec_cmd("serpantinumd start")` in `config/autostart.lua` (`grep -ri serpantinum ~/.config/hypr/` to find every reference). Stop it now with `pkill -f serpantinum`.
2. **Install [Caelestia](https://github.com/caelestia-dots/shell)**:
   - the shell only, from the AUR: `yay -S caelestia-shell` (the stable package, not `-git`);
   - or the full dotfiles ([caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia)): shell + a Hyprland config with ready-made keybinds. They **replace** `~/.config/hypr`, so back it up first.
3. **Start it**: `caelestia shell -d` (detached), and add that command to Hyprland's autostart (already done by the full dotfiles).
4. **Keybinds** (shell only): they go through Hyprland global shortcuts; copy the examples from the Caelestia dotfiles. `caelestia shell -s` lists the IPC commands.

Keybinds and binds that call `serpantinum …` (volume, brightness, lock, screenshot) must be replaced too.

## Debian / Kali with a GUI on Windows (WSL)

In PowerShell (Windows):

```powershell
wsl --update
wsl --set-default-version 2
wsl --install -d Debian
wsl --install -d kali-linux
```

In Kali, install the desktop (Win-KeX) and tools:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y kali-win-kex wireshark
kex             # full-screen Kali desktop
kex --sl -s     # "seamless" mode: Kali windows mixed with Windows ones, with sound
```

## University / company VPN (IKEv2, EAP)

See [`vpn-ikev2-eap.md`](vpn-ikev2-eap.md): strongSwan + NetworkManager from the command line, and the errors met along the way.

## Resources

- **CLI / TUI apps**: [awesome-cli-apps](https://github.com/agarrharr/awesome-cli-apps) · [awesome-shell](https://github.com/alebcay/awesome-shell) · [Terminals Are Sexy](https://terminalsare.sexy/) · [Terminal Trove](https://terminaltrove.com/list/) · [terminal-toys](https://github.com/Seebass22/terminal-toys) (terminal screensavers)
- **Shells for Wayland**: [Serpantinum](https://github.com/ilyamiro/serpantinum) (used here) · [Caelestia](https://github.com/caelestia-dots/shell)
- **Hyprland GUI settings**: [hyprmod](https://github.com/BlueManCZ/hyprmod). It writes `~/.config/hypr/hyprland-gui.lua`, loaded last, which overrides the monitors set in `hosts/<hostname>.lua`: don't use it for monitors.
- **fastfetch**: the Nebula config of this rice is [`home/.config/fastfetch/perso.jsonc`](../home/.config/fastfetch/perso.jsonc).
