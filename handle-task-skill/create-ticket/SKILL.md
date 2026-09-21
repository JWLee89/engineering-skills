---
name: create-ticket
description: >-
  Create well-documented tracker tickets by combining context from related tickets,
  user-supplied context banks, wiki/docs, and skill memory. Each ticket includes a
  layman-terms Description and a detailed Verification plan, then passes the four-point
  quality review via /review-ticket. Works with JIRA, Linear, GitHub Issues, or manual
  creation. Use when the user asks to create, draft, or write a ticket from a brief.
disable-model-invocation: true
---

# Create ticket

**Invoke:** `/create-ticket` · **Companions:** `/review-ticket`, `/handle-task` ·
**Entry:** read [workflow.md](workflow.md) in full.

Load **`.handle-task/project.yaml`** first — schema in
[../project-config.md](../project-config.md).

```
INTAKE CONTEXT → DRAFT → CREATE → /review-ticket → [SPLIT?] → CONFIRM
```

## Single source of truth

This folder lives inside `handle-task-skill/`. Edits apply globally via
`../scripts/install-skills.sh`.

## What this skill does

1. **Gather context** from a flexible mix — related tickets (via adapter), pasted briefs,
   local files, wiki links, and skill/repo memory — until enough to write a complete ticket.
2. **Draft** a ticket whose description has all required sections, including **Description**
   in layman terms and a detailed **Verification plan**
   ([ticket-template.md](ticket-template.md)).
3. **Create** the ticket via the issue tracker adapter
   ([../issue-tracker-adapters.md](../issue-tracker-adapters.md)).
4. **Review** — run `/review-ticket` (or inline [../review-ticket/quality-gate.md](../review-ticket/quality-gate.md))
   on the created ticket.
5. If too big, **propose sub-task split** (approval-first) per
   [../subtask-template.md](../subtask-template.md).
6. If any quality check fails, **ask clarifying questions**, backfill, and confirm.

## Required description sections

| Section | Purpose |
| ------- | ------- |
| **Background** | Why this ticket exists; linked parent/epic/blockers; baseline state. |
| **Description** | What needs to be done, **in layman terms** — for agents and humans. Git branch: `{TICKET-KEY}`. |
| **Scope** | In scope / out of scope table. |
| **DoD (Definition of Done)** | Testable checklist; PR merge target. |
| **Verification plan** | How the implementer verifies success — executable checks for every DoD item. |

Full template: [ticket-template.md](ticket-template.md).

## Boundaries

- **Always:** Description + Verification plan; ask when context is thin; run quality review
  after creation; branch = real ticket key.
- **Never:** create without required sections; skip review; auto-create sub-tasks; invent
  ticket keys or assignees.
- **Ask first:** issue type, assignee, epic/parent link, splitting into sub-tasks.

## See also

- [workflow.md](workflow.md) — full phase workflow
- [ticket-template.md](ticket-template.md) — required sections + field guidance
- [../review-ticket/quality-gate.md](../review-ticket/quality-gate.md) — four-point review
- [../issue-tracker-adapters.md](../issue-tracker-adapters.md) — create/update by tracker type
- [../subtask-template.md](../subtask-template.md) — sub-task split conventions
