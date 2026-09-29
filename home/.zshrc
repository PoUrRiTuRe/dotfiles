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

# Plugins (syntax-highlighting must stay last)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# change to the next or previous word
bindkey '^[[1;5D' backward-word   # Ctrl + ←
bindkey '^[[1;5C' forward-word    # Ctrl + →
