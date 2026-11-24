# dotfiles 改善アイデア一覧

2026-11-20 時点(コミット `21da495`)のレビュー結果です。優先度の高い順に並べています。

- 特記のない項目は、この Mac 上の実測かソースコードで確認済みです。
- Windows と WSL に関する項目は実機で動かしておらず、ソースとドキュメントからの導出です。
- 「未検証」と書いた項目は、ドキュメントの記載や推定にとどまります。
- Neovim の項目は、方向とヘルプタグだけを書いています。
- 各項目の先頭にある ID は、節ごとの接頭辞と連番です。接頭辞は R(再現性)、B(不具合)、U(使い勝手)、M(運用)、S(見送り)、N(実装メモ)、C(その他の候補)、X(リポジトリ外)です。項目を並べ替えたり消したりしても、ID は振り直さない想定です。

## 1. 別マシンで再現しない箇所

- [ ] `R-01` **Linux/WSL に Neovim が入らない**
  - 現状: `d74ae9b` で `[tools]` から外れ、`os/macos/Brewfile:1` だけになっています。Ubuntu 26.04 の apt は 0.11.6 ですが、この設定(`configs/nvim/lua/config/options.lua:33`)も Neovide 0.17 系も 0.12 以上が必須です。
  - 対応: `configs/mise/config.toml` の `[tools]` に `neovim = { version = "latest", os = ["linux"] }` を足し、`mise lock` でロックを更新します。Mac に残っている mise 版(`mise ls neovim` に出る 0.12.6)を `mise uninstall` で消すと、`nvim` が shim を経由しなくなります。
- [ ] `R-02` **`~/.gitconfig` が既存マシンに届かない**
  - 現状: `configs/mise/config.toml:118` が `copy` と `create_if_missing` の組み合わせなので、既にファイルがあるマシンには反映されません。この Mac では `useConfigOnly`(`configs/git/.gitconfig:3`)が効いておらず、コミットのメールアドレスが複数混在しています。`configs/git/.gitconfig:5-7` の credential helper は Unix 専用のパスですが、Windows にもコピーされます。
  - 対応: 共有する設定を `configs/git/config` に移し、`~/.config/git/config` へ symlink します。`~/.gitconfig` はマシンローカル(メールアドレス用)とし、今の seed エントリは残します。`~/.gitconfig` が無い状態で `git config --global` を実行すると、symlink 越しに追跡中のファイルへ書き込まれるためです。credential helper は Unix だけに配ります。
- [ ] `R-03` **WezTerm は WSL のディストリ名が一致しないと起動しない**
  - 現状: `configs/wezterm/wezterm.lua:16-20` が `WSL:Ubuntu-26.04` を固定で指定しています。winget で入る版(20240203)では、その名前のドメインが無いとエラー通知を出して終了します。
  - 対応: `wezterm.default_wsl_domains()` の結果に名前があるときだけ `default_domain` を設定します。
- [ ] `R-04` **Neovide の設定が Windows で効かない**
  - 現状: `configs/mise/config.toml:112` は全 OS で `~/.config/neovide` にリンクしますが、Windows の Neovide が読むのは `%APPDATA%\neovide\config.toml` です。さらに `configs/neovide/config.toml:1` の `frame = "buttonless"` は macOS 専用の値で、Windows で読ませるとファイル全体(フォント指定を含む)が破棄されます。
  - 対応: `[dotfiles]` の `variants` で Windows 用の `target` を分け、Windows 用のファイルから `frame` を外します。より小さい対応は、フォントを `guifont` に戻して(`:h 'guifont'`)`config.toml` を macOS 専用にすることです。
- [ ] `R-05` **Windows にフォントが入らない**
  - 現状: `configs/wezterm/wezterm.lua:9` は Moralerspace Neon を `configs/wezterm/fonts` から読みますが、`.gitignore:4` で `*.ttf` を除外しています。kitty と Neovide は Guguru Sans Code で、これを入れるのは `os/macos/Brewfile:2` だけです。
  - 対応: フォントを 1 つに揃え、Windows での入手手順を README に書きます。
- [ ] `R-06` **`.gitattributes` が無い**
  - 現状: Git for Windows の既定(`core.autocrlf=true`)でクローンすると、`install.sh` と zsh のファイルが CRLF になり動きません。
  - 対応: `* text=auto eol=lf` と `*.ps1 text eol=crlf` の 2 行を置き、`git add --renormalize .` を 1 回コミットします。ロックファイルに `linguist-generated` を付けると、GitHub の差分表示も畳まれます。
