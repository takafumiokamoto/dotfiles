#!/bin/bash
set -euo pipefail

# ダウンロードが途中で切れても中途半端に実行されないよう、全体を関数に包んで最後に呼ぶ。
main() {
    local repo=https://github.com/takafumiokamoto/dotfiles.git
    local project_root="${DOTFILES_DIR:-$HOME/dotfiles}"
    local mise_config="$project_root/configs/mise/config.toml"
    local mise_bin

    if [[ "$(uname -s)" == "Darwin" ]]; then
        # 新品の macOS にも /usr/bin/git はスタブとして存在するので、実体の有無で判定する。
        local clt_git=/Library/Developer/CommandLineTools/usr/bin/git
        if [[ ! -e "$clt_git" ]]; then
            xcode-select --install
            echo "Command Line Tools のインストール完了を待っています(ダイアログで進めてください)"
            until [[ -e "$clt_git" ]]; do
                sleep 5
            done
        fi
    fi

    if [[ ! -d "$project_root/.git" ]]; then
        git clone "$repo" "$project_root"
    fi

    cd "$project_root"

    if [[ "$(uname -s)" == "Darwin" ]]; then
        local brew_bin=/opt/homebrew/bin/brew
        if [[ ! -x "$brew_bin" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        eval "$("$brew_bin" shellenv)"
        brew bundle --verbose --file="$project_root/os/macos/Brewfile"
    elif command -v apt >/dev/null 2>&1; then
        sudo apt -y update
        sudo apt -y upgrade
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Syu --noconfirm
    fi

    if command -v mise >/dev/null 2>&1; then
        mise_bin="$(command -v mise)"
    elif [[ -x "${HOME}/.local/bin/mise" ]]; then
        # miseがPATHにないが、インストールされている場合
        mise_bin="${HOME}/.local/bin/mise"
    else
        curl -fsSL https://mise.run | sh
        mise_bin="${HOME}/.local/bin/mise"
    fi

    export MISE_GLOBAL_CONFIG_FILE="$mise_config"

    "$mise_bin" bootstrap --yes --force-dotfiles

    # mise のツール(blink.cmp のビルドに使う cargo、Linux では nvim 自体)に PATH を通して実行する。
    "$mise_bin" exec -- nvim --headless "+Lazy! restore" +qa
}

# curl | bash だと stdin が端末でなく、Homebrew のインストーラが sudo -n で失敗し、
# mise の chsh もパスワードを読めない。端末があれば stdin をつなぎ直す。
if [[ ! -t 0 ]] && (: </dev/tty) 2>/dev/null; then
    main "$@" </dev/tty
else
    main "$@"
fi
