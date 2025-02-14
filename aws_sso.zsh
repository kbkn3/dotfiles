#!/bin/zsh

# 定数定義
readonly SUCCESS=0
readonly ERROR=1
readonly AWS_CONFIG_FILE="${HOME}/.aws/config"
readonly AWS_CREDENTIALS_FILE="${HOME}/.aws/credentials"

# デバッグモード設定
DEBUG_MODE=false

# 言語設定
DEFAULT_LANG="en"
SUPPORTED_LANGS=("en" "ja" "vi")
CURRENT_LANG=""

# ログ出力関数
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

log_debug() {
    if [[ "$DEBUG_MODE" = true ]]; then
        echo "[DEBUG] $1" >&2
    fi
}

# 言語設定を初期化する関数
init_language() {
    # 1. CURRENT_LANGが既に設定されていて、サポートされている言語の場合はそれを使用
    if [[ -n "$CURRENT_LANG" ]] && [[ " ${SUPPORTED_LANGS[@]} " =~ " ${CURRENT_LANG} " ]]; then
        log_debug "Using explicitly set CURRENT_LANG: $CURRENT_LANG"
        return $SUCCESS
    fi
    
    # 2. システムのロケールから言語を取得して使用
    local system_lang=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1 | tr -d '"')
    if [[ -n "$system_lang" ]] && [[ " ${SUPPORTED_LANGS[@]} " =~ " ${system_lang} " ]]; then
        CURRENT_LANG=$system_lang
        log_debug "Using system language: $CURRENT_LANG"
        return $SUCCESS
    fi
    
    # 3. 上記どちらも該当しない場合はデフォルト言語を使用
    CURRENT_LANG=$DEFAULT_LANG
    log_debug "Using default language: $CURRENT_LANG"
    return $SUCCESS
}

# 依存コマンドの確認
check_dependencies() {
    local missing_deps=()
    
    if ! command -v "aws" >/dev/null 2>&1; then
        missing_deps+=("aws")
    fi
    
    if [[ ${#missing_deps[@]} -ne 0 ]]; then
        case "$CURRENT_LANG" in
            "ja")
                log_error "必要なコマンドがインストールされていません: ${missing_deps[*]}"
                ;;
            "vi")
                log_error "Các lệnh cần thiết chưa được cài đặt: ${missing_deps[*]}"
                ;;
            *)
                log_error "Required commands are not installed: ${missing_deps[*]}"
                ;;
        esac
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
    case "$CURRENT_LANG" in
        "ja")
            log_info "pecoをインストールすると、インタラクティブにプロファイルを選択できます！"
            ;;
        "vi")
            log_info "Cài đặt peco để chọn profile tương tác!"
            ;;
        *)
            log_info "Install peco for interactive profile selection!"
            ;;
    esac
}

# プロファイル一覧を表示する関数
list_profiles() {
    case "$CURRENT_LANG" in
        "ja")
            log_info "利用可能なプロファイル:"
            ;;
        "vi")
            log_info "Các profile có sẵn:"
            ;;
        *)
            log_info "Available profiles:"
            ;;
    esac
    aws configure list-profiles
}

# 認証情報の更新が必要か確認する関数
check_credentials() {
    if [[ $# -ne 1 ]]; then
        case "$CURRENT_LANG" in
            "ja")
                log_error "プロファイル名が指定されていません"
                ;;
            "vi")
                log_error "Chưa chỉ định tên profile"
                ;;
            *)
                log_error "Profile name is not specified"
                ;;
        esac
        return $ERROR
    fi
    
    local profile="$1"
    
    # 認証情報の有効性を確認
    if aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        case "$CURRENT_LANG" in
            "ja")
                log_info "認証情報は有効です"
                ;;
            "vi")
                log_info "Thông tin xác thực hợp lệ"
                ;;
            *)
                log_info "Credentials are valid"
                ;;
        esac
        return $SUCCESS
    else
        case "$CURRENT_LANG" in
            "ja")
                log_info "認証情報の期限切れを検知しました。更新を試みます..."
                ;;
            "vi")
                log_info "Phát hiện thông tin xác thực hết hạn. Đang thử làm mới..."
                ;;
            *)
                log_info "Detected expired credentials. Attempting to refresh..."
                ;;
        esac
        aws sso login --profile "$profile"
        return $?
    fi
}

