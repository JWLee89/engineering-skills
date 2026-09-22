---
name: handle-task
description: >-
  Portable ticket-to-ship workflow: load .handle-task/project.yaml, /review-ticket on
  tracker issues, spec + plan approval gates, TDD implementation, then /pull-request
  (full PR template and CI). Use for ticket IDs, handle a task, or workflow fixes.
disable-model-invocation: true
---

# Handle task

**Invoke:** `/handle-task` · **Companion:** `/pull-request` · **Entry:** [QUICKSTART.md](QUICKSTART.md)

Load **`.handle-task/project.yaml`** first ([project-config.md](project-config.md)).

```
INTAKE → /review-ticket ✓ → SPECIFY → SPEC ✓ → PLAN → PLAN ✓ → MEMORY → IMPLEMENT → VERIFY → /pull-request
```

## Mandatory gates (do not skip)

| Gate | When | Source of truth |
| ---- | ---- | --------------- |
| **Ticket quality** | Before writing a spec | Invoke **`/review-ticket`** ([review-ticket/workflow.md](review-ticket/workflow.md)); user confirms ticket is ready |
| **Implementation spec** | Before plan or code | [specify.md](specify.md) — **explicit user approval** of local spec (not ticket description alone) |
| **Plan + todo** | Before branch / code | [plan-and-tasks.md](plan-and-tasks.md) — explicit user approval |
| **Pull request** | After Phase 8 verify | Invoke **`/pull-request`** ([pull-request/workflow.md](pull-request/workflow.md)) — not a bare `gh pr create` summary |

**Tracker issues (JIRA, Linear, GitHub):** always run **`/review-ticket`** in Phase 1. Do not inline the four-point review or skip because the ticket “looks fine.”

**Resume / handoff:** if context was summarized or the user said “approved” earlier, still **re-present the spec (or spec path + bullets) and wait for explicit approval** before implementation.

**Skip** the full flow only for trivial one-file fixes (no tracker, no spec).

## Delegates

| Phase | Read |
| ----- | ---- |
| Ticket review | [review-ticket/workflow.md](review-ticket/workflow.md) |
| Spec | [specify.md](specify.md) → [spec-driven-development.md](spec-driven-development.md) |
| Plan | [plan-and-tasks.md](plan-and-tasks.md) → [planning-and-task-breakdown.md](planning-and-task-breakdown.md) |
| Implement | [incremental-implementation.md](incremental-implementation.md) → [test-driven-development.md](test-driven-development.md) |
| Spec ↔ tests | [spec-adherence.md](spec-adherence.md) |
| Verify | [verification.md](verification.md) |
| PR | [pull-request/workflow.md](pull-request/workflow.md) |
| ADRs / docs | [documentation-and-adrs.md](documentation-and-adrs.md) |
| Review / perf | [code-review.md](code-review.md) · [performance-optimization.md](performance-optimization.md) |
| Skill fixes | [self-improvement.md](self-improvement.md) |
| Ticket create | [create-ticket/workflow.md](create-ticket/workflow.md) |

## Artifacts

| Artifact | Path (typical) | Commit? |
| -------- | -------------- | ------- |
| Spec, plan, todo | `memory.local_specs` | **Never** |
| Task scratchpad | `memory.committed_tasks` | Yes |
| Status / decisions | `memory.status`, `memory.decisions` | Yes (decisions append-only) |

## Checklist

```
- [ ] project.yaml loaded; issue fetched
- [ ] /review-ticket completed; caller confirmed ticket ready (tracker issues)
- [ ] Implementation spec written; explicit spec approval recorded
- [ ] Plan + todo written; explicit plan approval recorded
- [ ] Task memory + branch ({ticket.id_pattern})
- [ ] Slices: REUSE → RED → GREEN → spec adherence
- [ ] Phase 8 verify + spec traceability ([spec-adherence.md](spec-adherence.md))
- [ ] /pull-request: template body, Δ lines, verification plan, CI URLs
```

______________________________________________________________________

## Phase 1: Intake

Fetch issue ([issue-tracker-adapters.md](issue-tracker-adapters.md)), read `memory.*` + agent guide, check prior PRs/task files.

Unassigned JIRA → assign to current user ([issue-transitions.md](issue-transitions.md)).

Oversized scope → [pr-splitting.md](pr-splitting.md) + real subtasks ([subtask-template.md](subtask-template.md)).

### Ticket review (hard stop)

1. Invoke **`/review-ticket`** for the issue key (or pasted content if `issue_tracker.type: none`).
2. Backfill / split per that workflow until the four-point gate passes.
3. **Stop** until the user confirms the **ticket** is ready to implement (separate from spec approval later).

Do not write `{local_specs}` or code until this step completes.

## Phases 2–4: Specify

Follow [specify.md](specify.md). **Hard stop** until the user **explicitly approves the implementation spec** (local `SPEC-*.md`), even when the JIRA description was already approved via `/review-ticket`.

## Phase 5: Plan

Follow [plan-and-tasks.md](plan-and-tasks.md). **Hard stop** until the user explicitly approves plan + todo.

## Phase 6: Task memory

Concise committed scratchpad; link local spec — never paste full spec.

## Phase 7: Implement

Execute approved todo: [incremental-implementation.md](incremental-implementation.md), [test-driven-development.md](test-driven-development.md), [spec-adherence.md](spec-adherence.md) per slice.

Commits when user asks or for PR prep. Never commit local specs or secrets.

## Phase 8: Verify

[verification.md](verification.md) + [spec-adherence.md](spec-adherence.md) matrix. Document CI-only gaps for the PR.

## Phase 9: Pull request

Run **`/pull-request`** — do not substitute a minimal PR description.

Required from [pull-request/workflow.md](pull-request/workflow.md): **Background**, **Purpose**, **Review guide**, **Changes made (git numstat Δ)**, **Verification** (author steps + CI checkboxes + out of scope), draft until ready unless user says otherwise, JIRA transition on ready when configured.

Record spec deviations (e.g. simplified design vs original JIRA DoD) in the PR **Spec adherence** or **Notes** section.

## Self-improvement

Process gaps → [self-improvement.md](self-improvement.md); notify user.

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Code without **implementation spec** approval | [specify.md](specify.md) gate |
| JIRA “approved” treated as spec approval | Two gates: ticket (`/review-ticket`) then local spec |
| Skipping `/review-ticket` on JIRA tickets | Phase 1 hard stop |
| `gh pr create` with Summary-only body | `/pull-request` + [templates.md](templates.md) |
| Silent deferral of spec items | Report + user ack in PR |
| Duplicating review rules in handle-task | Link [quality-gate.md](review-ticket/quality-gate.md) only |
