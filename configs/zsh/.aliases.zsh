alias ls='ls --color=auto'
alias ll='ls -la'

# Neovide: `v` starts it on every OS
if [[ "$OSTYPE" == darwin* ]]; then
    alias neovide='/Applications/Neovide.app/Contents/MacOS/neovide --fork'
    alias v='neovide'
elif [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    alias v="'/mnt/c/Program Files/Neovide/Neovide.exe' --wsl"
elif command -v neovide >/dev/null 2>&1; then
    alias v='neovide --fork'
fi
