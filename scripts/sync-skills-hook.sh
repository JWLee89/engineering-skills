#!/usr/bin/env bash
# Git post-commit hook: refresh global Cursor skill symlinks when skill files change.
# Installed via: ./scripts/install-skills.sh --install-hook

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
INSTALL="${ROOT}/scripts/install-skills.sh"

[[ -x "${INSTALL}" ]] || exit 0

if git diff-tree --no-commit-id --name-only -r HEAD | grep -Eq '^(skills/|handle-task-skill/|scripts/install-skills\.sh)'; then
  "${INSTALL}" --update --quiet
fi
