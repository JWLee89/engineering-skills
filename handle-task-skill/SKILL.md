---
name: handle-task
description: >-
  Portable ticket-to-ship workflow: load .handle-task/project.yaml, fetch issue
  from JIRA/Linear/GitHub or user input, write local specs, maintain committed
  task memory, split oversized work, implement on ticket branches, verify locally,
  then hand off to /make-pull-request. Use when user gives a ticket ID, asks to
  handle a task, spec before code, or work a ticket/epic/story.
disable-model-invocation: true
---

# Handle task

End-to-end: **issue → spec → plan → implement → verify → hand off to PR skill**.

**Invoke:** `/handle-task`
**Companion:** `/make-pull-request` (after implementation)
**Agent entry:** [QUICKSTART.md](QUICKSTART.md)

Load **`.handle-task/project.yaml`** first ([project-config.md](project-config.md)).

| Phase                | Delegate to (standalone — in this bundle)                                                                 |
| -------------------- | --------------------------------------------------------------------------------------------------------- |
| Scope + spec         | [specify.md](specify.md) → [spec-driven-development.md](spec-driven-development.md)                       |
| Plan + tasks         | [plan-and-tasks.md](plan-and-tasks.md) → [planning-and-task-breakdown.md](planning-and-task-breakdown.md) |
| Coding slices        | [test-driven-development.md](test-driven-development.md) → [incremental-implementation.md](incremental-implementation.md) |
| Significant choices  | [documentation-and-adrs.md](documentation-and-adrs.md) → `memory.decisions` from config                   |
| Performance in scope | [performance-optimization.md](performance-optimization.md)                                                |
| Code review          | [code-review.md](code-review.md)                                                                          |
| PR + CI              | `/make-pull-request` → [make-pull-request/workflow.md](make-pull-request/workflow.md)                     |

______________________________________________________________________

## Artifact policy

| Artifact         | Typical path                                  | Commit?                 |
| ---------------- | --------------------------------------------- | ----------------------- |
| Spec, plan, todo | `memory.local_specs` (e.g. `tasks/`)          | **Never**               |
| Task scratchpad  | `memory.committed_tasks` (e.g. `.hac/tasks/`) | **Yes**                 |
| Status index     | `memory.status`                               | **Yes** when configured |
| Decisions log    | `memory.decisions`                            | **Yes** (append-only)   |

Detailed specs stay local; committed memory is **concise** (bullets + links).

______________________________________________________________________

## When to use

- User gives a ticket key (`PROJ-123`, `ENG-456`) or describes a task to implement
- Scope is growing — split issue or stack PRs
- Non-trivial change needs spec → plan → implement
- Resuming work — read task memory + status first

**Skip** for trivial one-file fixes.

______________________________________________________________________

## Workflow

```
INTAKE → [SPLIT?] → SPECIFY → SPEC APPROVAL → PLAN → PLAN APPROVAL → MEMORY → IMPLEMENT → VERIFY → /make-pull-request
```

Checklist:

```
- [ ] .handle-task/project.yaml loaded
- [ ] Issue fetched (tracker MCP, gh, or user text)
- [ ] Split decision recorded
- [ ] Spec written under local_specs (not committed)
- [ ] User approved spec
- [ ] Plan + todo written; user approved plan
- [ ] Committed task file + status updated
- [ ] Branch matches ticket.id_pattern from config
- [ ] Unassigned JIRA ticket assigned to current user (when applicable)
- [ ] Issue moved to in-progress (when status_transitions configured)
- [ ] Each behavioral slice: RED test → GREEN code → REFACTOR ([test-driven-development.md](test-driven-development.md))
- [ ] Implementation complete; local verify green
- [ ] User prompted for /make-pull-request
```

______________________________________________________________________

## Phase 1: Intake

