#!/bin/bash

# 必要なディレクトリを作成
mkdir -p "${HOME}/.config/zsh"
mkdir -p "${HOME}/.config/.bin"

# dotfilesのディレクトリ
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

# シンボリックリンクを作成する関数
create_symlink() {
  local src=$1
  local dst=$2
  
  if [ ! -e "$src" ]; then
    echo "警告: ソースファイル $src が存在しません。リンクはスキップします。"
    return 1
  fi
  
  if [ -e "$dst" ]; then
    echo "既に存在します: $dst"
    read -p "バックアップを作成して上書きしますか? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "バックアップを作成: ${dst}.backup"
      mv "$dst" "${dst}.backup"
      ln -sf "$src" "$dst"
      echo "リンクを作成: $src -> $dst"
    fi
  else
    ln -sf "$src" "$dst"
    echo "リンクを作成: $src -> $dst"
  fi
  
  return 0
}

# 1. home.zshenvを$HOME/.zshenvにシンボリックリンク
create_symlink "${DOTFILES_DIR}/zsh/home.zshenv" "${HOME}/.zshenv"

# 2. 元の.zshenvを.config/zsh/.zshenvにリンク
create_symlink "${DOTFILES_DIR}/zsh/.zshenv" "${HOME}/.config/zsh/.zshenv"

# 3. .zshrcを.config/zsh/.zshrcにリンク
create_symlink "${DOTFILES_DIR}/zsh/.zshrc" "${HOME}/.config/zsh/.zshrc"

# 4. antigen.zshのシンボリックリンクを作成
create_symlink "${DOTFILES_DIR}/zsh/antigen.zsh" "${HOME}/.config/zsh/antigen.zsh"

# 履歴ファイル用のディレクトリ確認
if [ ! -e "${HOME}/.config/zsh/.zsh_history" ]; then
  echo "履歴ファイルを作成します: ${HOME}/.config/zsh/.zsh_history"
  touch "${HOME}/.config/zsh/.zsh_history"
fi

# .binディレクトリからシェルスクリプトのシンボリックリンクを作成
bin_src_dir="${DOTFILES_DIR}/.bin"
bin_dst_dir="${HOME}/.config/.bin"

if [ -d "$bin_src_dir" ]; then
  echo "=== .binディレクトリのスクリプトをリンクします ==="
  
  # .zshと.shファイルを検索
  find "$bin_src_dir" -type f \( -name "*.zsh" -o -name "*.sh" \) | while read -r script_file; do
    script_name=$(basename "$script_file")
    dst_script="${bin_dst_dir}/${script_name}"
    create_symlink "$script_file" "$dst_script"
  done
else
  echo "警告: .binディレクトリが存在しません。スクリプトのリンクはスキップします。"
fi

echo "インストールが完了しました！"