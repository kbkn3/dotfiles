# AWS SSO Profile Switch Tool

## 概要

このスクリプトは、AWS SSOプロファイルの切り替えを簡単に行うためのZshツールです。認証情報の自動チェックや更新、インタラクティブな選択機能を提供します。

## 主な機能

- AWS SSOプロファイルの切り替え
- 認証情報の自動チェックと更新
- pecoを使用したインタラクティブなプロファイル選択
- 多言語サポート（英語、日本語、ベトナム語）
- Zsh補完機能

## インストール要件

- AWS CLI v2
- Zsh
- peco（推奨、インタラクティブ選択に使用）

## 使用方法

### 基本的なコマンド

```bash
# 基本的な使用方法
aws-sso-switch [オプション] [プロファイル名]

# エイリアスを使用
ass [オプション] [プロファイル名]
```

### オプション

- -h, --help: ヘルプメッセージを表示
- --debug: デバッグモードを有効化
- --no-debug: デバッグモードを無効化

### キーバインド

- Ctrl + P: インタラクティブなプロファイル選択モードを起動

## 設定

### インライン設定

```bash
DEBUG_MODE=false
```

デバッグモードはデフォルトで無効になっています。有効にすると、log_debug()関数を通じて詳細なデバッグ情報が出力されます。

```bash
CURRENT_LANG=""
```

初期値は空になっており、

1. `CURRENT_LANG`
2. 端末のlocale
3. `DEFAULT_LANG`

の順に優先される。

### AWS設定ファイル

スクリプトは以下の設定ファイルを使用します：

- AWS設定ファイル: ~/.aws/config
- AWS認証情報ファイル: ~/.aws/credentials

## 機能詳細

### 自動認証チェック

- 起動時に現在のプロファイルの認証状態を自動チェック
- 認証情報の有効期限切れを検知して自動更新

### 多言語サポート

- システムのロケール設定に基づいて自動的に言語を選択
- サポート言語：
  - 英語（デフォルト）
  - 日本語
  - ベトナム語

### インタラクティブ選択

- pecoがインストールされている場合、インタラクティブなプロファイル選択が可能
- プロファイル一覧から簡単に選択可能

## 使用例

```bash
# インタラクティブ選択モードで起動
$ aws-sso-switch

# 特定のプロファイルに直接切り替え
$ aws-sso-switch dev-account

# デバッグモードで実行
$ aws-sso-switch --debug prod-account
```

## エラーハンドリング

- 必要なコマンドが見つからない場合のエラー表示
- プロファイルが存在しない場合のエラー処理
- 認証失敗時の適切なエラーメッセージ表示

## 自動補完

Zshの補完機能をサポートしており、プロファイル名の入力を補助します。