- [ ] `R-07` **mise のバージョン差に備える**
  - 現状: 設定が実験的機能に依存していますが、mise のバージョンを縛るものがありません。上流は 2026.11.8 で `[bootstrap.macos.*]` を `[bootstrap.settings.macos.*]` に改名済みで、古い mise は新しい表記を警告だけ出して無視します。
  - 対応: `min_version = { hard = "...", soft = "..." }` を `configs/mise/config.toml` の先頭に置きます。改名は全マシンの更新後に、`min_version` の引き上げと同じコミットで行います。
- [ ] `R-08` **手で設定済みの macOS 設定をリポジトリに書く**
  - 現状: タイル時の余白オフ、デスクトップのアイコンとウィジェットの非表示、ダークモードは、この Mac では設定済みですが `configs/mise/config.toml:21-44` にありません。
  - 対応: `[bootstrap.macos.defaults."com.apple.WindowManager"]` に `EnableTiledWindowMargins`、`StandardHideDesktopIcons`、`StandardHideWidgets` を足し、`NSGlobalDomain` に `AppleInterfaceStyle = "Dark"` を足します。
- [ ] `R-09` **ネイティブ Windows で使われないツールが入る**
  - 現状: `install.ps1:33` は `[tools]` のほぼ全部(36 個)を入れますが、PowerShell で mise を有効化していないので使う経路がありません。
  - 対応: WSL のホストとしてだけ使うなら `--skip tools` を付けます。

## 2. すぐ直せる不具合

### Neovim

- [ ] `B-01` **mode `"v"` のマッピングが Select モードでも発火する**
  - 現状: `configs/nvim/lua/config/keymaps.lua:7-8,41-44` の I、A、`<`、`>`、J、K が対象です。スニペットのプレースホルダで K や J から打ち始めると、行移動などが実行されます。また I と A は、既に矩形選択中だと 1 行しか編集しません。
  - ヒント: `:h mapmode-x`、`:h Select-mode-mapping`、`:h v_b_I`
- [ ] `B-02` **`cmdheight=0` で入力途中のキー、マクロ記録、検索件数が見えない**
  - 現状: `configs/nvim/lua/config/options.lua:9,30,33` の組み合わせで、最下行に出るはずの表示が全て消えます。
  - ヒント: `:h 'showcmdloc'`。ステータスラインを自作するなら `:h reg_recording()` と `:h searchcount()`
- [ ] `B-03` **`<S-F5>` と `<S-F11>` がターミナル版の Neovim に届かない**
  - 現状: `configs/nvim/lua/plugins/dap.lua:16,21` です。ターミナルでは `<F17>` と `<F23>` として届きます。同じファイルの `<F35>`(20 行目)と同じ理由です。Neovide では動きます。
  - ヒント: 挿入モードで `<C-v>` に続けてキーを押すと、届いている名前を確認できます。`:h i_CTRL-V`、`:h key-notation`
- [ ] `B-04` **Neovide のアニメーション切替が ON にしかならない**
  - 現状: `configs/nvim/lua/config/neovide.lua:60-62` は 36 行目のフラグを反転して渡すだけで、フラグ自体を更新していません。
  - ヒント: 状態を読む前に書き換えるか、`vim.g.neovide_*` の値から状態を導きます。
- [ ] `B-05` **`<c-\>` のターミナルモード割り当てが `<C-\><C-n>` を塞いでいる**
  - 現状: `configs/nvim/lua/plugins/snacks.lua:38-43` です。DAP のコンソールや `:terminal` から標準の方法で抜けられません。
  - ヒント: `:h t_CTRL-\_CTRL-N`
- [ ] `B-06` **保存時整形に穴がある**
  - 現状: `.winget` は yaml 扱い(`configs/nvim/lua/config/options.lua:35`)で oxfmt に渡りますが、oxfmt が拡張子を拒否して毎回失敗します。`tsconfig.json` は `jsonc` と判定されますが、`configs/nvim/lua/plugins/format.lua` に `jsonc` がありません。16 行目の `yml` は存在しない filetype です。
  - ヒント: `:h conform-options`、`:h conform-formatters`
- [ ] `B-07` **Neovide のターミナルモードで Cmd+V が効かない**
  - 現状: `configs/nvim/lua/config/neovide.lua:2-3` の対象モードに `t` がありません。
  - ヒント: `:h nvim_paste()`
