#!/bin/bash

toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
changed=$(git diff --name-only HEAD 2>/dev/null | head -10)

if [ -z "$changed" ]; then
  exit 0
fi

files=$(echo "$changed" | tr '\n' ', ' | sed 's/,$//')

codex exec --full-auto --sandbox read-only --cd "$toplevel" \
  "Review the following changed files: ${files}. Report only bugs, security risks, and performance issues. Skip minor style issues. No questions needed, output only concrete findings with file path, line number, and fix suggestion."
