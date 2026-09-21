#!/usr/bin/env bash
# Install handle-task skills for Cursor and Claude Code — from any clone of this bundle.
#
# Global install uses symlinks into ~/.cursor/skills/ and ~/.claude/skills/, so edits
# in this repo are visible in every project without copying files. Re-run --update
# after moving the repo or if symlinks break.
#
# Usage:
#   ./handle-task-skill/scripts/install-skills.sh              # global: Cursor + Claude
#   ./handle-task-skill/scripts/install-skills.sh --project    # ./.cursor/skills + ./.claude/skills
#   ./handle-task-skill/scripts/install-skills.sh --cursor-only
#   ./handle-task-skill/scripts/install-skills.sh --claude-only
#   ./handle-task-skill/scripts/install-skills.sh --update     # refresh symlinks
#   ./handle-task-skill/scripts/install-skills.sh --list       # show install plan
#   ./handle-task-skill/scripts/install-skills.sh --install-hook   # post-commit sync
#   ./handle-task-skill/scripts/install-skills.sh --remove
#   ./handle-task-skill/scripts/install-skills.sh --remove-hook
#
# Installs:
#   /handle-task        → handle-task-skill/
#   /make-pull-request  → handle-task-skill/make-pull-request/
#   /create-ticket      → handle-task-skill/create-ticket/
#   /review-ticket      → handle-task-skill/review-ticket/
#
# Environment:
#   SKILLS_ROOT  Override repo root (default: parent of handle-task-skill/)

set -euo pipefail

SCOPE="global"
INSTALL_CURSOR=true
INSTALL_CLAUDE=true
DO_REMOVE=false
DO_UPDATE=false
DO_LIST=false
DO_INSTALL_HOOK=false
DO_REMOVE_HOOK=false
QUIET=false

SKILL_NAMES=(handle-task make-pull-request create-ticket review-ticket)
LEGACY_SKILLS=(modelops modelops-workflow modelops-skill handle-task-workflow create-jira-ticket)

usage() {
  sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
  echo
  echo "Options:"
  echo "  --global         Install to ~/.cursor/skills/ and ~/.claude/skills/ (default)"
  echo "  --project        Install to ./.cursor/skills/ and ./.claude/skills/"
  echo "  --cursor-only    Install only under .cursor/skills/"
  echo "  --claude-only    Install only under .claude/skills/"
  echo "  --update         Refresh symlinks and manifest (same as default install)"
  echo "  --list           Print source paths, targets, and current symlinks"
  echo "  --install-hook   Install git post-commit hook to run --update on skill edits"
  echo "  --remove-hook    Remove the git post-commit hook fragment"
  echo "  --quiet          Suppress success messages (for hooks)"
  echo "  --remove         Remove symlinks for handle-task skills"
  echo "  -h, --help       Show this help"
}

log() {
  if [[ "${QUIET}" == false ]]; then
    echo "$@"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) SCOPE="global" ;;
    --project) SCOPE="project" ;;
    --cursor-only)
      INSTALL_CURSOR=true
      INSTALL_CLAUDE=false
      ;;
    --claude-only)
      INSTALL_CURSOR=false
      INSTALL_CLAUDE=true
      ;;
    --remove) DO_REMOVE=true ;;
    --update) DO_UPDATE=true ;;
    --list) DO_LIST=true ;;
    --install-hook) DO_INSTALL_HOOK=true ;;
    --remove-hook) DO_REMOVE_HOOK=true ;;
    --quiet) QUIET=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="${SKILLS_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
HANDLE_TASK_DIR="${SKILLS_ROOT}/handle-task-skill"
MAKE_PR_DIR="${SKILLS_ROOT}/handle-task-skill/make-pull-request"
CREATE_TICKET_DIR="${SKILLS_ROOT}/handle-task-skill/create-ticket"
REVIEW_TICKET_DIR="${SKILLS_ROOT}/handle-task-skill/review-ticket"
MANIFEST="${HOME}/.config/handle-task-skills/source"
HOOK_MARKER="# handle-task-skills-sync (managed by install-skills.sh)"
HOOK_SCRIPT="${HANDLE_TASK_DIR}/scripts/sync-skills-hook.sh"

TARGET_DIRS=()

