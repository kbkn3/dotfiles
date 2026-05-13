#!/usr/bin/env bash
# cmux は DMG 配布版で Sparkle 経由の auto-update が効く。
# chezmoi では「未インストール時の初回投入」だけ面倒を見る。
# 既に /Applications/cmux.app があれば skip (アプリの自動更新任せ)。

set -euo pipefail

if [ -d /Applications/cmux.app ]; then
  echo "cmux already installed at /Applications/cmux.app (auto-updates via Sparkle)"
  exit 0
fi

dmg=$(mktemp -t cmux.XXXXXX.dmg)
mountpoint=""
cleanup() {
  if [ -n "$mountpoint" ]; then
    hdiutil detach "$mountpoint" -quiet >/dev/null 2>&1 || true
  fi
  rm -f "$dmg"
}
trap cleanup EXIT

echo "==> Downloading cmux DMG"
curl -fsSL -o "$dmg" \
  https://github.com/manaflow-ai/cmux/releases/latest/download/cmux-macos.dmg

echo "==> Mounting DMG"
mountpoint=$(hdiutil attach "$dmg" -nobrowse -quiet \
  | awk -F'\t' '/\/Volumes\// {print $NF; exit}')

if [ -z "$mountpoint" ] || [ ! -d "$mountpoint/cmux.app" ]; then
  echo "Failed to locate cmux.app inside the mounted DMG" >&2
  exit 1
fi

echo "==> Copying cmux.app to /Applications"
cp -R "$mountpoint/cmux.app" /Applications/
# Gatekeeper の隔離属性を外す (初回起動時の「開発元未確認」ダイアログ抑制)
xattr -dr com.apple.quarantine /Applications/cmux.app 2>/dev/null || true
