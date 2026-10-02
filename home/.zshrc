# fastfetch on terminal start
fastfetch --config ~/.config/fastfetch/perso.jsonc

# History (needed for autosuggestions)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Prompt
eval "$(starship init zsh)"

# ls -> eza (couleurs Nebula dans ~/.config/eza/theme.yml)
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lh --icons=auto --group-directories-first --git'
alias la='eza -lah --icons=auto --group-directories-first --git'
alias lt='eza --tree --level=2 --icons=auto --group-directories-first'

# ssh : les serveurs ne connaissent pas le terminal « xterm-kitty »
# (nano, htop, vim → « Error opening terminal »). On annonce un
# terminal standard que toutes les machines connaissent, même avec sudo.
alias ssh='TERM=xterm-256color ssh'

# clear = vrai reset du terminal + fastfetch
# Avant d'effacer, le contenu du terminal est sauvegardé dans
# ~/.cache/terminal-logs/ (les 20 derniers sont gardés).
clear() {
  if [[ -n $KITTY_WINDOW_ID ]]; then
    local dir=~/.cache/terminal-logs
    mkdir -p $dir
    kitty @ get-text --extent all > "$dir/$(date +%Y-%m-%d_%H-%M-%S).txt" 2>/dev/null
    local old=( $dir/*.txt(Nom[21,-1]) )
    (( ${#old} )) && rm -- $old
  fi
  command clear
  printf '\e[3J'
  fastfetch --config ~/.config/fastfetch/perso.jsonc
}

# ── Sélection à la façon d'un éditeur de texte ───────────────
# Shift + ←/→ : sélectionne caractère par caractère
# Ctrl + Shift + ←/→ : sélectionne mot par mot
# Ctrl + A : sélectionne toute la commande
# Retour arrière / Suppr : efface la sélection
# Taper un caractère : remplace la sélection
# ←/→ seules : annulent la sélection
# (défini AVANT les plugins pour qu'ils prennent ces widgets en compte)
_sel_start()      { (( REGION_ACTIVE )) || { MARK=$CURSOR; REGION_ACTIVE=1; } }
_sel-left()       { _sel_start; zle backward-char }
_sel-right()      { _sel_start; zle forward-char }
_sel-word-left()  { _sel_start; zle backward-word }
_sel-word-right() { _sel_start; zle forward-word }
_sel-all()        { MARK=0; CURSOR=${#BUFFER}; REGION_ACTIVE=1 }
_desel-left()     { REGION_ACTIVE=0; zle backward-char }
_desel-right()    { REGION_ACTIVE=0; zle forward-char }
_sel-backspace()  { if (( REGION_ACTIVE )); then zle kill-region; REGION_ACTIVE=0; else zle backward-delete-char; fi }
_sel-delete()     { if (( REGION_ACTIVE )); then zle kill-region; REGION_ACTIVE=0; else zle delete-char; fi }
_sel-self-insert() { if (( REGION_ACTIVE )); then zle kill-region; REGION_ACTIVE=0; fi; zle .self-insert }
for _w in _sel-left _sel-right _sel-word-left _sel-word-right _sel-all \
          _desel-left _desel-right _sel-backspace _sel-delete; do
  zle -N $_w
done
unset _w
zle -N self-insert _sel-self-insert

# Couleur de la sélection : style « néon », texte cyan sur un bleu moyen
# (mêmes couleurs que selection_foreground / selection_background dans kitty.conf)
zle_highlight=(region:fg=#00e5ff,bg=#2b3d8f paste:none)

# Plugins (syntax-highlighting must stay last)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# change to the next or previous word
bindkey '^[[1;5D' backward-word   # Ctrl + ←
bindkey '^[[1;5C' forward-word    # Ctrl + →

# Touches d'édition
bindkey '^[[3~'   _sel-delete           # Suppr : efface la sélection ou le caractère sous le curseur
bindkey '^?'      _sel-backspace        # Retour arrière : efface la sélection ou le caractère précédent
bindkey '^[[3;5~' kill-word             # Ctrl + Suppr : efface le mot suivant
bindkey '^H'      backward-kill-word    # Ctrl + Retour arrière : efface le mot précédent
bindkey '^[[H'    beginning-of-line     # Début (Home) : début de ligne
bindkey '^[[F'    end-of-line           # Fin (End) : fin de ligne

# Sélection
bindkey '^[[1;2D' _sel-left             # Shift + ←
bindkey '^[[1;2C' _sel-right            # Shift + →
bindkey '^[[1;6D' _sel-word-left        # Ctrl + Shift + ←
bindkey '^[[1;6C' _sel-word-right       # Ctrl + Shift + →
bindkey '^A'      _sel-all              # Ctrl + A : tout sélectionner
bindkey '^[[D'    _desel-left           # ← (annule la sélection)
bindkey '^[OD'    _desel-left
bindkey '^[[C'    _desel-right          # → (annule la sélection)
bindkey '^[OC'    _desel-right

# Ctrl + L = même chose que la commande clear (reset complet + fastfetch)
_clear_full() {
  zle -I            # prévient zsh qu'on va écrire à l'écran
  clear             # la fonction clear ci-dessus
  zle reset-prompt  # réaffiche le prompt proprement
}
zle -N _clear_full
bindkey '^L' _clear_full