- [ ] `B-08` **ui2 の呼び出しが失敗すると設定全体が止まる**
  - 現状: `configs/nvim/lua/config/options.lua:33` は実験的な API で、`init.lua` が最初に読むファイルにあります。API が変わると、キーマップも LSP も読み込まれません。
  - ヒント: `pcall` で囲みます。
- [ ] `B-17` **`<leader>tf` で現在のバッファを新しいタブに開けない**
  - `configs/nvim/lua/config/keymaps.lua:21` が呼ぶ `:tabsplit` は、Neovim 0.12.6 で `E492` になります。
  - `:tab split` で同じバッファが新しいタブに開くことを確認済みです。ヘルプは `:h :tab`。

### zsh とプロンプト

- [ ] `B-09` **Delete、Home、End が効かない**
  - 現状: `configs/zsh/.zshenv:9` の `EDITOR=nvim` により、macOS の `/etc/zshrc` のバインドが vi キーマップに入ります。その後 `configs/zsh/.zshrc:11` の `bindkey -e` で emacs キーマップに切り替わるため、これらのキーは未定義になります。
  - 対応: `bindkey -e` の直後で明示的に割り当てます。Delete は `^[[3~` を `delete-char` に、Home は `^[[H` と `^[OH` を `beginning-of-line` に、End は `^[[F` と `^[OF` を `end-of-line` に割り当てます。
- [ ] `B-10` **Python のディレクトリでプロンプト記号の前に空白が入る**
  - 現状: `configs/starship/starship.toml:28` の `format` が、仮想環境がなくても末尾の空白を出します。
  - 対応: `format = "([$virtualenv]($style) )"` と括弧で囲みます(動作確認済み)。
- [ ] `B-11` **`ask` と `askx` が呼び出し元のシェルを移動させる**
  - 現状: `configs/zsh/.zshrc:26-27` が現在のシェルで `cd ~/ask` します。
  - 対応: 本体を `( ... )` のサブシェルにします。
- [ ] `B-12` **`neovide` エイリアスが Linux でも定義される**
  - 現状: `configs/zsh/.aliases.zsh:3` は macOS の絶対パスです。WSL 用の `v` は `configs/zsh/.zshenv:4-6` にあります。
  - 対応: `.aliases.zsh` に OS 判定つきでまとめ、どの OS でも `v` で起動できるようにします。

### macOS

- [ ] `B-13` **Ctrl+Space が macOS に取られている**
  - 現状: 入力ソース切替のホットキー(ID 60 と 61)が有効なので、Neovim に `<C-space>` が届きません。blink.cmp ではこれがドキュメント表示の唯一のキーです(`configs/nvim/lua/plugins/blink-cmp.lua:12-13`)。入力切替は Karabiner で済んでいます。
  - 対応: `[[bootstrap.macos.defaults_entries]]` を 2 つ足します。`domain = "com.apple.symbolichotkeys"`、`key = "AppleSymbolicHotKeys"`、`path = ["60", "enabled"]`(もう 1 つは `"61"`)、`value = false` です。反映には再ログインが必要です。
- [ ] `B-14` **Hyper + ピリオドで sysdiagnose が走る**
  - 現状: `configs/karabiner/karabiner.json:20-34` の右⌘が本物の ⌃⌥⇧⌘ を送るので、割り当てのないキーはそのまま macOS に届きます。⌃⌥⇧⌘ + ピリオドは sysdiagnose の起動キーです(`man sysdiagnose`)。
  - 対応: Hyper + ピリオド(念のためカンマ、W、Q も)を `vk_none` に割り当てるルールを足します。
- [ ] `B-15` **Amethyst が何もタイルしていない**
  - 現状: `21da495` 以降、`configs/amethyst/amethyst.yml:1-2` は `floating-is-blacklist: false` と空のリストの組み合わせで、全ウィンドウがフロート扱いです。常駐とショートカットの占有は続いています。
  - 対応: macOS 標準のタイル(Karabiner の Hyper キー)に寄せて Amethyst を外すか、Amethyst に寄せるかを決めます。

### WezTerm

- [ ] `B-16` **ホイールが `less` や `man` で効かない**
  - 現状: `configs/wezterm/wezterm.lua:77-86` の 2 つのバインドに `alt_screen` の指定がなく、代替画面でもホイールを横取りします。
  - 対応: 両方に `alt_screen = false` を足します。

