---
name: handle-task
description: >-
  Portable ticket-to-ship workflow: load .handle-task/project.yaml, fetch issue,
  spec with approval gates, TDD implementation with spec adherence verification,
  self-improving skill updates on gaps, then hand off to /pull-request.
  Use when user gives a ticket ID, asks to handle a task, or improve the workflow.
disable-model-invocation: true
---

# Handle task

**Invoke:** `/handle-task` · **Companion:** `/pull-request` · **Entry:** [QUICKSTART.md](QUICKSTART.md)

Load **`.handle-task/project.yaml`** first ([project-config.md](project-config.md)).

```
INTAKE → [SPLIT?] → SPECIFY → SPEC ✓ → PLAN → PLAN ✓ → MEMORY → IMPLEMENT → VERIFY → /pull-request
```

## Delegates

| Phase | Read |
| ----- | ---- |
| Spec | [specify.md](specify.md) → [spec-driven-development.md](spec-driven-development.md) |
| Plan | [plan-and-tasks.md](plan-and-tasks.md) → [planning-and-task-breakdown.md](planning-and-task-breakdown.md) |
| Implement | [incremental-implementation.md](incremental-implementation.md) → [test-driven-development.md](test-driven-development.md) |
| Spec ↔ tests | [spec-adherence.md](spec-adherence.md) |
| Verify | [verification.md](verification.md) |
| Skill evolution | [self-improvement.md](self-improvement.md) |
| ADRs | [documentation-and-adrs.md](documentation-and-adrs.md) |
| Review / perf | [code-review.md](code-review.md) · [performance-optimization.md](performance-optimization.md) |
| PR | [pull-request/workflow.md](pull-request/workflow.md) |
| Ticket review | [review-ticket/workflow.md](review-ticket/workflow.md) |
| Ticket create | [create-ticket/workflow.md](create-ticket/workflow.md) |

## Artifacts

| Artifact | Path (typical) | Commit? |
| -------- | -------------- | ------- |
| Spec, plan, todo | `memory.local_specs` | **Never** |
| Task scratchpad | `memory.committed_tasks` | Yes |
| Status / decisions | `memory.status`, `memory.decisions` | Yes (decisions append-only) |

## Checklist

```
- [ ] project.yaml loaded; issue fetched; assumptions recorded
- [ ] Documentation quality gate passed or backfilled + confirmed ([review-ticket/quality-gate.md](review-ticket/quality-gate.md) via `/review-ticket`)
- [ ] Spec approved (local_specs); plan + todo approved
- [ ] Task memory + branch ({ticket.id_pattern})
- [ ] Each slice: REUSE → RED → GREEN → REFACTOR → spec adherence ([incremental-implementation.md](incremental-implementation.md))
- [ ] Phase 8: traceability matrix green or gaps reported to user ([spec-adherence.md](spec-adherence.md))
- [ ] Local verify green; CI-only gaps documented
- [ ] Process gap or user feedback → skill patched + user notified ([self-improvement.md](self-improvement.md))
- [ ] User prompted for /pull-request
```

**Skip** entire flow for trivial one-file fixes.

______________________________________________________________________

## Phase 1: Intake

Fetch issue (`integrations.issue_tracker`), read `memory.*` + agent guide, check prior PRs/task files.
Unassigned JIRA → assign to current user ([issue-transitions.md](issue-transitions.md)).
Split oversized work → [pr-splitting.md](pr-splitting.md) + real subtasks ([subtask-template.md](subtask-template.md)).

**Documentation quality gate (hard stop):** before spec/plan, run **`/review-ticket`**
(or inline [review-ticket/quality-gate.md](review-ticket/quality-gate.md)):

1. Enough background for the assignee to handle the task?
2. Well-defined scope? (too big → split into real sub-tasks)
3. Definition of done + required steps clear?
4. Can a new onboarder read the ticket and complete it?

If the fetched ticket fails any check, **ask clarifying questions**, backfill the ticket
(via [issue-tracker-adapters.md](issue-tracker-adapters.md)), and **confirm with the caller**
before proceeding to spec. Do not start implementation on an under-documented ticket. If the
user asks to create a fresh ticket instead, hand off to `/create-ticket`.

## Phases 2–4: Specify

[specify.md](specify.md) — **hard stop** until user approves spec.

## Phase 5: Plan

[plan-and-tasks.md](plan-and-tasks.md) — **hard stop** until user approves plan/todo.

## Phase 6: Task memory

Concise committed scratchpad; link local spec — never paste full spec.

## Phase 7: Implement

Branch + optional issue transition. Execute todo slices:

1. **[incremental-implementation.md](incremental-implementation.md)** — REUSE, SOLID, vertical slices
2. **[test-driven-development.md](test-driven-development.md)** — RED → GREEN → REFACTOR for behavior changes
3. **[spec-adherence.md](spec-adherence.md)** — after each slice: map acceptance criteria → tests; report gaps to user; fix Blockers

**Non-negotiable:** tests must cover spec success criteria — passing tests alone is insufficient.
Shortcuts over core requirements → stop, report, fix.

Commits when user asks or for PR prep. Never commit local specs or secrets.

## Phase 8: Verify

[verification.md](verification.md) + full **[spec-adherence.md](spec-adherence.md)** matrix (all success criteria, testing strategy, non-negotiables).
Document CI-only gaps for `/pull-request`.

## Phase 9: Pull request

Prompt user → `/pull-request` only.

## Self-improvement

When a mistake, spec gap, or user improvement request reveals **workflow** weakness:

1. Fix the ticket work if still in scope
2. **[self-improvement.md](self-improvement.md)** — patch skill, notify user, PR to `engineering-skills` when appropriate

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Code before spec/plan approval | Gates in specify.md / plan-and-tasks.md |
| Production code before failing test | [test-driven-development.md](test-driven-development.md) |
| Tests pass but spec scenario missing | [spec-adherence.md](spec-adherence.md) |
| Reimplementing existing helpers | REUSE in [incremental-implementation.md](incremental-implementation.md) |
| Duplicated rules across skill files | One source; link elsewhere ([self-improvement.md](self-improvement.md)) |
| Silent deferral of spec items | Report + user ack |
