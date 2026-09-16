---
name: make-pull-request
description: >-
  Portable post-implementation PR workflow: load .handle-task/project.yaml,
  build a review-friendly description with a verification plan, open draft PR,
  apply labels, execute and check off every verification step, run CI fix loop,
  pre-merge code review, then mark ready only when evidence is complete. Use
  after /handle-task implementation is complete, when opening or finalizing a PR,
  or when user says make pull request or get CI green.
disable-model-invocation: true
---

# Make pull request

Run **after `/handle-task` implementation** is complete on the feature branch.

**Invoke:** `/make-pull-request`
**Companion:** `/handle-task` (ticket → code)
**Agent entry:** read [workflow.md](workflow.md) in full.

**Single source of truth:** this folder lives inside `handle-task-skill/`. Edits here apply
globally via `install-skills.sh` — there is no separate `make-pull-request-skill/` bundle.

## Before starting

1. Load **`.handle-task/project.yaml`** — schema in [../project-config.md](../project-config.md)
2. Follow **[workflow.md](workflow.md)** (phases 0–7)

## Quick map

| Phase | What                                                                                        |
| ----- | ------------------------------------------------------------------------------------------- |
| 0     | Load project config                                                                         |
| 1     | Pre-flight — git, task memory, existing PR                                                  |
| 2     | **Review-friendly PR plan** — body outline + verification plan (author + CI + out of scope) |
| 3     | Push + `gh pr create --draft` + **labels**                                                  |
| 4–5   | **Execute verification plan** — run each step, check boxes, record evidence; CI fix loop    |
| 5b    | Scenario verification commits (optional)                                                    |
| 6     | Pre-merge code review → [../code-review.md](../code-review.md)                              |
| 7     | Update body with evidence → **`gh pr ready` only when gate passes** → issue transition      |

## Core principles

1. **Easy to review** — short Background/Purpose, file-ordered Review guide, table of changes, explicit out-of-scope
2. **Verification is executable** — every checkbox maps to a command or CI run; run them before marking ready
3. **Draft until proven** — stay draft until author steps + required CI are green and checked off

## Boundaries

- **Always:** `pr.draft_until_ready`; CI run URLs in Verification; labels from `pr.labels`
- **Never:** `gh pr ready` with unchecked author steps or red required CI; merge without user request
- **Ask first:** squash verification commits
