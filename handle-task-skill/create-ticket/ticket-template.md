# Ticket template (create-ticket)

Every ticket created by `/create-ticket` uses this description. All sections are
**required**. Expand placeholders from `.handle-task/project.yaml`:
`{prefix}`, `{TICKET-KEY}`, `{git.default_base}`, `{git.pr_target}`, `url_template` (`{key}`).

Portable across JIRA, Linear, GitHub Issues, and other trackers — apply via the adapter
in [../issue-tracker-adapters.md](../issue-tracker-adapters.md).

______________________________________________________________________

## Description body (copy per ticket)

```markdown
**Parent / Epic:** [{PARENT-KEY}]({url_template})   ← omit if none
**Depends on:** [{BLOCKER-KEY}]({url_template})   ← omit if none
**Blocks:** [{BLOCKED-KEY}]({url_template})   ← omit if none

---

## Background

<Why this ticket exists. Link related tickets, prior merged work, and constraints from
decisions/specs. Include baseline repo state, metrics, or versions the implementer needs.
Written so an assignee with no prior context understands the situation.>

Source context: <list tickets / context banks / files used to draft this>

---

## Description

<What needs to be done, **in layman terms** — readable by both agents and humans. Name
concrete files, modules, or workflow steps. Avoid unexplained jargon; gloss acronyms in
one line. State the git branch explicitly: `{TICKET-KEY}` (base: `{git.default_base}`).>

---

## Scope

| In scope | Out of scope |
|----------|--------------|
| ... | ... |

---

## DoD (Definition of Done)

- [ ] <testable checklist item>
- [ ] <testable checklist item>
- [ ] PR merged to `{git.pr_target}` on branch `{TICKET-KEY}`
```

______________________________________________________________________

## Verification plan section (append to the body above)

The Verification plan is a **required** block. It tells the person or agent implementing
the ticket exactly how to verify success — every DoD item maps to a concrete, executable check.

```markdown
---

## Verification plan

How the implementer (person or agent) confirms the task was handled successfully. Each
item must map to a command, CI workflow, or explicit manual step.

### Steps run (author)

- [ ] `<scoped lint / verify.hooks>` — <what passing proves>
- [ ] `<verify.commands[0]>` — <what passing proves>
- [ ] Scoped tests — `<command>` — covers <DoD item #>

### Test plan (reviewer / CI)

- [ ] **CI** workflow green — <name from verify.ci_workflows>
- [ ] <scenario> — <how to observe it; CI run link after verification>

### Manual / smoke (if any)

- [ ] <step> — <expected observation>

### Out of scope

- <deferred ticket or explicit non-goal>
```

______________________________________________________________________

## Summary line pattern

```
[{area}] {imperative title}
```

Example: `[API] Add pagination to the user list endpoint`

For subtasks under a parent, append the ordinal:

```
[{area}] {imperative title} ({PARENT-KEY} / {n})
```

______________________________________________________________________

## Field guidance (by tracker)

See [../issue-tracker-adapters.md](../issue-tracker-adapters.md) for create/update APIs.

| Field | Guidance |
| ----- | -------- |
| Project / repo | From `ticket.prefix` or user input |
| Issue type | Ask user if not obvious |
| Summary | Pattern above |
| Description | Full markdown body (Background → Verification plan) |
| Assignee | Only if user specifies |
| Parent / epic | Only if user confirms |

______________________________________________________________________

## Quality gate (after creation)

Every created ticket is reviewed via `/review-ticket` against
[../review-ticket/quality-gate.md](../review-ticket/quality-gate.md).

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
|---------|-----|
| Missing Description or Verification plan | Both required — do not create without them |
| Description full of unexplained jargon | Rewrite in layman terms |
| Verification plan with no executable checks | Every DoD item → command / CI / manual step |
| Copying a source ticket's body | Link the source; write fresh Description |
| Inventing assignee or epic | Leave blank unless user specifies |
