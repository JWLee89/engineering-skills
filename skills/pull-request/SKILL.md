---
name: pull-request
version: "1.0.0"
domain: workflow
role: author
scope: pull-request-lifecycle
triggers:
  - /pull-request
  - open PR
  - fix CI
related-skills:
  - handle-task
  - code-review
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
**Companions:** `/handle-task` (ticket → code) — run **after Phase 8**; **`/code-review`** is
**mandatory in handle-task Phase 9b** before `gh pr ready`. Do not replace with ad-hoc `gh pr create`.
**Agent entry:** [workflow.md](workflow.md) by phase ([Load when](#load-when) — do not read the whole file up front).

**Single source of truth:** `skills/pull-request/` (symlinked globally by
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

1. Load **`.handle-task/project.yaml`** — [../project-config.md](../handle-task/project-config.md)
2. Follow **[workflow.md](workflow.md)**

## Load when

| Phase | Read | Defer |
| ----- | ---- | ----- |
| Pre-flight | [workflow.md](workflow.md) Phases 0–1 | Phase 2 references until git/gh pre-flight done |
| Plan body | [references/reviewer-friendly-pr-body.md](references/reviewer-friendly-pr-body.md), [references/pr-body-template.md](references/pr-body-template.md), [references/pr-diff-links.md](references/pr-diff-links.md) | Later workflow phases |
| Create / CI / ready | [workflow.md](workflow.md) Phases 3–7 | — |
| Verify checkboxes | [../handle-task/references/templates/verification-pr-body.md](../handle-task/references/templates/verification-pr-body.md) | [../handle-task/templates.md](../handle-task/templates.md) index only |
| Author quality | [../handle-task/engineering-rubric.md](../handle-task/engineering-rubric.md) | `/code-review` rubric until Phase 9b |

## Quick map

| Phase | What |
| ----- | ---- |
| 0 | Load project config |
| 1 | Pre-flight — git, existing PR, tracker comments |
| 2 | Review-friendly plan — body + **Review guide (summary, commits, line focus)** + **Changes made (Δ lines)** + verification |
| 3 | Create draft PR or refresh open PR |
| 4–5 | Execute verification; CI/CD fix loop; merge conflicts |
| 5d | Review feedback loop |
| 6 | Author self-review → [../engineering-rubric.md](../handle-task/engineering-rubric.md) |
| 7 | Ready gate → `gh pr ready` → issue transition |

## Boundaries

- **Always:** `pr.draft_until_ready`; CI run URLs in Verification; Review guide links PR diff hunks + `?plain=1` for markdown; labels from `pr.labels`
- **Never:** `gh pr ready` with red required CI; merge without user request
- **Ask first:** squash, force-push, amending pushed commits
