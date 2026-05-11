# path
export PATH=${HOME}/.local/bin:$PATH
export PATH="/usr/local/sbin:$PATH"

# lang
export LANGUAGE="en_US.UTF-8"
export LANG="${LANGUAGE}"
export LC_ALL="${LANGUAGE}"
export LC_CTYPE="${LANGUAGE}"

# editor
export EDITOR=vim
export CVSEDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export GIT_EDITOR="${EDITOR}"

# history
export HISTFILE=${XDG_STATE_HOME}/zsh/history
export HISTSIZE=1000
export SAVEHIST=100000

# 端末ごとの環境変数設定を読み込み
# ローカル環境変数ファイルが存在する場合は読み込む
local_env_conf="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/conf.d/hosts/local.zshenv"
if [ -f "$local_env_conf" ]; then
  source "$local_env_conf"
fi
