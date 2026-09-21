# Handle task templates

Copy and fill. Save under `memory.local_specs` from config (e.g. `tasks/`) — never commit.

**Path convention:** use lowercase ticket key in filenames — `proj-123` for `PROJ-123`.
Load `ticket.prefix`, `git.default_base`, and `integrations.issue_tracker.url_template`
from `.handle-task/project.yaml`. Expand `{key}` in URLs (e.g. `PROJ-123`).

| Workflow step                | Reference                                                      |
| ---------------------------- | -------------------------------------------------------------- |
| Spec writing + approval gate | [specify.md](specify.md)                                       |
| Plan + todo + approval gate  | [plan-and-tasks.md](plan-and-tasks.md)                         |
| Draft PR → merge-ready       | [make-pull-request/workflow.md](make-pull-request/workflow.md) |
| Project settings             | [project-config.md](project-config.md)                         |
| Subtask (split work)         | [subtask-template.md](subtask-template.md)                       |

______________________________________________________________________

## Subtask description (tracker — not a local file)

When splitting a parent ticket, create **real child issues** in your tracker. Each
description must include **Background**, **Description**, **Scope**, **DoD**, and
**Verification plan**, plus links to Parent / Depends on / Blocks.

**Do not** use synthetic branch names — branch must equal the child ticket key.

Full template: [subtask-template.md](subtask-template.md)

______________________________________________________________________

## Spec (`{local_specs}/<ticket_key_lower>/SPEC-<slug>.md`)

Used during Phase 2–4 — see [specify.md](specify.md).

````markdown
# Spec: <title> ({TICKET-KEY})

**Issue:** [{TICKET-KEY}](<url from url_template>)
**Parent / epic:** <link or —>
**Branch:** `{TICKET-KEY}` (base: `<git.default_base>`)
**Capability map:** `{local_specs}/<ticket_key_lower>/CAPABILITY-MAP.md` (if applicable)

---

## Assumptions I'm Making

1. ...
2. ...

→ Correct me now or implementation proceeds with these.

---

## Objective

<What and why. User stories or acceptance criteria from the tracker, refined.>

### Success criteria

- [ ] <testable condition>
- [ ] <testable condition>

---

## Current state

<Relevant files, data flow, existing behavior — from codebase reading.>

---

## Tech stack / scope boundary

| In scope | Out of scope |
|----------|--------------|
| ... | ... |

---

## Commands

```bash
# From repo root — use real commands from verify.commands in config
npm test
npm run lint
# or: make test-unit, pytest, etc.
````

______________________________________________________________________

## Project structure (expected changes)

| File            | Action          |
| --------------- | --------------- |
| `src/...`       | Create / modify |

______________________________________________________________________

## Testing strategy

- Unit: `tests/unit/...` or equivalent
- Integration: note CI-only deps if any
- Manual / smoke: ...

______________________________________________________________________

## Boundaries

- **Always:** Run scoped tests before PR; match existing patterns in adjacent modules
- **Ask first:** New deps, CI changes, schema/API contract edits
- **Never:** Commit local specs; commit secrets; remove failing tests without approval

______________________________________________________________________

## Open questions

| Question | Owner | Status |
| -------- | ----- | ------ |
| ...      | ...   | open   |

______________________________________________________________________

## Risks

| Risk | Mitigation |
| ---- | ---------- |
| ...  | ...        |

````

---

## Capability map (`{local_specs}/<ticket_key_lower>/CAPABILITY-MAP.md`)

```markdown
# Capability Map: {TICKET-KEY} — <initiative name>

**Issue:** [{TICKET-KEY}](<url from url_template>)

| Module id | Responsibility | Tracker subtask | Depends on |
|-----------|----------------|-----------------|------------|
| scaffolding | Module scaffold | PROJ-XXX | — |
| core | Core logic | PROJ-YYY | scaffolding |

**Build order:** scaffolding → core → ...

Each module gets its own `SPEC-<module-id>.md` and (usually) its own PR.
````

______________________________________________________________________

## Plan (`{local_specs}/plan-<ticket_key_lower>.md`)

Written after **spec approval** — see [plan-and-tasks.md](plan-and-tasks.md).

```markdown
# Implementation Plan: {TICKET-KEY}

**Spec:** `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md`
**Tasks:** `{local_specs}/todo-<ticket_key_lower>.md`

## Overview

<One paragraph approach.>

## Verified findings

1. ...

## Architecture decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| ... | ... | ... |

## Implementation order

```

1. ...
2. ...

```

## Files changed (expected)

| File | Action |
|------|--------|

## Verification checkpoints

| After | Command |
|-------|---------|
| Phase 1 | `<from verify.commands>` |

## Out of scope

- ...
```

______________________________________________________________________

## Todo (`{local_specs}/todo-<ticket_key_lower>.md`)

Written with the plan, before **plan approval** — see [plan-and-tasks.md](plan-and-tasks.md).

```markdown
# Tasks: {TICKET-KEY} — <short title>

**Spec:** `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md`
**Plan:** `{local_specs}/plan-<ticket_key_lower>.md`

---

## Phase 0: ...

- [ ] **Task N: <name>**
  - Acceptance: ...
  - Spec: satisfies `<success criterion # or scenario>`
  - TDD: RED in `<test file>` → GREEN in `<production file(s)>`
  - Spec adhere: matrix row ✅ for this slice
  - Verify: `<scoped test command>`

