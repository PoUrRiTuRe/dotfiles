# Feuille de route — Rice Hyprland « Nebula » (ThinkPad P53)

> Arch Linux · Hyprland 0.56 (config Lua) · Serpantinum · thème cyan / magenta
> Sauvegarde : `~/backup-rice.sh` → dépôt GitHub `PoUrRiTuRe/dotfiles` (⚠️ encore **public**, voir points ouverts)

---

## ✅ Première session — les bases

- [x] **kitty s'ouvrait en plein écran** → bug de kitty ([#10442](https://github.com/kovidgoyal/kitty/issues/10442)), contourné par une règle `fullscreen_state = "0 0"`
- [x] **Ctrl + ← / →** qui écrivaient « D » dans zsh → `bindkey` dans `.zshrc`
- [x] **Greeter SDDM lent** → ligne `pam_fprintd` mal placée dans `/etc/pam.d/sddm`
- [x] **Empreinte au greeter** → mot de passe d'abord, puis empreinte (champ vide + Entrée, puis le doigt)
- [x] **Thème SDDM `nebula`** → horloge néon, cartes sombres, fond nébuleuse
- [x] **fastfetch écrasé** par matugen → vraie config dans `perso.jsonc`
- [x] **Latence de `SUPER + chiffre`** → dispatchers natifs de Hyprland au lieu de `serpantinum msg`
- [x] **Sauvegarde** → `backup-rice.sh` + dépôt GitHub (clé SSH, identité git)
- [x] **Curseur Chroma S** → pack Windows converti, croix de précision, animation fluidifiée
- [x] **Couleurs « panneau NVIDIA »** → shader `nvidia-like.glsl` (luminosité 60 / contraste 65 / vibrance 85)
- [x] **README** du dépôt, en anglais, avec captures

---

## ✅ Les 12 étapes

### 1. 🎧 Bluetooth
- [x] Casque Sony WH-1000XM4 appairé (Paired / Bonded / Trusted), reconnexion automatique
- [x] `/var/lib/bluetooth` sauvegardé (sans le cache des appareils voisins)

### 2. 💬 Notifications
- [x] Le mode **Silent** du panneau `SUPER + E` bloquait les pop-ups

### 3. 🌈 Bordure des fenêtres
- [x] Dégradé cyan → magenta, 2 px, rotation continue à vitesse constante (courbe `linear`)
- [x] Fondu doux au changement de focus (courbe `smooth`)
- [x] Config de bordure regroupée dans `settings.lua`

### 4. 🛟 Points de restauration ⏭️
- [x] Gérés par tes propres scripts rsync (NVMe système → second NVMe)

### 5. 📦 `backup-rice.sh`
- [x] Config utilisateur + fichiers système + liste des paquets
- [x] Refuse `sudo`, installe `git` si besoin, propose le push GitHub
- [x] Complété au fil des étapes (Dolphin, GTK, eza, nano, LazyVim, lanceur…)

### 6. 🔁 `restore-rice.sh` ❌
- Abandonné : chaque shell (Serpantinum, Caelestia, DMS) apporte sa propre config. Le README explique l'installation à la main.

### 7. 🗂️ Dolphin « Nebula »
- [x] Kvantum (base KvArcDark), fenêtres translucides floutées par Hyprland
- [x] Jeu de couleurs KDE **Nebula** : texte blanc, sélection cyan, liens magenta
- [x] `QT_QPA_PLATFORMTHEME=qt6ct` **et** `QT_STYLE_OVERRIDE=kvantum` dans `env.lua`

