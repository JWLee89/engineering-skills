---
name: handle-task
description: >-
  Portable ticket-to-ship workflow: load .handle-task/project.yaml, /review-ticket on
  tracker issues, spec + plan approval gates, TDD + feature isolation gates,
  agentic verification with evidence, /code-review on the task PR, then /pull-request to ready.
  Use for ticket IDs, handle a task, or workflow fixes.
disable-model-invocation: true
---

# Handle task

**Invoke:** `/handle-task` · **Companions:** `/pull-request`, `/code-review` · **Entry:** [QUICKSTART.md](QUICKSTART.md)

Load **`.handle-task/project.yaml`** first ([project-config.md](project-config.md)).

```
INTAKE → /review-ticket ✓ → SPECIFY → SPEC ✓ → PLAN → PLAN ✓ → MEMORY → IMPLEMENT (+ isolation gates) → VERIFY (agentic) → /pull-request (draft) → /code-review ✓ → /pull-request (ready)
```

## Mandatory gates (do not skip)

| Gate | When | Source of truth |
| ---- | ---- | --------------- |
| **Ticket quality** | Before writing a spec | Invoke **`/review-ticket`** ([review-ticket/workflow.md](review-ticket/workflow.md)); user confirms ticket is ready |
| **Implementation spec** | Before plan or code | [specify.md](specify.md) — **explicit user approval** of local spec (not ticket description alone) |
| **Plan + todo** | Before branch / code | [plan-and-tasks.md](plan-and-tasks.md) — explicit user approval |
| **Feature isolation** | Each behavioral slice (when applicable) | [feature-gating.md](feature-gating.md) — prove behavior before full-stack wiring |
| **Agentic verify** | Phase 8 (always) | [verification.md](verification.md) — agent runs checks and records evidence; not user-only |
| **Deep code review** | After draft PR exists (Phase 9) | Invoke **`/code-review`** ([code-review/workflow.md](code-review/workflow.md)) on the task PR; user approves draft; **Blockers** fixed before ready |
| **Pull request** | Phase 9–10 | **`/pull-request`** ([pull-request/workflow.md](pull-request/workflow.md)) — draft + body first, then CI/ready after `/code-review` passes; not a bare `gh pr create` |

**Tracker issues (JIRA, Linear, GitHub):** always run **`/review-ticket`** in Phase 1. Do not inline the four-point review or skip because the ticket “looks fine.”

**Resume / handoff:** if context was summarized or the user said “approved” earlier, still **re-present the spec (or spec path + bullets) and wait for explicit approval** before implementation.

**Skip** the full flow only for trivial one-file fixes (no tracker, no spec).

## Delegates

| Phase | Read |
| ----- | ---- |
| Ticket review | [review-ticket/workflow.md](review-ticket/workflow.md) |
| Spec | [specify.md](specify.md) → [spec-driven-development.md](spec-driven-development.md) |
| Plan | [plan-and-tasks.md](plan-and-tasks.md) → [planning-and-task-breakdown.md](planning-and-task-breakdown.md) |
| Implement | [incremental-implementation.md](incremental-implementation.md) → [test-driven-development.md](test-driven-development.md) → [feature-gating.md](feature-gating.md) |
| Spec ↔ tests | [spec-adherence.md](spec-adherence.md) |
| Verify | [verification.md](verification.md) (agentic validation **required**) |
| PR | [pull-request/workflow.md](pull-request/workflow.md) |
| PR review (deep) | [code-review/workflow.md](code-review/workflow.md) → [code-review/rubric.md](code-review/rubric.md) |
| ADRs / docs | [documentation-and-adrs.md](documentation-and-adrs.md) |
| Author self-review / perf | [code-review.md](code-review.md) · [performance-optimization.md](performance-optimization.md) |
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
- [ ] Slices: REUSE → RED → GREEN → feature gate (when applicable) → spec adherence
- [ ] Phase 8: agentic verify + evidence bundle + spec traceability ([verification.md](verification.md), [spec-adherence.md](spec-adherence.md))
- [ ] Phase 9: /pull-request draft PR (body, Δ lines, verification plan, push)
- [ ] Phase 9: /code-review on that PR — draft approved; no Blockers (or user-accepted deferral)
- [ ] Phase 10: /pull-request CI green, author self-review, ready gate, CI URLs
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

Execute approved todo: [incremental-implementation.md](incremental-implementation.md), [test-driven-development.md](test-driven-development.md), [feature-gating.md](feature-gating.md) (isolation proof when applicable), [spec-adherence.md](spec-adherence.md) per slice.

Commits when user asks or for PR prep. Never commit local specs or secrets.

## Phase 8: Verify

**Always** run [verification.md](verification.md) **agentic validation** (execute commands, capture proof). Complete [spec-adherence.md](spec-adherence.md) matrix. Re-run [feature-gating.md](feature-gating.md) isolation gates for in-scope behavioral slices. Document CI-only gaps and run URLs for the PR.

## Phase 9: Pull request (draft) + deep code review

After Phase 8, ship reviewable code through **`/pull-request`** and **`/code-review`** — do not
substitute a minimal PR description or skip the rubric pass.

### 9a. Open draft PR

Run **`/pull-request`** through at least **Phases 1–4** ([pull-request/workflow.md](pull-request/workflow.md)):

- Push the task branch; create or refresh a **draft** PR
- **Background**, **Purpose**, **Review guide**, **Changes made (Δ)**, **Verification** plan
- Record spec deviations in **Spec adherence** or **Notes**

Do **not** run `gh pr ready` in this sub-step.

### 9b. Deep code review (hard stop)

1. Invoke **`/code-review`** on **this task’s PR** (URL or number — same branch).
2. Complete the full workflow: fresh context → [rubric.md](code-review/rubric.md) → draft markdown.
3. **Stop** until the user **approves** the review draft (edit severities, drop false positives).
4. **Blockers** — fix on the branch, push, re-run **`/code-review`** until none remain (or user
   explicitly accepts deferral with a tracked follow-up).
5. **Major** items — fix or document in the PR with user acknowledgment before ready.

Publishing review comments to the forge is **optional** (user decides after draft approval).
Implementing fixes requires explicit user ask per [code-review/workflow.md](code-review/workflow.md).

**Skip `/code-review` only** for trivial one-file fixes with no draft PR (same bar as skipping full handle-task).

## Phase 10: Pull request (merge-ready)

Continue **`/pull-request`** — CI fix loop, merge conflicts, review feedback, author self-review
([code-review.md](code-review.md)), then **Phase 7 ready gate** only when:

- `/code-review` gate passed (Phase 9b)
- Required CI green with run URLs
- Verification checkboxes have evidence

Then `gh pr ready` and issue transition when configured ([issue-transitions.md](issue-transitions.md)).

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
| User asked to run tests instead of agent | Phase 8 agentic validation — run Shell yourself |
| Full-stack only, no isolation proof | [feature-gating.md](feature-gating.md) in plan + slice |
| “Tests pass” with no command output | Evidence bundle in [verification.md](verification.md) |
| Duplicating review rules in handle-task | Link [quality-gate.md](review-ticket/quality-gate.md) only |
| `gh pr ready` without **`/code-review`** | Phase 9b gate |
| Treating author self-review as substitute for **`/code-review`** | Phase 9b vs [code-review.md](code-review.md) |
