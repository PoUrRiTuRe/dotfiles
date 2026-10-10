# 🔐 IKEv2 / EAP VPN on Arch Linux (strongSwan + NetworkManager)

Many universities and companies only document their VPN for Ubuntu / Debian. If their guide shows a **strongSwan** form in NetworkManager like this one:

| Field in the GUI | Typical value |
|---|---|
| Server → Address | `vpn.example.org` |
| Server → Certificate | *(None)* |
| Client → Authentication | **EAP (Username/Password)** |
| Client → Username | `login@realm` |
| Options → **Request an inner IP address** | ✅ checked |
| Options → **Enforce UDP encapsulation** | ✅ checked |
| Options → Use IP compression | ☐ unchecked |

then it works the same way on Arch: only the package names differ.

> Replace `vpn.example.org` and `login@realm` with the values from your organization's guide. Never commit them, nor your password.

---

## 1. Install

```bash
sudo pacman -S --needed networkmanager-strongswan   # pulls in strongswan
sudo systemctl restart NetworkManager
```

## 2. Create the connection

From a terminal (no GUI needed):

```bash
nmcli connection add type vpn con-name "VPN" \
  vpn-type org.freedesktop.NetworkManager.strongswan \
  connection.autoconnect no \
  vpn.data "address=vpn.example.org, method=eap, user=login@realm, virtual=yes, encap=yes, ipcomp=no, password-flags=2"
```

| `vpn.data` key | GUI equivalent |
|---|---|
| `address=` | Server → Address |
| `method=eap` | Authentication: EAP (Username/Password) |
| `user=` | Username |
| `virtual=yes` | **Request an inner IP address** |
| `encap=yes` | **Enforce UDP encapsulation** |
| `ipcomp=no` | Use IP compression unchecked |
| `password-flags=2` | Password asked at every connection, never stored |

No `certificate=` key: the server certificate is then checked against the system CA store, like *(None)* in the GUI.

Prefer a GUI? `sudo pacman -S nm-connection-editor`, then **+** → **IPsec/IKEv2 (strongswan)** and fill in the same fields. Some guides warn that both options of the table above get unchecked after an update: check them again if the connection suddenly stops working.

## 3. Connect / disconnect

```bash
nmcli --ask connection up "VPN"     # asks for the password
nmcli connection down "VPN"
nmcli connection show --active      # check
ip addr                             # an address from the remote network should appear
```

With this repository's `.zshrc`, the same thing is `vpn-on`, `vpn-off` and `vpn-status` (the connection must be named `VPN`; rename an existing one with `nmcli connection modify "<old name>" connection.id VPN`).

Once connected, internal services are reachable as on site, e.g. a Proxmox server: web UI on `https://<server-ip>:8006`, or `ssh root@<server-ip>`.

---

## 🩺 Troubleshooting

Read the daemon's log first:

```bash
journalctl -b -u NetworkManager --since "-15min" | grep -iE "vpn|charon|strongswan" | tail -30
journalctl -b --since "-15min" | grep -i charon | tail -30
```

| Symptom | Cause | Fix |
|---|---|---|
| `The VPN service did not start in time` + `unable to create netlink socket: Protocol not supported (93)` + `unmet dependency: CUSTOM:kernel-ipsec` | The kernel was updated (`pacman -Syu`) without rebooting: the running kernel can't load its IPsec module (`xfrm_user`), because its modules were replaced by the new version's. Check with `uname -r` vs `ls /usr/lib/modules/` (`modprobe xfrm_user` says *Module not found*) | **Reboot** |
| `Could not find source connection` | NetworkManager was just restarted and Wi-Fi isn't connected yet | Wait for Wi-Fi, try again |
| `PKCS11 module '<name>' lacks library path` | Placeholder in strongSwan's default config | Harmless, ignore |
| Authentication fails | Wrong username format (often `login@realm`, not just `login`) or password | Check the organization's guide |
| Connected, but pages / SSH freeze | MTU too large for the tunnel | Lower the MTU of the Wi-Fi / Ethernet connection, e.g. `nmcli connection modify "<wifi-name>" 802-11-wireless.mtu 1300` (`802-3-ethernet.mtu` for a cable), then reconnect |
| `program=` path errors | Plugin and strongSwan disagree on the daemon path | `cat /usr/lib/NetworkManager/VPN/nm-strongswan-service.name` and check that the `program=` file exists |

> After a kernel update, reboot soon: until then, anything that loads a kernel module (VPN, some USB devices or file systems) can fail the same way.
