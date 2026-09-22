---
name: pull-request
description: >-
  Portable PR lifecycle: create or update pull requests, resolve merge conflicts,
  fix CI/CD failures, address review feedback, simplify code for reviewability,
  and keep descriptions verification-backed until merge-ready. Load
  .handle-task/project.yaml. Use after /handle-task, when opening or updating a PR,
  when CI is red, when resolving review comments, or when user says pull request.
disable-model-invocation: true
---

# Pull request

Own the **full PR lifecycle** — not only the first `gh pr create`.

**Invoke:** `/pull-request`
**Companion:** `/handle-task` (ticket → code) — run **after Phase 8**; do not replace with ad-hoc `gh pr create`.
**Agent entry:** read [workflow.md](workflow.md) in full.

**Single source of truth:** `handle-task-skill/pull-request/` (symlinked globally by
`scripts/install-skills.sh`).

## Scope

| In scope | Out of scope (unless user asks) |
| -------- | ------------------------------- |
| Draft/create/update PR body, labels, verification checkboxes | Merge to main |
| Merge-base conflicts, rebase/merge + force-with-lease when user requests | Force-push without user approval |
| CI/CD fix loop (logs → minimal fix → push → watch) | Disabling tests or skipping hooks |
| Review comment triage → code fixes → push → reply | Rewriting product spec |
| Pre-merge self-review (complexity, duplication, scope) | Drive-by refactors unrelated to PR |
| Squash/rebase history when user asks | |

## Before starting

1. Load **`.handle-task/project.yaml`** — [../project-config.md](../project-config.md)
2. Follow **[workflow.md](workflow.md)**

## Quick map

| Phase | What |
| ----- | ---- |
| 0 | Load project config |
| 1 | Pre-flight — git, existing PR, tracker comments |
| 2 | Review-friendly plan — body + **Changes made (with Δ lines)** + verification |
| 3 | Create draft PR or refresh open PR |
| 4–5 | Execute verification; CI/CD fix loop; merge conflicts |
| 5d | Review feedback loop |
| 6 | Pre-merge code review → [../code-review.md](../code-review.md) |
| 7 | Ready gate → `gh pr ready` → issue transition |

## Core principles

1. **Easy to review** — Background/Purpose, file-ordered Review guide, **Changes made with line deltas**, Out of scope
2. **Verification is executable** — every checkbox maps to a command or CI run URL
3. **Draft until proven** — stay draft until author steps + required CI are green
4. **Improve while iterating** — fix CI, conflicts, and review findings in focused commits; simplify complexity when it blocks review

## Boundaries

- **Always:** `pr.draft_until_ready`; CI run URLs in Verification; labels from `pr.labels`
- **Never:** `gh pr ready` with red required CI; merge without user request
- **Ask first:** squash, force-push, amending pushed commits