## 3. 日常の使い勝手

### シェルと git

- [ ] `U-01` **zsh の補完を初期化する**
  - 現状: macOS では `compinit` がどこからも呼ばれておらず、Tab はファイル名補完だけです。
  - 対応: `configs/zsh/.zshrc` の fzf の行より前で `compinit` を実行します。mise で入れたツールの補完は、各コマンドが生成できます(`mise completion zsh`、`gh completion -s zsh`、`task --completion zsh`、`uv generate-shell-completion zsh` など)。Ubuntu では配布元の zshrc が先に `compinit` を実行するため、`.zshenv` に `skip_global_compinit=1` が要る見込みです(未検証)。
- [ ] `U-02` **履歴オプションを設定する**
  - 現状: `configs/zsh/.zshrc:7-9` はサイズだけで、オプションは全て既定値です。履歴はシェル終了時にしか書かれず、重複もそのまま残ります。
  - 対応: `INC_APPEND_HISTORY`、`HIST_IGNORE_DUPS`、`HIST_IGNORE_SPACE` を設定します。`SHARE_HISTORY` は、複数ペインで↑キーの履歴が混ざるので勧めません。
- [ ] `U-03` **ディレクトリ移動を短くする**
  - 現状: 履歴の約 4 割が `cd` と `ll` です。
  - 対応: `cdpath=(~ ~/git)`、`setopt AUTO_CD`、既に使える fzf の Alt-C で足ります。
- [ ] `U-04` **↑キーで前方一致の履歴検索**
  - 対応: `up-line-or-beginning-search` と `down-line-or-beginning-search` を↑↓に割り当てます。
- [ ] `U-05` **git の既定動作を追跡ファイルに書く**
  - 現状: 追跡しているのは名前と credential helper だけです。
  - 対応: 候補は `init.defaultBranch = main`(Apple 同梱の設定が効かない環境では `master` になります)、`pull.rebase` と `rebase.autoStash`、`fetch.prune`、`core.quotePath = false`(日本語ファイル名がエスケープ表示されなくなります)です。

### Neovim

- [ ] `U-06` **入れているのに配線されていない言語ツール**
  - 現状: rust-analyzer(`configs/mise/config.toml:70`)に対応する `configs/nvim/lsp/` のファイルがありません。bash-language-server は shellcheck が無いと lint を無効にします。Python には formatter も linter もありません。
  - ヒント: Rust は `lsp/gopls.lua` と同じ形のファイルを 1 つ足します(`:h lsp-config`、`:h lsp-root_markers`)。shellcheck は mise の `[tools]` に足すだけで bashls が拾います。Python は ruff(`ruff server`)が候補です。
- [ ] `U-07` **診断の見え方を決める**
  - 現状: `vim.diagnostic.config()` の呼び出しがなく、0.12 の既定(sign と下線だけ)です。
  - ヒント: `:h vim.diagnostic.config()`、`:h vim.diagnostic.Opts.VirtualText`、`:h diagnostic-on-jump-example`
- [ ] `U-08` **JSON サーバーを新しい方に替える**
  - 現状: `configs/nvim/lsp/jsonls.lua:2` は 2021 年版の `vscode-json-languageserver`(`configs/mise/config.toml:56`)を使っています。57 行目の `vscode-langservers-extracted` に、新しい `vscode-json-language-server` が入っています。スキーマも渡していません。
  - ヒント: コマンドを差し替えて 56 行目を削り、`settings.json.schemas` に使うものだけを列挙します。
- [ ] `U-09` **DAP の構成を広げる**
  - 現状: Go は `configs/nvim/lua/plugins/dap.lua:80-88` が現在のファイルだけを対象にするので、複数ファイルの `package main` で失敗します。lldb-dap の構成は C だけです(103 行目)。
  - ヒント: Go はパッケージ単位とテスト用(delve の `mode = "test"`)を足します。cpp と rust は C の構成を使い回せます。`:h dap-configuration`
- [ ] `U-10` **保存時整形にオフスイッチを付ける**
  - 現状: `configs/nvim/lua/plugins/format.lua:24-27` は固定のテーブルで、無効化できません。また JSON は `configs/editorconfig/.editorconfig:14` の 2 スペース対象に入っていないため、`package.json` が 4 スペースに直されます。
  - ヒント: conform の `doc/recipes.md` にある「Command to toggle format-on-save」