skills_target_dirs() {
  TARGET_DIRS=()
  local base
  if [[ "$SCOPE" == "project" ]]; then
    base="$(pwd)"
  else
    base="${HOME}"
  fi
  if [[ "${INSTALL_CURSOR}" == true ]]; then
    TARGET_DIRS+=("${base}/.cursor/skills")
  fi
  if [[ "${INSTALL_CLAUDE}" == true ]]; then
    TARGET_DIRS+=("${base}/.claude/skills")
  fi
}

skill_source_dir() {
  case "$1" in
    handle-task) printf '%s\n' "${HANDLE_TASK_DIR}" ;;
    make-pull-request) printf '%s\n' "${MAKE_PR_DIR}" ;;
    create-ticket) printf '%s\n' "${CREATE_TICKET_DIR}" ;;
    review-ticket) printf '%s\n' "${REVIEW_TICKET_DIR}" ;;
    *)
      echo "error: unknown skill: $1" >&2
      exit 1
      ;;
  esac
}

validate_sources() {
  local skill src
  for skill in "${SKILL_NAMES[@]}"; do
    src="$(skill_source_dir "${skill}")"
    if [[ ! -f "${src}/SKILL.md" ]]; then
      echo "error: missing ${src}/SKILL.md" >&2
      exit 1
    fi
  done
}

write_manifest() {
  [[ "${SCOPE}" == "global" ]] || return 0
  mkdir -p "$(dirname "${MANIFEST}")"
  {
    echo "# Written by handle-task-skill/scripts/install-skills.sh — do not edit."
    echo "source_root=${SKILLS_ROOT}"
    echo "handle_task_dir=${HANDLE_TASK_DIR}"
    echo "make_pull_request_dir=${MAKE_PR_DIR}"
    echo "create_ticket_dir=${CREATE_TICKET_DIR}"
    echo "review_ticket_dir=${REVIEW_TICKET_DIR}"
    echo "install_cursor=${INSTALL_CURSOR}"
    echo "install_claude=${INSTALL_CLAUDE}"
    echo "updated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    local dir
    for dir in "${TARGET_DIRS[@]}"; do
      echo "skills_dir=${dir}"
    done
  } >"${MANIFEST}"
  log "manifest ${MANIFEST}"
}

link_one() {
  local target_dir="$1"
  local skill_name="$2"
  local skill_src="$3"
  local dest="${target_dir}/${skill_name}"
  [[ -e "${dest}" && ! -L "${dest}" ]] && {
    echo "error: ${dest} exists and is not a symlink; remove it manually" >&2
    exit 1
  }
  ln -sfn "${skill_src}" "${dest}"
  log "linked ${dest} -> ${skill_src}"
}

remove_one() {
  local target_dir="$1"
  local skill_name="$2"
  local dest="${target_dir}/${skill_name}"
  if [[ -L "${dest}" ]]; then
    rm "${dest}"
    log "removed ${dest}"
  elif [[ -e "${dest}" ]]; then
    log "skipped ${dest} (exists but is not a symlink)"
  fi
}

remove_legacy() {
  local target_dir="$1"
  local legacy
  for legacy in "${LEGACY_SKILLS[@]}"; do
    remove_one "${target_dir}" "${legacy}"
  done
}

install_git_hook() {
  local git_dir hook_file
  git_dir="$(git -C "${SKILLS_ROOT}" rev-parse --git-dir 2>/dev/null)" || {
    echo "error: ${SKILLS_ROOT} is not a git repository" >&2
    exit 1
  }
  hook_file="$(cd "${git_dir}" && pwd)/hooks/post-commit"
  mkdir -p "$(dirname "${hook_file}")"
  chmod +x "${HOOK_SCRIPT}"

  if [[ -f "${hook_file}" ]] && grep -qF "${HOOK_MARKER}" "${hook_file}"; then
    log "git hook already installed: ${hook_file}"
    return 0
  fi

  {
    echo ""
    echo "${HOOK_MARKER}"
    echo "\"${HOOK_SCRIPT}\" || true"
  } >>"${hook_file}"
  chmod +x "${hook_file}"
  log "installed git post-commit hook: ${hook_file}"
  log "  refreshes global Cursor + Claude Code skills when skill files change"
}

