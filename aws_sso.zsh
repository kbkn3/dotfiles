# 定数定義
readonly SUCCESS=0
readonly ERROR=1
readonly AWS_CONFIG_FILE="${HOME}/.aws/config"
readonly AWS_CREDENTIALS_FILE="${HOME}/.aws/credentials"

# デバッグモード設定
DEBUG_MODE=false

# ヘルプメッセージ
show_help() {
    cat << EOF
aws-sso-switch - AWS SSO プロファイル切り替えツール

使用方法:
    aws-sso-switch [options] [profile-name]
    ass [options] [profile-name]  # エイリアス

オプション:
    -h, --help     このヘルプメッセージを表示
    --debug        デバッグモードを有効化
    --no-debug     デバッグモードを無効化

引数:
    profile-name   切り替えたいAWSプロファイル名（省略可）
                  省略時はpecoによるインタラクティブ選択が起動

機能:
    - プロファイルの切り替え
    - 認証情報の自動チェックと更新
    - pecoによるインタラクティブな選択
    - Zsh補完のサポート

キーバインド:
    Ctrl + P       プロファイル選択を起動（pecoが必要）

環境変数:
    AWS_PROFILE    現在選択中のプロファイル名

設定ファイル:
    ${AWS_CONFIG_FILE}
    ${AWS_CREDENTIALS_FILE}

例:
    # インタラクティブ選択（pecoが必要）
    $ aws-sso-switch

    # プロファイルを直接指定
    $ aws-sso-switch dev-account
    $ awsp prod-account

    # デバッグモードを有効化
    $ aws-sso-switch --debug dev-account
EOF
}

# ログ出力関数
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

log_debug() {
    if [[ "$DEBUG_MODE" = true ]]; then
        echo "[DEBUG] $1"
    fi
}

# 依存コマンドの確認
check_dependencies() {
    local missing_deps=()
    
    # aws コマンドは必須
    if ! command -v "aws" >/dev/null 2>&1; then
        missing_deps+=("aws")
    fi
    
    if [[ ${#missing_deps[@]} -ne 0 ]]; then
        log_error "必要なコマンドがインストールされていません: ${missing_deps[*]}"
        return $ERROR
    fi
    
    return $SUCCESS
}

# pecoが利用可能か確認
has_peco() {
    command -v peco >/dev/null 2>&1
    return $?
}

# pecoのインストール推奨メッセージを表示
show_peco_recommendation() {
    cat << EOF

[TIP] pecoをインストールすると、インタラクティブにプロファイルを選択できるようになります！

インストール方法:
  - macOS (Homebrew):   brew install peco
  - Ubuntu/Debian:      sudo apt-get install peco
  - Amazon Linux/RHEL:  sudo yum install peco
  - その他:             https://github.com/peco/peco
EOF
}

# プロファイル一覧を表示する関数
list_profiles() {
    log_info "利用可能なプロファイル:"
    aws configure list-profiles
}

# 認証情報の更新が必要か確認する関数
check_credentials() {
    if [[ $# -ne 1 ]]; then
        log_error "プロファイル名が指定されていません"
        return $ERROR
    fi
    
    local profile="$1"
    
    # 認証情報の有効性を確認（結果を変数に保存）
    if aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        log_info "認証情報は有効です"
        return $SUCCESS
    else
        log_info "認証情報の期限切れを検知しました。更新を試みます..."
        aws sso login --profile "$profile"
        return $?
    fi
}

# pecoでプロファイルを選択する関数
select_profile_with_peco() {
    local selected_profile
    selected_profile=$(aws configure list-profiles | peco --prompt="Select AWS Profile>" --initial-index=0)
    echo "$selected_profile"
}

# AWS プロファイル切り替え関数
aws-sso-switch() {
    # オプション解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                return $SUCCESS
                ;;
            --debug)
                enable_debug
                shift
                ;;
            --no-debug)
                disable_debug
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # 依存関係チェック
    if ! check_dependencies; then
        return $ERROR
    fi

    local profile_name

    if [[ $# -eq 0 ]]; then
        # 引数がない場合
        if has_peco; then
            # pecoがある場合はインタラクティブ選択
            profile_name=$(select_profile_with_peco)
            if [[ -z "$profile_name" ]]; then
                log_error "プロファイルが選択されませんでした"
                return $ERROR
            fi
        else
            # pecoがない場合はプロファイル一覧を表示してpecoのインストールを推奨
            list_profiles
            show_peco_recommendation
            return $ERROR
        fi
    else
        profile_name="$1"
    fi
    
    # プロファイルが存在するか確認
    if aws configure list-profiles | grep -q "^${profile_name}$"; then
        export AWS_PROFILE="$profile_name"
        
        # 認証情報をチェックして必要な場合は更新
        if check_credentials "$profile_name"; then
            log_info "AWS プロファイルを切り替えました: $profile_name"
            aws sts get-caller-identity
        fi
    else
        log_error "プロファイル '$profile_name' が見つかりません"
        list_profiles
        return $ERROR
    fi
}

# プロファイル補完機能
_aws_sso_switch_completion() {
    local curr_word=$words[CURRENT]
    local profiles
    profiles=( $(aws configure list-profiles 2>/dev/null) )
    compadd -a profiles
}

# 補完を有効化
compdef _aws_sso_switch_completion aws-sso-switch

# エイリアスの設定
alias ass='aws-sso-switch'

# AWS認証の自動チェック関数
auto_check_aws_login() {
    # AWS_PROFILEが設定されているか確認
    if [[ -n "$AWS_PROFILE" ]]; then
        log_info "AWS Profile: $AWS_PROFILE の認証状態を確認中..."
        check_credentials "$AWS_PROFILE"
    # デフォルトプロファイルのチェック
    elif [[ -f "$AWS_CONFIG_FILE" ]] || [[ -f "$AWS_CREDENTIALS_FILE" ]]; then
        local default_profile="default"
        if aws configure list-profiles | grep -q "^${default_profile}$"; then
            log_info "デフォルトプロファイルの認証状態を確認中..."
            export AWS_PROFILE="$default_profile"
            check_credentials "$default_profile"
        fi
    fi
}

# デバッグモードを有効にする関数
enable_debug() {
    DEBUG_MODE=true
    log_debug "デバッグモードが有効になりました"
}

# デバッグモードを無効にする関数
disable_debug() {
    DEBUG_MODE=false
}

# .zshrc起動時に自動実行
auto_check_aws_login

# Ctrl+PでAWSプロファイル選択を行う関数
aws-sso-switch-widget() {
    # 現在のバッファを保存
    local BUFFER_BACKUP=$BUFFER
    local CURSOR_BACKUP=$CURSOR
    
    # プロファイル選択を実行
    if command -v peco >/dev/null 2>&1; then
        # pecoがある場合は選択実行
        local selected_profile=$(aws configure list-profiles | peco --prompt="Select AWS Profile>" --initial-index=0)
        if [[ -n "$selected_profile" ]]; then
            BUFFER="aws-sso-switch $selected_profile"
            zle accept-line
        else
            # 選択がキャンセルされた場合は元のバッファを復元
            BUFFER=$BUFFER_BACKUP
            CURSOR=$CURSOR_BACKUP
        fi
    else
        # pecoがない場合はメッセージを表示
        BUFFER="echo 'pecoが必要です。インストールしてください。'"
        zle accept-line
    fi
}

# ウィジェットを作成
zle -N aws-sso-switch-widget

# Ctrl+Pにバインド
bindkey '^P' aws-sso-switch-widget