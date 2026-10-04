---
name: review-ticket
version: "1.0.0"
domain: workflow
role: analyst
scope: issue-tracker
triggers:
  - /review-ticket
  - review ticket
  - ticket quality
related-skills:
  - handle-task
  - create-ticket
description: >-
  Review and improve existing tracker tickets for onboarder-readability, scope,
  background, and definition of done. Runs the four-point quality gate, asks
  clarifying questions, backfills descriptions, and proposes sub-task splits when
  work is too large. Works with any configured issue tracker or pasted content.
  Use when the user asks to review, improve, or quality-check a ticket, or when
  /handle-task intake finds an under-documented ticket.
disable-model-invocation: true
---

# Review ticket

**Invoke:** `/review-ticket` · **Companions:** `/handle-task`, `/create-ticket` ·
**Entry:** read [workflow.md](workflow.md) in full.

Load **`.handle-task/project.yaml`** first — schema in
[../project-config.md](../handle-task/project-config.md).

```
LOAD CONFIG → FETCH TICKET → FOUR-POINT REVIEW → [SPLIT?] → BACKFILL → CONFIRM
```

## Single source of truth

Canonical path: `skills/review-ticket/`. Edits apply globally via
`../scripts/install-skills.sh`.

## What this skill does

1. **Fetch** the ticket via the issue tracker adapter
   ([../issue-tracker-adapters.md](../handle-task/issue-tracker-adapters.md)) or user-pasted content.
2. **Review** against the four-point quality gate ([quality-gate.md](quality-gate.md)):
   - Enough background for the assignee?
   - Well-defined scope? (too big → propose sub-tasks)
   - Definition of done and required steps clear?
   - Can a new onboarder complete the task from the ticket alone?
3. **Ask clarifying questions** for any gap — do not guess.
4. **Backfill** the ticket description (via adapter or user-applied paste).
5. **Propose splits** when scope is too large — approval-first, real child tickets only
   ([../subtask-template.md](../handle-task/subtask-template.md)).
6. **Confirm** with the caller before declaring the ticket ready.

## Invoked from other skills

| Caller | When |
| ------ | ---- |
| `/handle-task` | **Phase 1 — mandatory** for every external tracker issue; do not substitute an inline review |
| `/create-ticket` | After creating a ticket — mandatory quality pass |

When invoked standalone, the user provides a ticket key/number or pastes the full description.

## Boundaries

- **Always:** run all four checks; report pass/fail table; preserve required sections
  when backfilling ([../create-ticket/ticket-template.md](../create-ticket/ticket-template.md)).
- **Never:** proceed to implementation on a failing ticket; auto-create sub-tasks without approval;
  duplicate quality criteria outside [quality-gate.md](quality-gate.md).
- **Ask first:** splitting a ticket; accepting unresolved gaps as assumptions.

## See also

- [workflow.md](workflow.md) — phase workflow
- [quality-gate.md](quality-gate.md) — four-point review (single source of truth)
- [../issue-tracker-adapters.md](../handle-task/issue-tracker-adapters.md) — fetch / update by tracker type
- [../subtask-template.md](../handle-task/subtask-template.md) — sub-task split conventions
