#!/bin/bash

# 必要なディレクトリを作成
mkdir -p "${HOME}/.config/zsh"
mkdir -p "${HOME}/.config/.bin"
mkdir -p "${HOME}/.config/wezterm"
mkdir -p "${HOME}/.config/zsh/conf.d/hosts"

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

# 5. ホスト固有設定ファイルのシンボリックリンクを作成
create_symlink "${DOTFILES_DIR}/zsh/conf.d/hosts/local.zsh" "${HOME}/.config/zsh/conf.d/hosts/local.zsh"
create_symlink "${DOTFILES_DIR}/zsh/conf.d/hosts/local.zshenv" "${HOME}/.config/zsh/conf.d/hosts/local.zshenv"

# ローカル設定ファイルの作成
# local.zsh (すべてのシェル起動時に読み込まれる設定)
LOCAL_CONF_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/conf.d/hosts/local.zsh"
if [ ! -e "$LOCAL_CONF_PATH" ]; then
  echo "ローカル設定ファイルを作成します: $LOCAL_CONF_PATH"
  touch "$LOCAL_CONF_PATH"
  echo "# ローカル固有の設定をここに記述してください" > "$LOCAL_CONF_PATH"
  echo "# このファイルはgitで管理されません" >> "$LOCAL_CONF_PATH"
  chmod +x "$LOCAL_CONF_PATH"
fi

# local.zshenv (環境変数とログインシェル設定)
LOCAL_ENV_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/conf.d/hosts/local.zshenv"
if [ ! -e "$LOCAL_ENV_PATH" ]; then
  echo "ローカル環境変数ファイルを作成します: $LOCAL_ENV_PATH"
  touch "$LOCAL_ENV_PATH"
  echo "# ローカル固有の環境変数をここに記述してください" > "$LOCAL_ENV_PATH"
  echo "# このファイルはgitで管理されません" >> "$LOCAL_ENV_PATH"
  chmod +x "$LOCAL_ENV_PATH"
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
    create_symlink "$script_file" "$dst_script"
  done
else
  echo "警告: .binディレクトリが存在しません。スクリプトのリンクはスキップします。"
fi

# Weztermの設定ファイルの対応
if [ -d "${DOTFILES_DIR}/wezterm" ]; then
  echo "=== Weztermの設定ファイルを配置します ==="
  
  # 方法1: ディレクトリ全体をシンボリックリンクする場合
  if [ -e "${HOME}/.config/wezterm" ]; then
    echo "既に存在します: ${HOME}/.config/wezterm"
    read -p "バックアップを作成して上書きしますか? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "バックアップを作成: ${HOME}/.config/wezterm.backup"
      mv "${HOME}/.config/wezterm" "${HOME}/.config/wezterm.backup"
      ln -sf "${DOTFILES_DIR}/wezterm" "${HOME}/.config/wezterm"
      echo "ディレクトリをリンク: ${DOTFILES_DIR}/wezterm -> ${HOME}/.config/wezterm"
    fi
  else
    ln -sf "${DOTFILES_DIR}/wezterm" "${HOME}/.config/wezterm"
    echo "ディレクトリをリンク: ${DOTFILES_DIR}/wezterm -> ${HOME}/.config/wezterm"
  fi
  
  # 方法2: ファイルをコピーする場合（上記の方法1を使用する場合はコメントアウト）
  # echo "Weztermの設定ファイルをコピーします"
  # cp -r "${DOTFILES_DIR}/wezterm/"* "${HOME}/.config/wezterm/"
else
  echo "警告: weztermディレクトリが存在しません。設定ファイルの設定はスキップします。"
fi

# Starshipの設定ファイルのシンボリックリンクを作成
create_symlink "${DOTFILES_DIR}/starship.toml" "${HOME}/.config/starship.toml"

echo "インストールが完了しました！"