1. **Fetch the issue** (use `integrations.issue_tracker.type` from config):

   - **jira** — Atlassian MCP: `jira_get_issue`, comments, dev links. If the issue has
     **no assignee**, assign it to the authenticated JIRA user (the person running the skill)
     via `jira_assign_issue` — see [issue-transitions.md](issue-transitions.md#unassigned-tickets-jira).
   - **github** — `gh issue view <num>`
   - **linear** — Linear MCP if available, else ask user
   - **none** — user provides summary + acceptance criteria in chat

2. **Read repo state:** `memory.status`, `memory.decisions`, `memory.agent_guide` (e.g. `CLAUDE.md`)

3. **Prior work:** committed task files, local specs, `gh pr list --search "<ticket-key>"`

4. **Record assumptions** ([spec-driven-development.md](spec-driven-development.md)) before writing.

**Base branch:** `git.default_base` from config.

______________________________________________________________________

## Phases 2–4: Specify

**Read [specify.md](specify.md)** — spec approval gate is a hard stop.

______________________________________________________________________

## Phase 3: Split decision

**Read [pr-splitting.md](pr-splitting.md)** when diff or scope exceeds reviewable size.

When splitting:

1. **Read [jira-subtask-template.md](jira-subtask-template.md)** — required subtask format
2. Create **real tracker subtasks** (JIRA Subtask or sibling Task under Epic) — each description
   **must** include: **Background**, **Description**, **Scope**, **DoD**, plus links to
   **Parent**, **Depends on**, **Blocks** when applicable
3. **Never** use synthetic branch names (`PROJ-100-a`, `PARENT-1`) — branch must equal the
   child ticket key (`PROJ-101`)
4. Link **Work item split** + **Blocks** chain; update parent description with subtask table
5. Implement `/handle-task` on each **child key** only — one PR per subtask

______________________________________________________________________

## Phase 5: Plan

**Read [plan-and-tasks.md](plan-and-tasks.md)** — plan approval gate is a hard stop.

______________________________________________________________________

## Phase 6: Committed task memory

After plan approval, create/update concise files at paths from config (e.g.
`.hac/tasks/<prefix>-<id>-<slug>.md`): metadata, plan checklist, session log.

Do **not** create task memory retroactively for finished work.

______________________________________________________________________

## Phase 7: Implement

1. Branch: `{ticket.id_pattern}` from config (e.g. `PROJ-123`)
2. **Issue transition:** apply `status_transitions.implementation_start` when configured
   ([issue-transitions.md](issue-transitions.md)) — e.g. JIRA `Assign` → In Progress
3. Execute each todo slice via [test-driven-development.md](test-driven-development.md) and
   [incremental-implementation.md](incremental-implementation.md)
4. Log decisions and session notes after each slice

**Implementation rules** (required — see delegates for detail):

- **TDD per slice** — for any behavior change: **write the failing test first (RED)**, then
  minimal code (GREEN), then refactor. Production code must be easy to **test, maintain,
  extend**, and **scale** — tests prove each slice before moving on.
- **DRY / reuse** — search the codebase first. If an existing function already does what
  you need, use it. If it is close, extend or parameterize it. **Do not reinvent the wheel**
  — when another module already implements the same functionality, call or extend it.
- **SOLID** — follow [SOLID](https://www.digitalocean.com/community/conceptual-articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design)
  as practical guardrails: one reason to change per unit (SRP), extend without modifying
  stable code (OCP), honor substitutability (LSP), narrow interfaces (ISP), depend on
  abstractions at boundaries (DIP).
- **REUSE CHECK** — before each slice (before RED), state what existing code you considered
  and whether you reuse, extend, or add new code (log non-obvious forks in `memory.decisions`).

**Commits:** code, tests, committed memory, docs — never local specs. Commit when user asks
or when preparing PR. Never commit secrets.

**After commits:** run Phase 8, then **ask** before `/make-pull-request`.

______________________________________________________________________

## Phase 8: Verify

**Read [verification.md](verification.md)** — use `verify.commands` from config.

Document CI-only gaps for the PR skill; do not skip listing them.

______________________________________________________________________

## Phase 9: Pull request

Do **not** open PRs inside this skill. Prompt user, then run **`/make-pull-request`**
([make-pull-request.md](make-pull-request.md)).

______________________________________________________________________

## Anti-patterns

| Mistake                        | Fix                                             |
| ------------------------------ | ----------------------------------------------- |
| Hardcoding ticket prefix in paths | Use `ticket.prefix` and paths from config    |
| Assuming JIRA                  | Read `issue_tracker.type` from config           |
| Committing local specs         | Keep under `memory.local_specs` only            |
| Code before spec/plan approval | Stop at gates in specify.md / plan-and-tasks.md |
| Opening PR without user OK     | Ask; use `/make-pull-request`                   |
| Reimplementing existing helpers | Search first; reuse or extend ([incremental-implementation.md](incremental-implementation.md)) |
| Production code before tests | TDD: RED → GREEN per slice ([test-driven-development.md](test-driven-development.md)) |
| Monolithic classes/functions mixing concerns | Split by responsibility; one reason to change per unit (SRP) |

______________________________________________________________________

## Resources

- [QUICKSTART.md](QUICKSTART.md) — invocation + file map
- [project-config.md](project-config.md) — `.handle-task/project.yaml` schema
- [templates.md](templates.md) — spec, plan, PR templates
- [verification.md](verification.md) — verify commands
- [make-pull-request.md](make-pull-request.md) — PR phase pointer
- [issue-transitions.md](issue-transitions.md) — JIRA/status workflow
- [jira-subtask-template.md](jira-subtask-template.md) — split subtask format (Background, Description, Scope, DoD)
- [pr-splitting.md](pr-splitting.md) — split heuristics + stacked PRs
- **Delegates:** [spec-driven-development.md](spec-driven-development.md),
  [planning-and-task-breakdown.md](planning-and-task-breakdown.md),
  [test-driven-development.md](test-driven-development.md),
  [incremental-implementation.md](incremental-implementation.md),
  [documentation-and-adrs.md](documentation-and-adrs.md),
  [code-review.md](code-review.md),
  [performance-optimization.md](performance-optimization.md)
