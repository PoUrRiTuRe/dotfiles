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

# ls -> eza (Nebula colors in ~/.config/eza/theme.yml)
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lh --icons=auto --group-directories-first --git'
alias la='eza -lah --icons=auto --group-directories-first --git'
alias lt='eza --tree --level=2 --icons=auto --group-directories-first'

# ssh: remote machines don't know the "xterm-kitty" terminal
# (nano, htop, vim → "Error opening terminal"). Announce a standard
# terminal that every machine knows, which also works with sudo.
alias ssh='TERM=xterm-256color ssh'

# clear = full terminal reset + fastfetch
# Before clearing, the terminal content is saved to
# ~/.cache/terminal-logs/ (the last 20 are kept).
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

# ── Text-editor-style selection ─────────────────────────────
# Shift + ←/→: select character by character
# Ctrl + Shift + ←/→: select word by word
# Ctrl + A: select the whole command
# Backspace / Delete: erase the selection
# Typing a character: replaces the selection
# ←/→ alone: cancel the selection
# (defined BEFORE the plugins so they pick up these widgets)
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

# Selection color: "neon" style, cyan text on a medium blue
# (same colors as selection_foreground / selection_background in kitty.conf)
zle_highlight=(region:fg=#00e5ff,bg=#2b3d8f paste:none)

# Plugins (syntax-highlighting must stay last)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# change to the next or previous word
bindkey '^[[1;5D' backward-word   # Ctrl + ←
bindkey '^[[1;5C' forward-word    # Ctrl + →

# Editing keys
bindkey '^[[3~'   _sel-delete           # Delete: erase the selection or the character under the cursor
bindkey '^?'      _sel-backspace        # Backspace: erase the selection or the previous character
bindkey '^[[3;5~' kill-word             # Ctrl + Delete: erase the next word
bindkey '^H'      backward-kill-word    # Ctrl + Backspace: erase the previous word
bindkey '^[[H'    beginning-of-line     # Home: start of line
bindkey '^[[F'    end-of-line           # End: end of line

# Selection
bindkey '^[[1;2D' _sel-left             # Shift + ←
bindkey '^[[1;2C' _sel-right            # Shift + →
bindkey '^[[1;6D' _sel-word-left        # Ctrl + Shift + ←
bindkey '^[[1;6C' _sel-word-right       # Ctrl + Shift + →
bindkey '^A'      _sel-all              # Ctrl + A: select all
bindkey '^[[D'    _desel-left           # ← (cancels the selection)
bindkey '^[OD'    _desel-left
bindkey '^[[C'    _desel-right          # → (cancels the selection)
bindkey '^[OC'    _desel-right

# Ctrl + L = same as the clear command (full reset + fastfetch)
_clear_full() {
  zle -I            # tell zsh we are about to write to the screen
  clear             # the clear function above
  zle reset-prompt  # redraw the prompt cleanly
}
zle -N _clear_full
bindkey '^L' _clear_full
