# CLAUDE.md — contexte pour Claude Code

Ce dépôt sauvegarde le rice Hyprland de rotten_guy. Il a été construit au fil d'une longue
conversation sur claude.ai ; ce fichier en transmet l'essentiel. **Lis aussi
`feuille-de-route-rice.md`** (historique complet, en français) et `README.md` (installation, en anglais).

## L'utilisateur
- Étudiant en BUT2 (informatique / réseaux), parle **français**, ton décontracté : réponds en français.
- Débutant-intermédiaire sous Linux : explique **pourquoi** une commande fait ce qu'elle fait, sans jargon inutile.
- Quand il demande une modification d'un fichier de config, il veut **le fichier complet**, pas seulement le passage modifié.

## La machine
- ThinkPad P53 · Arch Linux · **Hyprland 0.56 en config Lua** (`~/.config/hypr/hyprland.lua` + `config/*.lua`, syntaxe `hl.bind`, `hl.config`, `hl.env`…).
- Shell graphique **Serpantinum** (Quickshell), installé dans `~/.local/share/serpantinum` (hors pacman).
- GPU **NVIDIA Quadro RTX 3000** seule (BIOS en carte dédiée) : la veille peut figer l'écran au réveil.
- Terminal kitty + zsh + starship. Clavier Bluetooth **Lily58**, casque Sony WH-1000XM4, lecteur d'empreinte (fprintd).

## Règles apprises (importantes)
1. **Toujours chercher d'abord une option dans Serpantinum** (`~/.config/serpantinum/settings.json`, guide `SUPER + H`). Ne patcher son code qu'en dernier recours, avec un script qui sauvegarde l'original et propose `--restore` (voir `scripts/patch-*.py`).
2. **matugen réécrit certains fichiers** (fastfetch `config.jsonc`, couleurs kitty) : ne pas modifier ces fichiers générés, passer par des fichiers à part.
3. **Vérifier qu'un fichier est complet** après modification (`tail`) : un collage dans nano a déjà coupé le `.zshrc`.
4. **Ne jamais lancer les scripts de l'utilisateur avec sudo** quand ils le refusent (`backup-rice.sh`, `save-all.sh`). Demander confirmation avant toute commande `sudo` ou modification dans `/etc`, `/usr`.
5. **Confidentialité** : la position (IP, GPS) dans `settings.json` de Serpantinum est retirée par `backup-rice.sh` ; les logs de terminal (`~/.cache/terminal-logs`) ne vont jamais sur GitHub.
6. **Dépôt public** (l'utilisateur le garde public pour l'instant, ne plus insister) : il contient `system/rotten-laptop/var/lib/bluetooth/` (clés d'appairage), le curseur Chroma S (licence de Glimy à vérifier) et des fonds d'écran. Décision en attente : repasser en privé, ou nettoyer (retirer les clés, purger l'historique git, refaire l'appairage).
7. Après chaque changement : mettre à jour `backup-rice.sh` si un nouveau fichier est concerné, puis le README et la feuille de route, puis sauvegarder avec `~/save-all.sh` (ou `~/backup-rice.sh`, réponse `o`).

## Pièges déjà résolus (ne pas réintroduire)
- Workspaces : dispatchers natifs `hl.dsp.focus({ workspace = i })`, pas `serpantinum msg workspace` (latence). `SUPER + Tab` utilise `"e+1"` / `"e-1"` (`"+1"` crée des workspaces à l'infini).
- Dolphin : `QT_QPA_PLATFORMTHEME=qt6ct` **et** `QT_STYLE_OVERRIDE=kvantum` ; jeu de couleurs KDE « Nebula ».
- GTK sombre : `GTK_THEME` dans `env.lua` **et** `~/.config/environment.d/gtk.conf` (le portail est un service systemd) ; icônes et thème via `gsettings` sous Wayland.
- Veille NVIDIA : services `nvidia-suspend/resume/hibernate` + `hyprland-suspend/resume` (Hyprland en pause pendant la veille). Capot sur secteur = verrouillage par Hyprland (`switch:on:Lid Switch`), veille seulement sur batterie. **À tester** : réveil sur batterie.
- Le lanceur de Serpantinum ignore `Terminal=true` : les applis terminal passent par `kitty <commande>` dans un `.desktop`.
- SSH depuis kitty : `alias ssh='TERM=xterm-256color ssh'` dans `.zshrc` (sinon « Error opening terminal: xterm-kitty » sur les serveurs, même avec sudo).
- kitty intercepte `Ctrl + Shift + ←/→` (onglets) : mis à `no_op` pour la sélection dans zsh.
- Ménage KDE : des paquets utiles sont partis avec (`zbar`, `ark`). Avant d'en retirer d'autres, les ajouter à la liste protégée de `scripts/menage-apercu.sh`.
- Hors Plasma, Dolphin ne voit un nouveau plugin KDE (ex. `ark` → « Compresser / Extraire ») qu'après `kbuildsycoca6 --noincremental` (Dolphin fermé).

## Deux machines
- `rotten-laptop` (ThinkPad P53) et `rotten-desktop` (PC fixe : GTX 1080 Ti → pilote `nvidia-580xx-dkms`, 2 écrans 165 Hz, pas d'empreinte).
- `home/` est **commun** ; ce qui dépend de la machine va dans `home/.config/hypr/config/hosts/<nom>.lua`, `system/<nom>/`, `packages/<nom>/`.
- Ne jamais copier sur le fixe les PAM d'empreinte, la veille NVIDIA du P53, le capot ni le Bluetooth du portable.

## Flux de travail avec Claude Code (cloud)
- Le dépôt local de l'utilisateur est `~/dotfiles-backup` (branche `main`). Claude Code travaille sur une branche `claude/...` puis la fusionne dans `main` via une PR.
- ⚠️ `save-all.sh` fait `git pull --rebase`, **puis recopie `~/*.sh` et `~/*.py` dans `scripts/`** : un script modifié par Claude dans le dépôt doit aussi être copié dans `~` (`cp ~/dotfiles-backup/scripts/<script> ~/`), sinon l'ancienne version l'écrase.
- Claude ne peut pas changer la visibilité du dépôt (public/privé) : l'utilisateur le fait dans GitHub → *Settings* → *Danger Zone*.

## Points ouverts
- Trousseau (gnome-keyring) non déverrouillé après une connexion par empreinte → choix A (Brave `--password-store=basic`), B (trousseau sans mot de passe) ou C (rien).
- Firmware du Lily58 (ZMK, mode bootloader déclenché par erreur), à voir plus tard. Le 2 octobre il a perdu son appairage (engrenage sur l'écran) → réappairé avec `bluetoothctl` ; cause trouvée : calque Lower de `PoUrRiTuRe/rotten_lily58_keymap_config` = `BT_CLR` sur Échap et `BT_SEL 0-4` sur 1-5 (Lower + Échap efface l'appairage). Correction proposée : calque Adjust (Lower + Raise). L'utilisateur modifie son keymap avec https://nickcoutsos.github.io/keymap-editor/ (commit direct sur ce dépôt → GitHub Actions compile les `.uf2`).
- `~` affiche `master ?` dans le prompt : le dossier perso est un dépôt git, sans doute par erreur. Ne rien supprimer sans vérifier.
