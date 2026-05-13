#!/usr/bin/env bash
# Claude Code は native installer 配下 (~/.local/share/claude/) で auto-update
# する。chezmoi では「未インストール時の初回投入」だけ面倒を見る。
# 既に入っていれば何もしない (auto-update 任せ)。

set -euo pipefail

if command -v claude >/dev/null 2>&1; then
  echo "claude already installed: $(command -v claude) ($(claude --version 2>/dev/null || echo unknown))"
  exit 0
fi

echo "==> Installing Claude Code via native installer"
curl -fsSL https://claude.ai/install.sh | bash
