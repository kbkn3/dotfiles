
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# history
setopt hist_ignore_dups
setopt EXTENDED_HISTORY
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_no_store
setopt hist_expand
setopt share_history

# interactive
export LISTMAX=50
unsetopt bg_nice
setopt list_packed
setopt no_beep
unsetopt list_types

# alias
alias ls='ls -F --color=auto'

# .zshrc更新したら自動でコンパイルする
if [ "$ZDOTDIR/.zshrc" -nt "$ZDOTDIR/.zshrc.zwc" ]; then
  zcompile "$ZDOTDIR/.zshrc"
fi

# setting
# 新規ファイル作成時のパーミッション
umask 022
# コアダンプを残さない
limit coredumpsize 0

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# antigen
export _ANTIGEN_INSTALL_DIR=${HOME}/.local/bin
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
# ローカル設定ファイルが存在する場合は読み込む
local_conf="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/conf.d/hosts/local.zsh"
[[ -f "$local_conf" ]] && source "$local_conf"



# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
