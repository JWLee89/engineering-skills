---
name: handle-task
version: "1.0.0"
domain: workflow
role: orchestrator
scope: ticket-to-ship
triggers:
  - /handle-task
  - work a ticket
  - implement issue
related-skills:
  - review-ticket
  - create-ticket
  - pull-request
  - code-review
description: >-
  Ticket-to-ship: load .handle-task/project.yaml, /review-ticket, spec + plan gates,
  implement with engineering rubric, agentic verify, /pull-request draft, /code-review, ready.
disable-model-invocation: true
---

# Handle task

**Invoke:** `/handle-task` · **Entry:** [QUICKSTART.md](QUICKSTART.md) · **Map:** [references/workflow-map.md](references/workflow-map.md) · **Config:** [project-config.md](project-config.md)

Load **`.handle-task/project.yaml`** first. **Quality over token savings** — read only the delegates for the **current phase** ([lazy load](#lazy-load-do-not-read-the-whole-bundle)).

```
INTAKE → /review-ticket ✓ → SPECIFY → SPEC ✓ → PLAN → PLAN ✓ → MEMORY → IMPLEMENT → VERIFY
  → /pull-request (draft) → /code-review ✓ → /pull-request (ready)
```

## Mandatory gates

| Gate | When | Source |
| ---- | ---- | ------ |
| Ticket quality | Before spec | **`/review-ticket`** — [review-ticket/workflow.md](../review-ticket/workflow.md) |
| Implementation spec | Before plan/code | [specify.md](specify.md) — explicit user approval |
| Plan + todo | Before branch/code | [plan-and-tasks.md](plan-and-tasks.md) — explicit approval |
| Feature isolation | Behavioral slices | [feature-gating.md](feature-gating.md) |
| Agentic verify | Phase 8 | [verification.md](verification.md) |
| Deep code review | After draft PR | **`/code-review`** — [code-review/workflow.md](../code-review/workflow.md) |
| Pull request | Phases 9–10 | **`/pull-request`** — [pull-request/workflow.md](../pull-request/workflow.md) |

Tracker issues: always **`/review-ticket`** in Phase 1. **Skip** full flow only for trivial one-file fixes.

**Resume:** re-present spec (path + bullets) and wait for explicit approval before coding.

## Lazy load (do not read the whole bundle)

| Phase | Read | Defer |
| ----- | ---- | ----- |
| Intake | This file, [review-ticket/workflow.md](../review-ticket/workflow.md) | `specify.md`, implement/PR/review workflows |
| Specify | [specify.md](specify.md) + one [templates.md](templates.md) anchor | Plan, rubric, PR workflows |
| Plan | [plan-and-tasks.md](plan-and-tasks.md) + plan/todo template anchors | PR/code-review until Phase 9 |
| Implement | [incremental-implementation.md](incremental-implementation.md), [engineering-rubric.md](engineering-rubric.md), slice delegates from todo | Full [code-review/workflow.md](../code-review/workflow.md) |
| Verify | [verification.md](verification.md), [spec-adherence.md](spec-adherence.md) | — |
| Draft PR | [pull-request/workflow.md](../pull-request/workflow.md) through Phase 4 | Full rubric until `/code-review` |
| Deep review | [code-review/workflow.md](../code-review/workflow.md), [code-review/rubric.md](../code-review/rubric.md) | — |

Optional: `/create-ticket` → [create-ticket/workflow.md](../create-ticket/workflow.md).

## Delegates (by need)

| Topic | File |
| ----- | ---- |
| Issue fetch | [issue-tracker-adapters.md](issue-tracker-adapters.md) · [issue-transitions.md](issue-transitions.md) |
| Split / subtasks | [pr-splitting.md](pr-splitting.md) · [subtask-template.md](subtask-template.md) |
| TDD | [test-driven-development.md](test-driven-development.md) |
| ADRs / wire formats | [documentation-and-adrs.md](documentation-and-adrs.md) |
| Author self-review | [engineering-rubric.md](engineering-rubric.md) ([code-review.md](code-review.md) pointer) |
| Perf | [performance-optimization.md](performance-optimization.md) |
| Skill fixes | [self-improvement.md](self-improvement.md) |

## Artifacts

| Artifact | Path | Commit? |
| -------- | ---- | ------- |
| Spec, plan, todo | `memory.local_specs` | Never |
| Task scratchpad | `memory.committed_tasks` | Yes |
| Status / decisions | `memory.status`, `memory.decisions` | Yes |

## Phases (detail in linked files)

1. **Intake** — fetch issue; **`/review-ticket`**; user confirms ticket ready.
2. **Specify** — [specify.md](specify.md); user approves local spec.
3. **Plan** — [plan-and-tasks.md](plan-and-tasks.md); user approves plan + todo.
4. **Memory** — concise scratchpad; link spec path.
5. **Implement** — todo slices + [engineering-rubric.md](engineering-rubric.md).
6. **Verify** — agent runs checks; evidence + spec matrix.
7. **Draft PR** — **`/pull-request`** Phases 1–4; no `gh pr ready` yet.
8. **Deep review** — **`/code-review`**; fix Blockers; user approves review draft.
9. **Ready** — **`/pull-request`** CI green, author rubric pass, `gh pr ready`, issue transition.

## Phase 9: Pull request (draft) + deep code review

Cross-link target for [pull-request/workflow.md](../pull-request/workflow.md). After Phase 8 verify:

- **9a — Draft PR:** **`/pull-request`** Phases 1–4; no `gh pr ready` yet.
- **9b — Deep review:** **`/code-review`** on the task PR; user approves draft; fix **Blockers** before ready.
- **Phase 10 — Ready:** **`/pull-request`** CI green, [engineering-rubric.md](engineering-rubric.md) author pass, `gh pr ready`.

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Code without spec/plan approval | Gates in [specify.md](specify.md), [plan-and-tasks.md](plan-and-tasks.md) |
| Tracker ticket “approved” treated as spec approval | Ticket gate then **local spec** gate — [specify.md](specify.md) |
| Skip `/review-ticket` on tracker issues | Phase 1 |
| Silent deferral of spec items | Report + user ack in PR ([spec-adherence.md](spec-adherence.md)) |
| Full-stack only, no isolation proof | [feature-gating.md](feature-gating.md) in plan + slice |
| `gh pr create` with summary-only body | `/pull-request` + [templates.md](templates.md) |
| `gh pr ready` without `/code-review` | [Phase 9b](#phase-9-pull-request-draft-deep-code-review) |
| User asked to run tests | Agent runs verify ([verification.md](verification.md)) |
| “Tests pass” with no command output | Evidence in [verification.md](verification.md) |
| Author self-review only, skip `/code-review` | Phase 9b vs [engineering-rubric.md](engineering-rubric.md) |
| Read entire skill bundle at intake | [Lazy load](#lazy-load-do-not-read-the-whole-bundle) |
| Duplicate ticket/review criteria in this file | [quality-gate.md](../review-ticket/quality-gate.md), [code-review/rubric.md](../code-review/rubric.md) |
