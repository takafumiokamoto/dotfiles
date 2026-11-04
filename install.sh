#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MISE_CONFIG="$PROJECT_ROOT/configs/mise/config.toml"

cd "$PROJECT_ROOT"

if [[ "$(uname -s)" == "Darwin" ]]; then
    brew bundle --file="$PROJECT_ROOT/Brewfile"
fi

if command -v mise >/dev/null 2>&1; then
    MISE_BIN="$(command -v mise)"
elif [[ -x "${HOME}/.local/bin/mise" ]]; then
    # miseがPATHにないが、インストールされている場合
    MISE_BIN="${HOME}/.local/bin/mise"
else
    curl -fsSL https://mise.run | sh
    MISE_BIN="${HOME}/.local/bin/mise"
fi

export MISE_GLOBAL_CONFIG_FILE="${MISE_CONFIG}"

"${MISE_BIN}" bootstrap --yes --force-dotfiles
