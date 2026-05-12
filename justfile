# dotfiles 管理用 just タスク。
# 利用: `cd ~/repo/dotfiles && just <recipe>` または `chezmoi cd && just <recipe>`
# just 自体は Brewfile.tmpl 経由で brew install される。

# 引数なしの実行ではタスク一覧を表示
default:
    @just --list --unsorted

# === chezmoi 基本操作 ===

# リポジトリを最新化してから apply（日常メンテ用）
up: pull apply

# source dir 側で git pull --ff-only
pull:
    chezmoi git pull -- --ff-only

# diff を見せてから apply
apply:
    chezmoi diff
    chezmoi apply -v

# 適用予定の diff のみ表示
diff:
    chezmoi diff

# chezmoi と destination state の健全性チェック
doctor:
    chezmoi doctor
    chezmoi verify

# 編集（chezmoi edit ラッパー、ターゲットパスで指定）
edit target:
    chezmoi edit {{ target }}

# === Brewfile 管理 ===

# 現状の brew bundle を dump して Brewfile.tmpl との diff を表示（更新前確認）
brew-dump:
    @brew bundle dump --force --file=/tmp/current.Brewfile
    @echo "==> dumped to /tmp/current.Brewfile"
    @echo "==> diff vs expanded Brewfile.tmpl (left=current / right=template):"
    @diff <(grep -E '^(tap|brew|cask|vscode|mas) ' /tmp/current.Brewfile | sort -u) \
          <(chezmoi execute-template < Brewfile.tmpl | grep -E '^(tap|brew|cask|vscode|mas) ' | sort -u) \
       || true

# Brewfile.tmpl に書かれていない brew/cask を強制削除（破壊的、確認後に実行）
brew-cleanup:
    #!/usr/bin/env bash
    set -euo pipefail
    BREW="$(mktemp)"
    trap 'rm -f "$BREW"' EXIT
    chezmoi execute-template < Brewfile.tmpl > "$BREW"
    brew bundle cleanup --file="$BREW" --force

# === ホスト固有設定 ===

# 端末ごとのローカル zsh 設定ファイル雛形を作る（gitignore 対象）
hosts-init:
    @mkdir -p ~/.config/zsh/conf.d/hosts
    @touch ~/.config/zsh/conf.d/hosts/local.zsh ~/.config/zsh/conf.d/hosts/local.zshenv
    @echo "==> ~/.config/zsh/conf.d/hosts/{local.zsh,local.zshenv} created"
