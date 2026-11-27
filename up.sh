#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" == "Darwin" ]]; then
    brew update
    brew upgrade --yes
elif command -v apt >/dev/null 2>&1; then
    sudo apt -y update
    sudo apt -y upgrade
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Syu --noconfirm
fi

# パッケージマネージャで入れた mise は self-update がエラーになる(上の更新に含まれる)。
if [[ "$(mise doctor 2>/dev/null)" == *"self_update_available: yes"* ]]; then
    mise self-update --yes
fi
mise up
nvim --headless -c "Lazy! update" -c "qa"
mise prune