- [ ] `U-11` **小さな autocmd を 3 つ足す**
  - 現状: `configs/nvim/lua/config/autocmd.lua` は、存在しないカラースキーム用の 1 つだけです。
  - ヒント: ヤンクのハイライト(`:h vim.hl.on_yank()`)、前回のカーソル位置の復元(`:h restore-cursor`)、リサイズ時の分割の均等化(`:h VimResized`)
- [ ] `U-12` **同梱プラグインを有効にする**
  - 現状: 0.12 には `:Undotree` と `:Cfilter` が入っていますが、既定では読み込まれません。
  - ヒント: `:h package-undotree`、`:h package-cfilter`
- [ ] `U-13` **fzf-lua に keymaps、helptags、resume を足す**
  - 現状: 約 95 個あるキーマップを一覧する手段がありません。`configs/nvim/lua/plugins/fzf.lua:12-31` の `<leader>f` 配下は ff、fg、fb だけです。
- [ ] `U-14` **gitsigns と codediff の未使用機能を使う**
  - 現状: `configs/nvim/lua/plugins/gitsigns.lua:14-17` はハンク移動だけです。Diffview を消した `af9c87b` で、ファイル履歴とハンクのリセットが無くなりました。
  - ヒント: `:Gitsigns preview_hunk_inline`、`:Gitsigns blame_line`、`:CodeDiff history`、`:h gitsigns-functions`
- [ ] `U-15` **`background` を明示する**
  - 現状: 未設定なので、Neovide は OS の外観に合わせます。ライトモードの OS では明るい配色で起動します。
  - ヒント: `:h 'background'`
- [ ] `U-16` **残骸を掃除する**
  - `configs/nvim/lua/plugins/codediff.lua:9-16` の色は、前のテーマの背景色で計算した値です。
  - `configs/nvim/lsp/lua_ls.lua:11` の `hs` は Hammerspoon の名残です。
  - `configs/nvim/lua/config/lazy.lua:21-22` は leader 設定の重複です。
  - `configs/nvim/lua/config/autocmd.lua:1-6` は、インストールされていないカラースキーム用です。
- [ ] `U-20` **LSP が使えないバッファでも `gd` と `gD` で宣言に移動できるようにする**
  - `configs/nvim/lua/plugins/fzf.lua:16-17` は両方のキーを全バッファで fzf-lua に割り当てます。LSP 未接続時は通知だけで終わり、Neovim 標準のバッファ内検索も使えません。
  - 定義・宣言への移動をサーバーがサポートする場合だけ、それぞれのキーに LSP の検索を割り当てます。ヘルプは `:h LspAttach`、`:h gd`、`:h gD`。
- [ ] `U-21` **異常終了後に未保存の編集を復旧できるようにする**
  - `configs/nvim/lua/config/options.lua:10,25` で undo 履歴を保存していますが、履歴がディスクに書かれるのはファイルの保存時です。スワップを無効にしているため、最後の保存以降の編集を `:recover` で取り出せません。
  - `swapfile` を有効にすると、既定ではプロジェクトの外にある Neovim の状態ディレクトリにスワップが作られます。ヘルプは `:h crash-recovery`、`:h 'directory'`。

### ターミナルと herdr

- [ ] `U-17` **kitty の新しいタブが作業ディレクトリを引き継がない**
  - 対応: `cmd+t` を `new_tab_with_cwd` に割り当てます。`scrollback_lines` も既定の 2000 行のままです。
- [ ] `U-18` **herdr の Claude/Codex 連携を入れる**
  - 現状: `herdr integration status` はどちらも未インストールです。サーバー再起動後、エージェントのペインが会話を再開できません。
  - 対応: `herdr integration install claude` と `herdr integration install codex` を実行します。`~/.claude/settings.json` などにフックが書き込まれます。
- [ ] `U-19` **herdr の日本語入力向けオプション**
  - 現状: `configs/herdr/config.toml` に `[experimental]` がありません。
  - 対応: `switch_ascii_input_source_in_prefix` は、IME がオンでも prefix キーを効かせます。`reveal_hidden_cursor_for_cjk_ime` と `cjk_ime_agents` は、変換候補ウィンドウをペインに追従させます。どちらも macOS 専用で、実験的扱いです。

## 4. 運用

