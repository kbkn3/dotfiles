#!/bin/bash
# filepath: /Users/{user}/dotfiles/install.sh

# 必要なディレクトリを作成
mkdir -p "${HOME}/.config/zsh"
mkdir -p "${HOME}/.config/.bin"

# dotfilesのディレクトリ
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

# 1. home.zshenvを$HOME/.zshenvにシンボリックリンク
src_zshenv="${DOTFILES_DIR}/zsh/home.zshenv"
dst_zshenv="${HOME}/.zshenv"

if [ -e "$dst_zshenv" ]; then
  echo "既に存在します: $dst_zshenv"
  read -p "バックアップを作成して上書きしますか? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "バックアップを作成: ${dst_zshenv}.backup"
    mv "$dst_zshenv" "${dst_zshenv}.backup"
    ln -sf "$src_zshenv" "$dst_zshenv"
    echo "リンクを作成: $src_zshenv -> $dst_zshenv"
  fi
else
  ln -sf "$src_zshenv" "$dst_zshenv"
  echo "リンクを作成: $src_zshenv -> $dst_zshenv"
fi

# 2. 元の.zshenvを.config/zsh/.zshenvにリンク
src_config_zshenv="${DOTFILES_DIR}/zsh/.zshenv"
dst_config_zshenv="${HOME}/.config/zsh/.zshenv"

if [ -e "$dst_config_zshenv" ]; then
  echo "既に存在します: $dst_config_zshenv"
  read -p "バックアップを作成して上書きしますか? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "バックアップを作成: ${dst_config_zshenv}.backup"
    mv "$dst_config_zshenv" "${dst_config_zshenv}.backup"
    ln -sf "$src_config_zshenv" "$dst_config_zshenv"
    echo "リンクを作成: $src_config_zshenv -> $dst_config_zshenv"
  fi
else
  ln -sf "$src_config_zshenv" "$dst_config_zshenv"
  echo "リンクを作成: $src_config_zshenv -> $dst_config_zshenv"
fi

# 3. .zshrcを.config/zsh/.zshrcにリンク (存在する場合)
src_zshrc="${DOTFILES_DIR}/zsh/.zshrc"
dst_zshrc="${HOME}/.config/zsh/.zshrc"

if [ -e "$src_zshrc" ]; then
  if [ -e "$dst_zshrc" ]; then
    echo "既に存在します: $dst_zshrc"
    read -p "バックアップを作成して上書きしますか? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "バックアップを作成: ${dst_zshrc}.backup"
      mv "$dst_zshrc" "${dst_zshrc}.backup"
      ln -sf "$src_zshrc" "$dst_zshrc"
      echo "リンクを作成: $src_zshrc -> $dst_zshrc"
    fi
  else
    ln -sf "$src_zshrc" "$dst_zshrc"
    echo "リンクを作成: $src_zshrc -> $dst_zshrc"
  fi
else
  echo "警告: ソースファイル $src_zshrc が存在しません。.zshrcのリンクはスキップします。"
fi

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
    
    if [ -e "$dst_script" ]; then
      echo "既に存在します: $dst_script"
      read -p "バックアップを作成して上書きしますか? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "バックアップを作成: ${dst_script}.backup"
        mv "$dst_script" "${dst_script}.backup"
        ln -sf "$script_file" "$dst_script"
        echo "リンクを作成: $script_file -> $dst_script"
      fi
    else
      ln -sf "$script_file" "$dst_script"
      echo "リンクを作成: $script_file -> $dst_script"
    fi
  done
else
  echo "警告: .binディレクトリが存在しません。スクリプトのリンクはスキップします。"
fi

echo "インストールが完了しました！"