#!/usr/bin/env bash
# Git post-commit hook: refresh global Cursor skill symlinks when skill files change.
# Installed via: ./handle-task-skill/scripts/install-skills.sh --install-hook

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
INSTALL="${ROOT}/handle-task-skill/scripts/install-skills.sh"

[[ -x "${INSTALL}" ]] || exit 0

if git diff-tree --no-commit-id --name-only -r HEAD | grep -Eq '^handle-task-skill/'; then
  "${INSTALL}" --update --quiet
fi
