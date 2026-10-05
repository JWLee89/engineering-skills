# Quick start (agents)

**Quality first.** Read only files for the **current phase** — [SKILL.md](SKILL.md#lazy-load-do-not-read-the-whole-bundle).

## Nine-step workflow

| Step | Action | Invoke / doc |
| ---- | ------ | ------------- |
| 1 (opt) | Create ticket | `/create-ticket` → `/review-ticket` |
| 2 | Analyze ticket | `/review-ticket` or `/handle-task` Phase 1 |
| 3 | Spec | `/handle-task` → [specify.md](specify.md) |
| 4 | Plan | [plan-and-tasks.md](plan-and-tasks.md) |
| 5 | Split if too large | [pr-splitting.md](pr-splitting.md) · `/review-ticket` Phase 3 |
| 6 | Implement | [incremental-implementation.md](incremental-implementation.md) · [engineering-rubric.md](engineering-rubric.md) |
| 7 | Pre-PR quality | [engineering-rubric.md](engineering-rubric.md) author checklist |
| 8 | Pull request | `/pull-request` draft ([workflow.md](../pull-request/workflow.md) Phases 1–4) |
| 9 | Review loop | `/code-review` · `/pull-request` review triage (push back when comments are wrong) |

## Invocations

| Command | When |
| ------- | ---- |
| `/handle-task` | Ticket → spec → plan → implement → verify |
| `/pull-request` | PR create/update, CI, conflicts, ready |
| `/create-ticket` | Draft + create tracker issue |
| `/review-ticket` | Four-point ticket gate, backfill, split |
| `/code-review` | Deep PR review (mandatory handle-task Phase 9b before ready) |
| `/update-skills` | Add or modify catalog skills (intent gate before edits) |

**Folder:** `skills/handle-task/` · **Name:** `handle-task` from [SKILL.md](SKILL.md) frontmatter.

## First step (every session)

1. Read **`.handle-task/project.yaml`** ([project-config.md](project-config.md)).
2. If missing: copy [examples/generic.project.yaml](examples/generic.project.yaml) → `.handle-task/project.yaml`; confirm with user.

Install (once): `./scripts/install-skills.sh` — symlinks to `~/.cursor/skills/` and `~/.claude/skills/`. Reload Cursor after `SKILL.md` frontmatter changes.

## SSOT map (do not duplicate criteria elsewhere)

| Topic | File |
| ----- | ---- |
| Orchestrator + lazy load | [SKILL.md](SKILL.md) |
| Ticket quality | [review-ticket/quality-gate.md](../review-ticket/quality-gate.md) |
| Spec + gate | [specify.md](specify.md) |
| Plan + gate | [plan-and-tasks.md](plan-and-tasks.md) |
| Implement + author quality | [engineering-rubric.md](engineering-rubric.md) |
| Deep PR review | [code-review/rubric.md](../code-review/rubric.md) |
| Verify | [verification.md](verification.md) |
| PR phases | [pull-request/workflow.md](../pull-request/workflow.md) |
| PR body format | [reviewer-friendly-pr-body.md](../pull-request/references/reviewer-friendly-pr-body.md) |
| Code review phases | [code-review/workflow.md](../code-review/workflow.md) |

## Related global skills

Use **bundle delegates OR** overlapping globals (e.g. `code-review-and-quality`, `spec-driven-development`), **not both** for the same phase.

## Trackers & transitions

`integrations.issue_tracker.type`: `jira` | `linear` | `github` | `none` — see [issue-tracker-adapters.md](issue-tracker-adapters.md).

Status transitions (when configured): [issue-transitions.md](issue-transitions.md). Unassigned work items → assign the authenticated tracker user at intake when supported.