### 8. 🧹 Ménage de KDE Plasma et GNOME
- [x] Agent de mot de passe `hyprpolkitagent` installé (il n'y en avait aucun)
- [x] 42 paquets utiles protégés, **327 paquets supprimés (~2 Go)**
- [x] Réparation après coup : `zbar` réinstallé (requis par les captures d'écran de Serpantinum)
- [x] Réparation après coup : `ark` réinstallé (+ `unrar`) pour le menu « Compresser / Extraire » de Dolphin ; ajouté aux paquets protégés de `menage-apercu.sh`
- [x] Le greeter ne propose plus que Hyprland

### 9. 📂 Couleurs de `ls`
- [x] `eza` + thème Nebula (`~/.config/eza/theme.yml`), alias `ls` / `ll` / `la` / `lt`
- [x] Zoom de kitty : `Ctrl + =` / `Ctrl + -` / `Ctrl + 0`
- Dossiers cachés en cyan sombre : abandonné (eza ne sait pas colorer un dossier selon son nom)

### 10. 📝 LazyVim
- [x] Neovim + LazyVim (starter officiel) + outils (ripgrep, fd, fzf, lazygit)
- [x] Lancement depuis `SUPER + D` : `nvim.desktop` → `kitty nvim %F` (le lanceur ignore `Terminal=true`)

### 11. 🌙 Fenêtres GTK sombres
- [x] Réglages GTK hérités de KDE remplacés (`gtk-3.0` / `gtk-4.0`)
- [x] `GTK_THEME=Adwaita:dark` dans `env.lua` **et** `~/.config/environment.d/gtk.conf` (pour le portail)
- [x] Icônes Papirus-Dark aux dossiers cyan (`gsettings` + `papirus-folders`)
- [x] Nano aux couleurs Nebula (erreurs enfin lisibles)

### 12. 📐 Barre du haut avec `SUPER + E`
- [x] `patch-topbar.py` : horloge recentrée, indicateurs calés contre le panneau
- ⚠️ À relancer après une mise à jour de Serpantinum

---

## ✅ Après les 12 étapes

### ⌨️ Clavier Lily58 (Bluetooth)
- [x] Appairé avec `bluetoothctl` + `agent KeyboardDisplay` : taper le code à 6 chiffres **sur le clavier** + Entrée
- [x] Appairage sauvegardé avec celui du casque (`/var/lib/bluetooth`)
- [x] **Panne du 2 octobre** : plus de sans-fil, **engrenage** au lieu du logo Wi-Fi sur l'écran du clavier. L'engrenage (ZMK) = profil Bluetooth actif **sans appairage** : le clavier avait perdu sa clé, alors que le PC le croyait encore connecté
- [x] Réparé en réappairant : `remove` → `agent KeyboardDisplay` → `scan on` → `pair` (code tapé sur le clavier) → `trust` → `connect`
- ℹ️ Normal : seule la moitié **gauche** (central) parle au PC ; la droite parle à la gauche. D'où « gauche en USB + droite sans fil » qui marche, et pas l'inverse

### 🔀 Workspaces suivant / précédent
- [x] `SUPER + Tab` / `SUPER + Shift + Tab`
- [x] Corrigé : `"+1"` créait des workspaces à l'infini (jusqu'à 48 !) → `"e+1"` / `"e-1"` : seulement les workspaces ouverts, en boucle

### 🧹 `clear` complet
- [x] `clear` = vrai reset (scrollback vidé) + fastfetch
- [x] Filet de sécurité : le contenu est sauvegardé avant dans `~/.cache/terminal-logs/` (20 derniers, **jamais envoyés sur GitHub**)
- [x] `Ctrl + L` branché sur le même reset
- [x] kitty : `allow_remote_control yes` (nécessaire à la sauvegarde)
- [x] `less` installé (manquait pour `git log` et `man`)

### 🎮 Jeux Steam
- [x] `steam`, `lib32-nvidia-utils`, `lib32-vulkan-icd-loader` déjà installés
- [x] Une seule puce graphique active (NVIDIA, réglage du BIOS) → pas besoin de `prime-run` (`nvidia-prime` inutile)
- [x] Steam Play activé pour tous les titres, **Proton Experimental** par défaut
- Outils utiles : `protontricks` (composants Windows d'un jeu), `protonup-qt` (versions GE-Proton). Versions plus anciennes : Propriétés du jeu → Compatibilité
- Quaver : natif Linux · Overwatch : Proton (compte Battle.net requis) · Disfigure : vérifier sur protondb.com

### 📄 README
- [x] Crédits, Lily58, `SUPER + Tab`, astuce clavier Bluetooth

### 😴 Veille et écran figé
- [x] Cause : `PreserveVideoMemoryAllocations=1` **sans** les services NVIDIA de veille → écran figé au réveil
- [x] `nvidia-suspend`, `nvidia-resume`, `nvidia-hibernate` activés : réveil OK
- [x] Serpantinum (`settings.json`) : extinction de l'écran et veille automatiques **désactivées** (assombrissement et verrouillage gardés). Fermer le capot met toujours en veille

### ⌨️ zsh façon éditeur de texte
- [x] Suppr, Ctrl + Suppr, Ctrl + Retour arrière, Début / Fin (plus de `~` qui s'affiche)
- [x] Sélection : Shift + ←/→, Ctrl + Shift + ←/→ (kitty : `no_op` pour libérer ces touches), Ctrl + A, remplacement en tapant
- [x] Couleur de sélection identique clavier / souris (style « néon » cyan)
- [x] Leçon : un collage dans nano a **coupé** le `.zshrc` → les fichiers longs se donnent maintenant **à télécharger**, et on vérifie avec `tail`
- Contour arrondi autour de la sélection : impossible dans un terminal (affichage en grille)

### 💾 Sauvegarde complétée
- [x] Réglages Serpantinum sauvegardés **sans la position** (IP, GPS)
- [x] Liste des services activés (système et utilisateur) et des réglages `gsettings`
- [x] README : nouveaux paquets (`less`, Steam…), étape « Services », lien vers cette feuille de route


### 🧊 Freeze au réveil (suite)
- [x] Même avec les services NVIDIA, le réveil peut échouer (`Failed to apply atomic modeset`) : bug du pilote avec Wayland
- [x] La veille venait du **capot / de la touche veille** (logind), pas de Serpantinum
- [x] `/etc/systemd/logind.conf.d/no-suspend.conf` : touche veille ignorée ; capot sur secteur = rien côté système ; capot sur batterie = veille
- [x] L'écran de verrouillage de Serpantinum ignore le signal de logind → Hyprland verrouille lui-même à la fermeture du capot (`switch:on:Lid Switch`)
- [x] Correctif veille NVIDIA : `hyprland-suspend` / `hyprland-resume` mettent Hyprland en pause pendant la veille
- [ ] **À tester** : capot fermé sur batterie → réveil sans freeze. Sinon : `HandleLidSwitch=lock`

### 🔒 Empreinte sur l'écran de verrouillage (`SUPER + L`)
- [x] Vérifié : Serpantinum n'a **aucune** option d'empreinte (il utilise seulement le service PAM `login`)
- [x] `/etc/pam.d/serpantinum-fprint` + `patch-lock.py` : lecteur actif en parallèle du mot de passe
- [x] Animation façon Omarchy : anneau cyan qui pulse → coche magenta, tremblement rouge si doigt refusé
- ⚠️ À relancer après une mise à jour de Serpantinum
- [ ] Trousseau (Brave) après connexion par empreinte : choix A / B / C à faire

### 🗜️ Archives dans Dolphin
- [x] `ark` avait disparu avec le ménage KDE → plus de « Compresser / Extraire » au clic droit
- [x] `sudo pacman -S --needed ark 7zip unrar` : `ark` = menus + appli, `7zip` = `.7z` (déjà là), `unrar` = `.rar`
- [x] Hors Plasma, Dolphin ne voit pas les nouvelles extensions tout seul : `killall dolphin && kbuildsycoca6 --noincremental`
- [ ] Vérifier le clic droit dans Dolphin (sinon : *Configurer* → *Menus contextuels*, cocher les entrées d'Ark)

### 🧭 Règle pour la suite
- Avant de modifier un fichier de Serpantinum, **chercher d'abord une option** dans ses réglages ou son guide (`SUPER + H`). Les patchs restent le dernier recours.

---

## 🔍 Petits points ouverts

- [ ] **Dépôt public** alors qu'il contient `system/var/lib/bluetooth/` (clés d'appairage), le curseur Chroma S et des fonds d'écran → le passer en **privé** (GitHub → *Settings* → *Danger Zone* → *Change visibility*)
- [ ] **`~` affiche `master ?`** : ton dossier perso est un dépôt git (sans doute par erreur). Vérifier avec `ls -la ~/.git` **sans rien supprimer**
- [ ] **`hyprpolkitagent` au démarrage** : vérifier après un redémarrage avec `pgrep -a hyprpolkitagent`
- [ ] **GitHub** : vérifier que le README s'affiche avec les 4 captures
- [ ] **Règle kitty `fullscreen_state`** : à retirer quand kitty aura corrigé son bug

## ✨ Options, si l'envie te prend

- [ ] LazyVim : `:LazyExtras` → `lang.java` pour les TP de R308
- [ ] LazyVim : thème de couleurs Nebula
- [ ] Fenêtres GTK : couleurs Nebula (`gtk.css`)

## 💤 Mis de côté

- Fond d'écran animé (Igris, Wallpaper Engine)
- Timeshift (snapshots automatiques avant les mises à jour)
- Passage à fish
- Migration vers CachyOS (Serpantinum, Caelestia ou DMS) — après le projet de groupe
- Empreinte au greeter sans appuyer sur Entrée

---

## 🧰 Scripts (dossier `scripts/` du dépôt)

| Script | Rôle |
|---|---|
| `backup-rice.sh` | Sauvegarde tout dans `~/dotfiles-backup`, puis commit + push |
| `nebula-kvantum.sh` | Crée le thème Kvantum Nebula pour Dolphin |
| `nebula-colors.sh` | Crée le jeu de couleurs KDE Nebula et l'impose à Dolphin |
| `patch-topbar.py` | Corrige la barre de Serpantinum (`--restore` pour annuler) |
| `menage-apercu.sh` | Essai à blanc du ménage KDE / GNOME, avec liste de paquets protégés |
| `patch-lock.py` | Empreinte + animation sur l'écran de verrouillage (`--restore` pour annuler) |
| `save-all.sh` | Sauvegarde en une commande : récupère GitHub **et installe dans `~` la config et les scripts modifiés sur GitHub** (fichiers système seulement signalés), range les fichiers téléchargés, copie les scripts, lance la sauvegarde |

## 📄 Fichiers modifiés

| Fichier | Pourquoi |
|---|---|
| `~/.config/hypr/config/keybinds.lua` | workspaces natifs, `SUPER + Tab`, `SUPER + F` → Dolphin |
| `~/.config/hypr/config/settings.lua` | bordure, animations, shader, règle kitty |
| `~/.config/hypr/config/env.lua` | curseur, Qt (Dolphin), GTK sombre, menu « Ouvrir avec » |
| `~/.config/hypr/shaders/nvidia-like.glsl` | couleurs de l'écran |
| `~/.config/kitty/kitty.conf` | zoom, copie de l'historique, `allow_remote_control`, couleur de sélection, Ctrl + Shift + ←/→ libérés |
| `~/.config/fastfetch/perso.jsonc` | ta config fastfetch |
| `~/.config/eza/theme.yml` | couleurs de `ls` |
| `~/.config/nano/nanorc` | couleurs de nano |
| `~/.config/nvim/` | LazyVim |
| `~/.config/Kvantum/`, `qt6ct/`, `kdeglobals`, `dolphinrc` | thème de Dolphin |
| `~/.local/share/color-schemes/Nebula.colors` | jeu de couleurs KDE |
| `~/.config/gtk-3.0/`, `gtk-4.0/` | fenêtres GTK sombres, icônes, curseur |
| `~/.config/environment.d/gtk.conf` | `GTK_THEME` pour le portail |
| `~/.local/share/applications/nvim.desktop` | Neovim depuis le lanceur |
| `~/.local/share/icons/ChromaS/` | curseur |
| `~/.local/share/serpantinum/.../TopBar.qml` | barre corrigée (via `patch-topbar.py`) |
| `~/.zshrc` | fastfetch, eza, plugins, touches d'édition, sélection, `clear` complet + `Ctrl + L` |
| `/etc/pam.d/sddm`, `/etc/pam.d/sudo` | mot de passe + empreinte |
| `/etc/pam.d/serpantinum-fprint` | empreinte sur l'écran de verrouillage |
| `/etc/systemd/logind.conf.d/no-suspend.conf` | capot et touche veille : pas de veille sur secteur |
| `/etc/systemd/system/hyprland-{suspend,resume}.service`, `/usr/local/bin/suspend-hyprland.sh` | Hyprland en pause pendant la veille (anti-freeze NVIDIA) |
| `~/.local/share/serpantinum/.../Lock.qml` | empreinte + animation (via `patch-lock.py`) |
| `/etc/sddm.conf.d/`, `/usr/share/sddm/themes/nebula/` | greeter |
| `/var/lib/bluetooth/` | appairages (casque XM4, clavier Lily58) |
| `~/.config/serpantinum/settings.json` | veille et extinction d'écran désactivées (sauvegardé sans la position) |
| services `nvidia-suspend/resume/hibernate` | réveil de veille (pas un fichier : voir README, étape « Services ») |
| **`gsettings`** (pas de fichier) | GTK : thème sombre, icônes Papirus, curseur → à refaire à la main (voir README) |
