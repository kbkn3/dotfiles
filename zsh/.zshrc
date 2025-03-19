# alias
alias ls='ls -F --color=auto'

# .zshrc更新したら自動でコンパイルする
if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

# setting
# 新規ファイル作成時のパーミッション
umask 022
# コアダンプを残さない
limit coredumpsize 0

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# antigen
source "${HOME}/.config/zsh/antigen.zsh"

# Load the oh-my-zsh's library
# antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
    # Bundles from the default repo (robbyrussell's oh-my-zsh)
    git
    # Syntax highlighting bundle.
    zsh-users/zsh-syntax-highlighting
    # Fish-like auto suggestions
    zsh-users/zsh-autosuggestions
    # Extra zsh completions
    zsh-users/zsh-completions
    # z
    rupa/z z.sh
    # abbr
    olets/zsh-abbr@main
EOBUNDLES

# Load the theme
antigen theme robbyrussell

# Tell antigen that you're done
antigen apply

# starship
eval "$(starship init zsh)"

# mise
if type mise &>/dev/null; then
  eval "$(mise activate zsh)"
  eval "$(mise activate --shims)"
fi

# coreutils
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# 端末ごとの設定を読み込み
# ホスト名を取得
local host_name="$(hostname)"

# ローカル設定ファイルが存在する場合は読み込む
local_conf="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/conf.d/hosts/local.zsh"
if [ -f "$local_conf" ]; then
  source "$local_conf"
fi

