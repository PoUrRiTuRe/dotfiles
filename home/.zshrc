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

# Plugins (syntax-highlighting must stay last)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# change to the next or previous word
bindkey '^[[1;5D' backward-word   # Ctrl + ←
bindkey '^[[1;5C' forward-word    # Ctrl + →

# Ctrl + L = même chose que la commande clear (reset complet + fastfetch)
_clear_full() {
  zle -I            # prévient zsh qu'on va écrire à l'écran
  clear             # la fonction clear ci-dessus
  zle reset-prompt  # réaffiche le prompt proprement
}
zle -N _clear_full
bindkey '^L' _clear_full
