#!/usr/bin/env bash
# 新 PC で dotfiles をワンライナー展開するためのブートストラップ。
#
# 使い方:
#   curl -fsSL https://raw.githubusercontent.com/kbkn3/dotfiles/chezmoi/bootstrap.sh | bash
#
# やること:
#   1. Homebrew をインストール（未導入なら）
#   2. chezmoi をインストール（未導入なら）
#   3. kbkn3/dotfiles@chezmoi を init --apply
#      - chezmoi init は profile / name / email を対話で聞く（stdin が pipe なので /dev/tty を明示）
#      - apply 内で .chezmoiscripts/run_onchange_after_01-brew-bundle.sh が走り
#        Brewfile.tmpl の brew/cask を一括インストール

set -euo pipefail

REPO="kbkn3/dotfiles"
BRANCH="chezmoi"

log() {
  printf '\033[1;32m==>\033[0m %s\n' "$*"
}

# === 1. Homebrew ===
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty

  # 当該セッションに PATH を通す（Apple Silicon / Intel どちらでも対応）
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "brew インストールに失敗。手動で対処してください。" >&2
    exit 1
  fi
else
  log "Homebrew is already installed"
fi

# === 2. chezmoi ===
if ! command -v chezmoi >/dev/null 2>&1; then
  log "Installing chezmoi"
  brew install chezmoi
else
  log "chezmoi is already installed"
fi

# === 3. dotfiles 初期化 + 適用 ===
log "Initializing chezmoi from $REPO@$BRANCH"
# パイプ経由実行時に stdin が pipe になっていても対話プロンプトを動かすため /dev/tty を明示
chezmoi init "$REPO" --branch "$BRANCH" --apply </dev/tty

log "Done. 次のステップ:"
cat <<'NEXT'

  # 認証系（手動）
  ssh-keygen -t ed25519 -C "kbkn3"   # 新 PC で SSH 鍵を発行 → GitHub 登録
  gh auth login                       # GitHub CLI
  aws configure sso                   # 社内 SSO セッション
  op signin                           # 1Password CLI

  # ホスト固有 zsh 設定の枠
  chezmoi cd && just hosts-init

  # 情シス配布で別途入るもの (Brewfile 管理外):
  #   Google Chrome / Slack

NEXT