- [ ] `M-10` **セットアップ時の既存 dotfiles の上書きを明示指定にする**
  - `install.sh:30` と `install.ps1:33` は毎回 `--yes --force-dotfiles` を渡します。たとえば Unix で手書きの `~/.zshrc` があると、そのファイルも確認なしでリンクに置き換わります。
  - `--force-dotfiles` は上書きを指定したときだけ渡します。初回はスクリプトと同じ `MISE_GLOBAL_CONFIG_FILE` を指定して `mise bootstrap --only dotfiles --dry-run` で対象を確認し、必要な設定を退避してから適用できます。
- [ ] `M-01` **生成ファイルをフォーマッタから守る**
  - 現状: `4c0c728` で oxfmt がロックのサイドカー(`configs/mise/locks/`)を整形し、ダイジェストが変わって同じバージョンのツールが入り直しています。`configs/karabiner/karabiner.json` も、oxfmt の書式と Karabiner 自身の書式が食い違っています。
  - 対応: リポジトリ直下に `.oxfmtrc.json` を置き、`ignorePatterns` に `configs/mise/locks/**`、`configs/mise/mise.lock`、`configs/nvim/lazy-lock.json`、`configs/karabiner/**`、`configs/kbd/**` を入れます。`~/.config/...` 側のパスで開いたファイルには効かないので、必要なら conform 側でも除外します。
- [ ] `M-02` **README を書く**
  - 内容: OS ごとの前提とコマンド、ブートストラップ後の手作業(`gh auth login`、git のメールアドレス、Karabiner の権限、Windows のフォントと WSL、キーボードレイアウトの読み込み)、復元されないものの一覧。リポジトリは public でライセンス未設定です。
- [ ] `M-03` **リポジトリ直下に `AGENTS.md` を置く**
  - 現状: 規約が Claude Code のマシンローカルなメモリにしかなく、Codex や他のマシンからは見えません。
  - 内容: 構成の要点、勝手に実行しないコマンド(`install.sh`、`mise bootstrap`、`mise upgrade`)、読み取り専用の確認コマンド、生成ファイル、Neovim はヒントとレビューで進めるという方針。Claude Code は `CLAUDE.md` が無いときだけ `AGENTS.md` を読みます。
- [ ] `M-04` **グローバル gitignore に Claude Code のローカルファイルを入れておく**
  - 現状: Claude Code は初回に `**/.claude/settings.local.json` をグローバルの除外ファイルへ自分で追記します。`~/.config/git/ignore` は symlink なので、追跡中の `configs/git/ignore` が書き換わります。
  - 対応: 先に `configs/git/ignore` へ書いておきます。
- [ ] `M-05` **エージェントの設定を merge エントリで管理する**
  - 現状: `~/.claude/settings.json` と `~/.codex/config.toml` は追跡されていません。どちらもツールが自分で書き換えるので、symlink は向きません。
  - 対応: `[dotfiles]` のキーを `"~/.claude/settings.json/<id>"` の形にすると、指定したキーだけを管理できます。アプリが変える値は `merge = "missing"` にします。`hooks` のような配列は丸ごと置き換えられるので、対象にしません。
- [ ] `M-06` **`.gitignore` に 3 つ追加する**
  - 対応: `*.log`(`nvim.log` が過去に 2 回コミットされています)、`configs/kitty/*.bak`、`configs/mise/config.local.toml`(mise のマシンローカル設定)を足します。
- [ ] `M-07` **古いツールバージョンを消す**
  - 現状: `mise prune --dry-run` で 47 バージョン、約 7 GB が対象です。
  - 対応: 内容を確認してから `mise prune` を実行します。
- [ ] `M-08` **Brewfile を `[bootstrap.packages]` に移す**
  - 現状: `install.sh:15` の `brew bundle` は、再実行時にアップグレードも行います。宣言していない cask が 5 つあります(discord、foobar2000、google-chrome、tidal、font-moralerspace)。
  - 対応: 各エントリを `"brew-cask:<名前>" = { os = "macos" }` の形で書きます。先に未宣言分を整理してください。`mise bootstrap packages prune` は宣言外のものを削除するので、実行しないでください。最小の対応は `--no-upgrade` を付けることです。
- [ ] `M-09` **npm と uv にもリリース後の待機期間を設ける(未検証)**
  - 現状: mise 管理のツールには 24 時間の待機が効いていますが、npm と uv にはありません。
  - 対応: `[env]` に `NPM_CONFIG_MIN_RELEASE_AGE` と `UV_EXCLUDE_NEWER` を置きます。