remove_git_hook() {
  local git_dir hook_file tmp
  git_dir="$(git -C "${SKILLS_ROOT}" rev-parse --git-dir 2>/dev/null)" || {
    echo "error: ${SKILLS_ROOT} is not a git repository" >&2
    exit 1
  }
  hook_file="$(cd "${git_dir}" && pwd)/hooks/post-commit"
  if [[ ! -f "${hook_file}" ]]; then
    log "no post-commit hook to update"
    return 0
  fi
  if ! grep -qF "${HOOK_MARKER}" "${hook_file}"; then
    log "post-commit hook has no handle-task-skills fragment: ${hook_file}"
    return 0
  fi

  tmp="$(mktemp)"
  awk -v marker="${HOOK_MARKER}" '
    $0 == marker { skip=1; next }
    skip && $0 ~ /^"/ { skip=0; next }
    !skip { print }
  ' "${hook_file}" >"${tmp}"
  mv "${tmp}" "${hook_file}"
  chmod +x "${hook_file}"
  log "removed handle-task-skills fragment from ${hook_file}"
}

print_list() {
  local target_dir local_skill src dest
  echo "Scope:              ${SCOPE}"
  echo "Source root:        ${SKILLS_ROOT}"
  echo "Install Cursor:     ${INSTALL_CURSOR}"
  echo "Install Claude:     ${INSTALL_CLAUDE}"
  echo "Manifest:           ${MANIFEST}"
  echo "Hook script:        ${HOOK_SCRIPT}"
  echo "Target directories:"
  for target_dir in "${TARGET_DIRS[@]}"; do
    echo "  - ${target_dir}"
  done
  echo
  for local_skill in "${SKILL_NAMES[@]}"; do
    src="$(skill_source_dir "${local_skill}")"
    echo "${local_skill}:"
    echo "  source: ${src}"
    for target_dir in "${TARGET_DIRS[@]}"; do
      dest="${target_dir}/${local_skill}"
      echo "  dest:   ${dest}"
      if [[ -L "${dest}" ]]; then
        echo "  link:   $(readlink "${dest}")"
      elif [[ -e "${dest}" ]]; then
        echo "  link:   (exists, not a symlink)"
      else
        echo "  link:   (not installed)"
      fi
    done
    echo
  done
}

skills_target_dirs

if [[ "${DO_LIST}" == true ]]; then
  print_list
  exit 0
fi

if [[ "${DO_INSTALL_HOOK}" == true ]]; then
  install_git_hook
  exit 0
fi

if [[ "${DO_REMOVE_HOOK}" == true ]]; then
  remove_git_hook
  exit 0
fi

if ((${#TARGET_DIRS[@]} == 0)); then
  echo "error: no target directories selected (use --cursor-only / --claude-only carefully)" >&2
  exit 1
fi

validate_sources

if [[ "${DO_REMOVE}" == true ]]; then
  for target_dir in "${TARGET_DIRS[@]}"; do
    remove_one "${target_dir}" handle-task
    remove_one "${target_dir}" make-pull-request
    remove_one "${target_dir}" create-ticket
    remove_one "${target_dir}" review-ticket
    remove_legacy "${target_dir}"
  done
  if [[ -f "${MANIFEST}" && "${SCOPE}" == "global" ]]; then
    rm -f "${MANIFEST}"
    log "removed ${MANIFEST}"
  fi
else
  for target_dir in "${TARGET_DIRS[@]}"; do
    mkdir -p "${target_dir}"
    remove_legacy "${target_dir}"
    link_one "${target_dir}" handle-task "${HANDLE_TASK_DIR}"
    link_one "${target_dir}" make-pull-request "${MAKE_PR_DIR}"
    link_one "${target_dir}" create-ticket "${CREATE_TICKET_DIR}"
    link_one "${target_dir}" review-ticket "${REVIEW_TICKET_DIR}"
  done
  write_manifest
  log
  log "Done. Skills are symlinked — edits here apply globally without re-install."
  if [[ "${INSTALL_CURSOR}" == true ]]; then
    log "Cursor: reload the window after SKILL.md frontmatter changes."
  fi
  if [[ "${INSTALL_CLAUDE}" == true ]]; then
    log "Claude Code: restart the session if /handle-task does not appear yet."
  fi
  log "  /handle-task         — ticket → implement → verify"
  log "  /make-pull-request   — draft PR → CI → ready"
  log "  /create-ticket       — draft + create well-documented tickets"
  log "  /review-ticket       — quality gate, backfill, scope check"
  log
  log "Per repo: copy handle-task-skill/examples/generic.project.yaml → .handle-task/project.yaml"
  log "Auto-sync on commit:  ./handle-task-skill/scripts/install-skills.sh --install-hook"
  if [[ "${DO_UPDATE}" == true ]]; then
    log "(symlinks refreshed via --update)"
  fi
fi
