#!/bin/bash
set -euo pipefail

mise up
nvim --headless -c "Lazy! update" -c "qa"
if [[ "$(uname -s)" == "Darwin" ]]; then
    brew upgrade -y
fi
mise prune