## 5. 見送ったもの

- `S-01` **3 つの OS での週次 CI:** 全ツールが `latest` 追従なので、上流の都合で失敗しやすくなります。入れるなら、Ubuntu で実際にブートストラップするジョブ 1 つです。
- `S-02` **update や doctor のラッパータスク:** `mise bootstrap --update --upgrade` と `mise bootstrap status` で足ります。
- `S-03` **zoxide と zsh-autosuggestions:** fzf の既存機能と重なります。
- `S-04` **Renovate と Dependabot:** `mise.lock` は自前ホストが必要で、lazy.nvim には対応していません。
- `S-05` **ui2 のメッセージ表示先の変更:** 実験的機能の上に設定を重ねることになります。
- `S-06` **コミット署名と SSH の設定:** 鍵を使っておらず、HTTPS と gh で完結しています。

## 6. 実装メモ

- `N-01` **グローバルタスクの実行場所:** mise のグローバルタスクは既定で `$HOME` で実行されます。リポジトリを指すには、`[vars]` で `config_source` からパスを組み立てます。
- `N-02` **フックの冪等性:** `[bootstrap.hooks]` と `bootstrap` タスクは、`mise bootstrap` のたびに走ります。
- `N-03` **自動削除の範囲:** `upgrade.auto_prune` は、`mise upgrade` が置き換えた版しか消しません。この構成では実質何も消えていないようです(未再現)。
- `N-04` **herdr の更新:** `herdr update` と `herdr channel set` は使わないでください。herdr 0.9.5 は mise 経由のインストールを検出できず、後者は symlink 越しに追跡中の設定を書き換えます(未実行)。
- `N-05` **merge エントリ:** `variants` は付けられません。
- `N-06` **brew と brew-cask のエントリ:** `latest` 以外は指定できず、`apply` はアップグレードしません。

## 7. その他の候補

優先度は低めです。

- `C-01` **TOML の言語サーバー:** tombi と mise 公式スキーマで、`config.toml` に補完と検証を付けられます(未検証)。
- `C-02` **Go:** 保存時の import 整理、モジュールキャッシュのファイルを開くと gopls が増える問題、未配線の golangci-lint(`configs/mise/config.toml:51`)があります。
- `C-03` **Treesitter:** tree-sitter-manager はパーサを再ビルドしないので、プラグイン更新時にクエリとずれる可能性があります(未検証)。
- `C-04` **blink.cmp と oil のキー:** blink.cmp の `<C-e>` はメニュー表示中だと閉じる動作になり、行末移動(`configs/nvim/lua/config/keymaps.lua:52`)に 2 回押す必要があります。oil の `<C-h>` と `<C-l>` は、ウィンドウ移動を上書きします。
- `C-05` **WezTerm のプラグイン:** bar.wezterm がバージョン固定なしのリモートプラグインです(`configs/wezterm/wezterm.lua:89`)。
- `C-06` **Karabiner:** Escape で英数も送るルールが公式ギャラリーにあります(ターミナルの Vim 向け)。
- `C-07` **キーボードレイアウト:** `configs/kbd/m60h.layout.json` は VIA のエクスポートです。復元手順を README に書きます。
- `C-08` **adr-tools:** `configs/mise/config.toml:106` で入れていますが未使用です。外すか、決定の記録を数件だけ残すかを決めます。
- `C-09` **winget のアプリ:** 3 つを `[bootstrap.packages]` の `winget:` エントリに移せます(未検証)。
- `C-10` **綴りの誤り:** `defualtDomain`(`configs/wezterm/wezterm.lua:16`)、`neovide_animaiton_enable`(`configs/nvim/lua/config/neovide.lua:36`)、`explictly`(`configs/ask/AGENTS.md:3`)。
- `C-11` **値の型:** `configs/mise/config.toml:99` の `symlink_bins = "true"` が文字列です。
- `C-12` **zsh を入れ子で起動しても `PATH` を重複させない**。`configs/zsh/.zshenv:1` は起動ごとに `~/.local/bin` を先頭に追加します。追加前に `typeset -U path PATH` を置くと、設定を 2 回読んでも同じパスが 1 件に保たれます。

## 8. リポジトリ外

- `X-01` **バックアップ:** Time Machine の保存先が未設定で、`~/git` に git 管理外のプロジェクトがあります(iCloud などは未確認)。