---

## Plan approval gate

Do not start committed memory setup or implementation until the user explicitly approves this
plan and todo. See [plan-and-tasks.md](plan-and-tasks.md#plan-approval-gate-hard-stop).
```

______________________________________________________________________

## Committed task memory (`{memory.committed_tasks}/<ticket_key_lower>-<slug>.md`)

Keep this **short**. Link to local spec path; do not duplicate full spec.
Skip this section when `memory.committed_tasks` is `null` in config.

```markdown
# {TICKET-KEY} — <short title>

| Field | Value |
|-------|-------|
| **Status** | Active |
| **Priority** | P1 |
| **Owner** | @... |
| **Issue** | [{TICKET-KEY}](<url from url_template>) |
| **Branch** | `{TICKET-KEY}` |
| **Local spec** | `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md` (not committed) |

## Plan

- [ ] ...

## Notes / Findings

- ...

## Session Log

- **YYYY-MM-DD:** ...
```

______________________________________________________________________

## Verification plan (PR body)

Build in Phase 2 of [make-pull-request.md](make-pull-request.md). Three subsections are
**required** under `## Verification`:

### Steps run (author)

Checkboxes for commands the agent runs locally before/during PR iteration:

```markdown
### Steps run (author)

- [ ] `<verify.hooks or scoped lint>` — ...
- [ ] `<verify.commands[0]>` — ...
- [ ] Scoped tests — `<command>`
```

When a step passes, check it and add evidence: *passed locally* or a CI run link.

### Test plan (reviewer / CI)

Items that need GitHub Actions or branch-level proof:

```markdown
### Test plan (reviewer / CI)

- [ ] **CI** workflow green — <name from verify.ci_workflows>
- [ ] <scenario> — [run ID](https://github.com/org/repo/actions/runs/...) (after verification commit)
```

Use **verification commits** (Phase 5b) when behavior only shows on a follow-up push.

### Out of scope

```markdown
### Out of scope

- <deferred ticket or workflow>
- <explicit non-goals from spec>
```

______________________________________________________________________

## Draft PR title

Expand `pr.title_format` from `.handle-task/project.yaml`:

```
[{prefix}-{number}]({tag}): {summary}
```

Example: `[PROJ-42](feat): Add user authentication endpoint`

| Part        | Rule                                                             |
| ----------- | ---------------------------------------------------------------- |
| `{tag}`     | Primary semantic type (`commit.tags`: `feat`, `fix`, `chore`, …) |
| `{summary}` | What the PR delivers — not the full issue title                   |

PR titles use a colon after `({tag})`. Commits use a space: `[PROJ-42](feat) Summary`.

______________________________________________________________________

## Draft PR body (local — not committed)

Use after commits + verify, when the user approves opening a PR. **Always** create with
`gh pr create --draft`. Full workflow: [make-pull-request.md](make-pull-request.md).

```markdown
## Background

<Problem space and ticket context. Link parent epic or blocking tickets if relevant.
Mention constraints from committed decision log when configured.>

- Issue: [{TICKET-KEY}](<url from url_template>)
- Task memory: `{memory.committed_tasks}/<ticket_key_lower>-<slug>.md` (if configured)
- Local spec: `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md` (not committed)

## Purpose

<Single clear statement of what this PR delivers and why now.>

## Changes made

- <Grouped bullet: e.g. "Add auth middleware — JWT validation on protected routes">
- <Grouped bullet: tests, docs, task memory updates>
- <Explicit "not in this PR" only under Verification → Out of scope>

## Verification

### Steps run (author)

- [ ] `<commands from verify.commands>`

### Test plan (reviewer / CI)

- [ ] Reviewer: smoke steps if any manual checks apply
- [ ] CI: <workflow name> — especially for tests not runnable locally

### Out of scope

- <Follow-up ticket or deferred wiring>
```

**Agent prompt after commit (copy/adapt):**

> Commits for {TICKET-KEY} are on branch `{TICKET-KEY}`. Verify: \[passed commands\].
> Gaps: \[CI-only tests\]. Should I run `/make-pull-request` (draft PR + verification plan +
> CI watch)?

**Agent prompt at finalize (copy/adapt):**

> CI green on run \[link\]. Code review pass complete. Updating PR description, marking
> ready for review, and transitioning issue to ready-for-review (per
> `status_transitions.pr_ready` in config).

______________________________________________________________________

## Decision entry (`{memory.decisions}`) — append-only

Add a row to the quick-reference table **and** a detailed entry below (newest first).
Follow [documentation-and-adrs.md](documentation-and-adrs.md) and match the repo's existing format.

```markdown
| YYYY-MM-DD | <short decision> ({TICKET-KEY}) | <choice> | <impact> |
```

Detailed section:

```markdown
### YYYY-MM-DD — <title> ({TICKET-KEY})

- **Context:** ...
- **Decision:** ...
- **Alternatives considered:** ...
- **Impact:** ...
```
