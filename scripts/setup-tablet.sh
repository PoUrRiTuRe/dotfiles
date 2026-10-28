#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  setup-tablet.sh — one-time setup of the tablet as a third monitor
#  Installs Sunshine (AUR), installs its config from the repository,
#  enables its user service and prints the remaining steps.
#  The screen itself is automatic afterwards: starting "Nebula tablet" in
#  Moonlight creates it, quitting the session removes it.
#  Usage: ~/setup-tablet.sh   (without sudo; see docs/tablet-screen.md)
# ─────────────────────────────────────────────────────────────
set -uo pipefail
REPO="$HOME/dotfiles-backup"

[[ $EUID -eq 0 ]] && { echo "!! Run this script without sudo."; exit 1; }

echo "==> Sunshine"
if ! command -v sunshine >/dev/null; then
    command -v yay >/dev/null || { echo "!! yay is missing (see docs/arch-notes.md)"; exit 1; }
    yay -S --needed sunshine-bin || { echo "!! Sunshine install failed"; exit 1; }
fi
echo "   ok  $(command -v sunshine)"

echo "==> Config"
mkdir -p "$HOME/.config/sunshine" "$HOME/.local/bin"
for f in sunshine.conf apps.json; do
    if [[ -f "$HOME/.config/sunshine/$f" ]]; then
        echo "   ..  ~/.config/sunshine/$f already exists: kept (compare with $REPO/home/.config/sunshine/$f)"
    else
        cp "$REPO/home/.config/sunshine/$f" "$HOME/.config/sunshine/$f"
        echo "   ok  ~/.config/sunshine/$f"
    fi
done
if [[ ! -x "$HOME/.local/bin/tablet-screen" ]]; then
    cp "$REPO/home/.local/bin/tablet-screen" "$HOME/.local/bin/" && chmod +x "$HOME/.local/bin/tablet-screen"
fi
echo "   ok  ~/.local/bin/tablet-screen"

echo "==> Input (touch and mouse from the tablet)"
if id -nG | grep -qw input; then
    echo "   ok  $USER is in the input group"
else
    echo "   !!  $USER is not in the input group: if touch doesn't work, run"
    echo "       sudo usermod -aG input $USER   (then log out and back in)"
fi

echo "==> Firewall"
if systemctl is-active --quiet ufw; then
    if sudo -n true 2>/dev/null && sudo -n ufw status 2>/dev/null | grep -q 47989; then
        echo "   ok  ufw already allows Sunshine"
    else
        echo "   !!  ufw is active: Moonlight cannot reach Sunshine until its ports are open. Run"
        echo "       sudo ufw allow 47984:47990/tcp && sudo ufw allow 48010/tcp && sudo ufw allow 47998:48000/udp && sudo ufw allow 48010/udp"
    fi
else
    echo "   ok  no ufw firewall"
fi

echo "==> User service"
UNIT=$(systemctl --user list-unit-files --no-legend 2>/dev/null | awk 'tolower($1) ~ /sunshine/ {print $1; exit}')
if [[ -n "$UNIT" ]]; then
    systemctl --user enable --now "$UNIT" && echo "   ok  $UNIT enabled"
else
    echo "   !!  no Sunshine user service found: start it once with 'sunshine' to check it works"
fi

cat << 'TXT'

==> Remaining steps (once)
 1. Open https://localhost:47990 (accept the certificate) and create the Sunshine login.
 2. Run "tablet-screen on", then in Configuration > Audio/Video > Display pick TABLET
    and save; then "tablet-screen off".
 3. On the tablet: install Moonlight, add this PC (same Wi-Fi), enter the PIN
    in the Sunshine web UI (PIN tab).
 4. Moonlight settings: resolution "native" (2000x1200), 120 FPS, touchscreen mode
    (not trackpad).
 Then: tap "Nebula tablet" in Moonlight to start, "Quit session" to stop.
TXT
