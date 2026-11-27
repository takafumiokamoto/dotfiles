#!/bin/bash
set -euo pipefail

# ダウンロードが途中で切れても中途半端に実行されないよう、全体を関数に包んで最終行で呼ぶ。
main() {
    local repo=https://github.com/takafumiokamoto/dotfiles.git
    local dest="${DOTFILES_DIR:-$HOME/dotfiles}"

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

    if [[ ! -d "$dest/.git" ]]; then
        git clone "$repo" "$dest"
    fi

    # パイプ実行のままだと stdin が端末でなく、Homebrew のインストーラが sudo -n で失敗する。
    exec "$dest/install.sh" </dev/tty
}

main "$@"
