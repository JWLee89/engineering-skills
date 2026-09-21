# Ticket quality gate (four-point review)

Shared by **`/review-ticket`**, **`/create-ticket`** (after creation), and
**`/handle-task`** (at intake, Phase 1). A ticket that fails any check is **not**
ready to implement — the agent asks clarifying questions, backfills the ticket,
and confirms with the caller before proceeding.

This is the single source of truth for the review. Do not duplicate the criteria
elsewhere — link here.

______________________________________________________________________

## The four checks

| # | Check | Pass when… | Fail action |
|---|-------|-----------|-------------|
| 1 | **Enough background** | An assignee with no prior context can start the task from the ticket alone — repo/module, related tickets, constraints, and baseline state are all present. | Ask for the missing context; backfill **Background**. |
| 2 | **Well-defined scope** | The task fits one reviewable unit (see heuristics below). Not ambiguous about what's in vs. out. | If too big → **split into sub-tasks** (approval-first). If ambiguous → backfill **Scope**. |
| 3 | **Definition of done clear** | The DoD is a testable checklist and the steps required to handle the task are explicit. Each DoD item is observable. | Ask what "done" looks like; backfill **DoD** + required steps. |
| 4 | **Onboarder-readable** | A new onboarder could read the ticket, figure out exactly what to do, and complete it. The **Description** is in layman terms; jargon is glossed; acronyms linked. | Ask the user to rephrase; backfill **Description**. |

______________________________________________________________________

## Required description sections

Every ticket reviewed or created by these skills should include:

| Section | Purpose |
| ------- | ------- |
| **Background** | Why this ticket exists; linked parent/epic/blockers; baseline state. |
| **Description** | What needs to be done, **in layman terms** — for agents and humans. Git branch: `{TICKET-KEY}`. |
| **Scope** | In scope / out of scope table. |
| **DoD (Definition of Done)** | Testable checklist; PR merge target. |
| **Verification plan** | How the implementer verifies success — each DoD item maps to a command, CI run, or manual step. |

Template: [../create-ticket/ticket-template.md](../create-ticket/ticket-template.md).

Reference shapes (structure, not copy-paste):

- **Background / context** — explains *why* the task exists; links related work and constraints
- **Detailed steps** — concrete commands, settings, and file paths
- **End-to-end ops ticket** — background, numbered steps, observable DoD

______________________________________________________________________

## Scope heuristics (check 2)

A ticket is "too big" when it would produce a PR that is not cleanly reviewable. Signals:

- Likely > ~500 lines changed or > ~15 files (see [../pr-splitting.md](../pr-splitting.md)).
- Spans more than one independently testable capability.
- Multiple DoD items that could each be their own merged PR.
- Description lists several distinct "and also" tasks.

When too big → **split**, do not just shrink the description.

______________________________________________________________________

## Split into sub-tasks (check 2 failure)

Follow [../subtask-template.md](../subtask-template.md). **Approval-first — never auto-create.**

1. **Propose** the split (subtask list, merge order, first implement key) to the user —
   as a comment on the parent or in chat.
2. Wait for **explicit approval**.
3. Create one **real** child ticket per slice via the issue tracker adapter
   ([../issue-tracker-adapters.md](../issue-tracker-adapters.md)).
   Each child keeps all required sections.
4. Link parent ↔ children and document merge order (Blocks chain on JIRA; equivalent on other trackers).
5. Update the parent: subtask table, rollup DoD, rollup verification plan, and a note:
   "implement on child keys only."
6. Re-run this gate on each child.

Never use synthetic branch names (`PROJ-100-a`). Branch = real child ticket key.

______________________________________________________________________

## Backfill procedure (checks 1, 3, 4 failure)

1. **Ask clarifying questions** — numbered, specific, one per gap. Examples:
   - "Which repo/module does this touch? The ticket doesn't say." (check 1)
   - "What does 'done' look like? There's no observable check." (check 3)
   - "A new hire wouldn't know what 'OAuth token refresh flow' means — can you rephrase the
     goal?" (check 4)
2. On the user's reply, **backfill** the ticket description via the tracker adapter
   ([../issue-tracker-adapters.md](../issue-tracker-adapters.md)), preserving all required
   sections ([../create-ticket/ticket-template.md](../create-ticket/ticket-template.md)).
3. **Confirm** with the caller: re-state what was added and re-run the four checks. Do not
   mark the ticket ready until the user confirms.
4. If the user declines to backfill a gap, record it as an explicit assumption/limitation
   in the ticket **and** surface it to the user — never silently ship an
   under-documented ticket.

______________________________________________________________________

## Reporting

Present the review as a four-row table:

```markdown
| # | Check | Result | Evidence / gap |
|---|-------|--------|----------------|
| 1 | Enough background | ✅ / ❌ | <one line> |
| 2 | Well-defined scope | ✅ / ❌ | <one line; if ❌ → split proposed> |
| 3 | DoD clear | ✅ / ❌ | <one line> |
| 4 | Onboarder-readable | ✅ / ❌ | <one line> |
```

Only when all four pass (or gaps are explicitly accepted by the user) is the ticket ready.

______________________________________________________________________

## Where this runs

| Skill | When |
| ----- | ---- |
| `/review-ticket` | Primary — review existing ticket; backfill; split proposal |
| `/create-ticket` | After ticket creation (and after any split/backfill on children) |
| `/handle-task` | Phase 1 intake — gate must pass before spec/plan |

`/handle-task` and `/create-ticket` link here instead of restating the criteria.

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
|---------|-----|
| Proceeding to implement a ticket that fails the gate | Stop; run `/review-ticket` or backfill first |
| Auto-creating sub-tasks without approval | Approval-first split |
| Restating the four checks elsewhere | Link this file ([../self-improvement.md](../self-improvement.md)) |
| Silently accepting a gap the user didn't acknowledge | Record as explicit assumption + surface it |
| Skipping the review because "it looks fine" | Mandatory for every created or fetched ticket |