# プロファイルを選択する関数
select_profile_with_peco() {
    local prompt
    case "$CURRENT_LANG" in
        "ja")
            prompt="AWSプロファイルを選択>"
            ;;
        "vi")
            prompt="Chọn AWS Profile>"
            ;;
        *)
            prompt="Select AWS Profile>"
            ;;
    esac
    local selected_profile
    selected_profile=$(aws configure list-profiles | peco --prompt="$prompt" --initial-index=0)
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

    if ! check_dependencies; then
        return $ERROR
    fi

    local profile_name

    if [[ $# -eq 0 ]]; then
        if has_peco; then
            profile_name=$(select_profile_with_peco)
            if [[ -z "$profile_name" ]]; then
                case "$CURRENT_LANG" in
                    "ja")
                        log_error "プロファイルが選択されませんでした"
                        ;;
                    "vi")
                        log_error "Không có profile nào được chọn"
                        ;;
                    *)
                        log_error "No profile was selected"
                        ;;
                esac
                return $ERROR
            fi
        else
            list_profiles
            show_peco_recommendation
            return $ERROR
        fi
    else
        profile_name="$1"
    fi
    
    if aws configure list-profiles | grep -q "^${profile_name}$"; then
        export AWS_PROFILE="$profile_name"
        
        if check_credentials "$profile_name"; then
            case "$CURRENT_LANG" in
                "ja")
                    log_info "AWS プロファイルを切り替えました: $profile_name"
                    ;;
                "vi")
                    log_info "Đã chuyển AWS Profile sang: $profile_name"
                    ;;
                *)
                    log_info "AWS Profile switched to: $profile_name"
                    ;;
            esac
            aws sts get-caller-identity
        fi
    else
        case "$CURRENT_LANG" in
            "ja")
                log_error "プロファイル '$profile_name' が見つかりません"
                ;;
            "vi")
                log_error "Không tìm thấy profile '$profile_name'"
                ;;
            *)
                log_error "Profile '$profile_name' not found"
                ;;
        esac
        list_profiles
        return $ERROR
    fi
}

# AWS認証の自動チェック関数
auto_check_aws_login() {
    if [[ -n "$AWS_PROFILE" ]]; then
        case "$CURRENT_LANG" in
            "ja")
                log_info "AWS Profile: $AWS_PROFILE の認証状態を確認中..."
                ;;
            "vi")
                log_info "Đang kiểm tra trạng thái xác thực cho AWS Profile: $AWS_PROFILE..."
                ;;
            *)
                log_info "Checking authentication status for AWS Profile: $AWS_PROFILE..."
                ;;
        esac
        check_credentials "$AWS_PROFILE"
    elif [[ -f "$AWS_CONFIG_FILE" ]] || [[ -f "$AWS_CREDENTIALS_FILE" ]]; then
        local default_profile="default"
        if aws configure list-profiles | grep -q "^${default_profile}$"; then
            case "$CURRENT_LANG" in
                "ja")
                    log_info "デフォルトプロファイルの認証状態を確認中..."
                    ;;
                "vi")
                    log_info "Đang kiểm tra xác thực profile mặc định..."
                    ;;
                *)
                    log_info "Checking default profile authentication..."
                    ;;
            esac
            export AWS_PROFILE="$default_profile"
            check_credentials "$default_profile"
        fi
    fi
}

# Ctrl+PでAWSプロファイル選択を行うウィジェット関数
aws-sso-switch-widget() {
    # 現在のバッファを保存
    local BUFFER_BACKUP=$BUFFER
    local CURSOR_BACKUP=$CURSOR
    
    if command -v peco >/dev/null 2>&1; then
        # pecoのプロンプトメッセージを言語に応じて設定
        local prompt
        case "$CURRENT_LANG" in
            "ja")
                prompt="AWSプロファイルを選択>"
                ;;
            "vi")
                prompt="Chọn AWS Profile>"
                ;;
            *)
                prompt="Select AWS Profile>"
                ;;
        esac

        # pecoでプロファイル選択を実行
        local selected_profile=$(aws configure list-profiles | peco --prompt="$prompt" --initial-index=0)
        
        if [[ -n "$selected_profile" ]]; then
            BUFFER="aws-sso-switch $selected_profile"
            zle accept-line
        else
            # 選択がキャンセルされた場合は元のバッファを復元
            BUFFER=$BUFFER_BACKUP
            CURSOR=$CURSOR_BACKUP
        fi
    else
        # pecoがない場合は言語に応じたメッセージを表示
        case "$CURRENT_LANG" in
            "ja")
                BUFFER="echo '[INFO] pecoをインストールすると、インタラクティブにプロファイルを選択できます！'"
                ;;
            "vi")
                BUFFER="echo '[INFO] Cài đặt peco để chọn profile tương tác!'"
                ;;
            *)
                BUFFER="echo '[INFO] Install peco for interactive profile selection!'"
                ;;
        esac
        zle accept-line
    fi
}

