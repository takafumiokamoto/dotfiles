[[ -o interactive ]] || return

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

bindkey -e
source "$HOME/.aliases.zsh"

if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if [[ -r "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi
