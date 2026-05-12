# ワークフロー関数群。
# zsh の起動時に ~/.config/zsh/.zshrc から source される（chezmoi 管理）。
# 依存: fzf, git, lsof, ghq

# === git: ブランチを fuzzy 検索して checkout ===
fgc() {
  local branches branch
  branches=$(git --no-pager branch --all --format='%(refname:short)' 2>/dev/null \
    | sed 's#^origin/##' \
    | sort -u)
  [ -z "$branches" ] && { echo "Not a git repo or no branches"; return 1; }
  branch=$(echo "$branches" | fzf --preview 'git log --oneline --graph --color=always -20 {} 2>/dev/null') \
    || return
  git checkout "$branch"
}

# === git: ログを fuzzy 検索して内容表示 ===
fgl() {
  git log --color=always \
    --pretty=format:'%C(yellow)%h%Creset %s %C(blue)<%an>%Creset %C(green)(%cr)%Creset%C(red)%d%Creset' \
    --all \
    | fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'echo {} | awk "{print \$1}" | xargs -I _ git show --color=always _' \
        --bind 'enter:execute:echo {} | awk "{print \$1}" | xargs -I _ git show --color=always _ | less -R'
}

# === git: 変更ファイルを fuzzy 選んで add（multi 選択可） ===
fga() {
  local files selected
  files=$(git status --porcelain 2>/dev/null | awk '{print $2}')
  [ -z "$files" ] && { echo "No changes to add"; return; }
  selected=$(echo "$files" | fzf --multi \
    --preview 'git diff --color=always -- {} 2>/dev/null || bat --color=always {} 2>/dev/null || cat {}')
  [ -z "$selected" ] && return
  echo "$selected" | xargs git add
  git status --short
}

# === fzf でプロセスを選んで kill（multi 選択可、signal 引数は省略時 9） ===
fkill() {
  local pid signal
  signal="${1:-9}"
  pid=$(ps -ef | sed 1d | fzf --multi --header="Select process(es) to kill -$signal" \
    | awk '{print $2}')
  [ -z "$pid" ] && return
  echo "$pid" | xargs kill -"$signal"
}

# === ポートを listen しているプロセスを表示 ===
port() {
  if [ -z "$1" ]; then
    echo "usage: port <port_number>"
    return 1
  fi
  lsof -nP -iTCP:"$1" -sTCP:LISTEN 2>/dev/null
}

# === ghq + fzf でローカルリポジトリへ高速ジャンプ ===
pro() {
  local dir
  dir=$(ghq list --full-path 2>/dev/null \
    | fzf --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls -la {}') \
    || return
  cd "$dir"
}