# デバッグモードを有効にする関数
enable_debug() {
    DEBUG_MODE=true
    case "$CURRENT_LANG" in
        "ja")
            log_info "デバッグモードが有効になりました"
            ;;
        "vi")
            log_info "Đã bật chế độ gỡ lỗi"
            ;;
        *)
            log_info "Debug mode enabled"
            ;;
    esac
}

# デバッグモードを無効にする関数
disable_debug() {
    DEBUG_MODE=false
}

# ヘルプメッセージを表示する関数
show_help() {
    local usage_msg features_msg options_msg arguments_msg examples_msg
    local enable_debug_msg disable_debug_msg profile_name_msg
    local switch_msg auth_msg peco_msg completion_msg
    
    case "$CURRENT_LANG" in
        "ja")
            usage_msg="使用方法:"
            options_msg="オプション:"
            arguments_msg="引数:"
            features_msg="機能:"
            enable_debug_msg="デバッグモードを有効化"
            disable_debug_msg="デバッグモードを無効化"
            profile_name_msg="切り替えたいAWSプロファイル名（省略可）
                         省略時はpecoによるインタラクティブ選択が起動"
            switch_msg="プロファイルの切り替え"
            auth_msg="認証情報の自動チェックと更新"
            peco_msg="pecoによるインタラクティブな選択"
            completion_msg="Zsh補完のサポート"
            examples_msg="例:"
            keybindings_msg="キーバインド:"
            ;;
        "vi")
            usage_msg="Cách sử dụng:"
            options_msg="Tùy chọn:"
            arguments_msg="Đối số:"
            features_msg="Tính năng:"
            enable_debug_msg="Bật chế độ gỡ lỗi"
            disable_debug_msg="Tắt chế độ gỡ lỗi"
            profile_name_msg="Tên profile AWS để chuyển đổi (tùy chọn)
                         Nếu bỏ qua, sẽ khởi động lựa chọn tương tác bằng peco"
            switch_msg="Chuyển đổi giữa các profile AWS"
            auth_msg="Tự động kiểm tra và làm mới thông tin xác thực"
            peco_msg="Lựa chọn tương tác với peco"
            completion_msg="Hỗ trợ completion Zsh"
            examples_msg="Ví dụ:"
            keybindings_msg="Phím tắt:"
            ;;
        *)  # デフォルトは英語
            usage_msg="Usage:"
            options_msg="Options:"
            arguments_msg="Arguments:"
            features_msg="Features:"
            enable_debug_msg="Enable debug mode"
            disable_debug_msg="Disable debug mode"
            profile_name_msg="AWS profile name to switch to (optional)
                         If omitted, interactive selection with peco will launch"
            switch_msg="Switch between AWS profiles"
            auth_msg="Automatic credential check and renewal"
            peco_msg="Interactive selection with peco"
            completion_msg="Zsh completion support"
            examples_msg="Examples:"
            keybindings_msg="Key Bindings:"
            ;;
    esac

    cat << EOF
aws-sso-switch - AWS SSO Profile Switch Tool

${usage_msg}
    aws-sso-switch [options] [profile-name]
    ass [options] [profile-name]  # alias

${options_msg}
    -h, --help     $(printf "%-50s" "Show this help message")
    --debug        $(printf "%-50s" "${enable_debug_msg}")
    --no-debug     $(printf "%-50s" "${disable_debug_msg}")

${arguments_msg}
    profile-name   ${profile_name_msg}

${features_msg}
    - ${switch_msg}
    - ${auth_msg}
    - ${peco_msg}
    - ${completion_msg}

${keybindings_msg}
    Ctrl + P       ${peco_msg}

${examples_msg}
    # ${peco_msg}
    $ aws-sso-switch

    # ${switch_msg}
    $ aws-sso-switch dev-account
    $ ass prod-account

    # ${enable_debug_msg}
    $ aws-sso-switch --debug dev-account
EOF
}

# 初期化処理
init_language

# 補完を有効化
compdef _aws_sso_switch_completion aws-sso-switch

# エイリアスの設定
alias ass='aws-sso-switch'

# ウィジェットを作成
zle -N aws-sso-switch-widget

# Ctrl+Pにバインド
bindkey '^P' aws-sso-switch-widget

# 起動時の自動チェック
auto_check_aws_login