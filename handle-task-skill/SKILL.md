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
| Coding slices        | [incremental-implementation.md](incremental-implementation.md)                                            |
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

When splitting: create **tracker subtasks** (each with Background, Scope, DoD, Verification plan),
update the parent description, link with **Work item split** + **Blocks** (JIRA) — then implement
`/handle-task` on each **subtask key** (e.g. `PROJ-101`), not synthetic branch suffixes (`PROJ-100-a`).

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
3. Execute local todo via [incremental-implementation.md](incremental-implementation.md)
4. Test after each slice; log decisions and session notes

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

______________________________________________________________________

## Resources

- [QUICKSTART.md](QUICKSTART.md) — invocation + file map
- [project-config.md](project-config.md) — `.handle-task/project.yaml` schema
- [templates.md](templates.md) — spec, plan, PR templates
- [verification.md](verification.md) — verify commands
- [make-pull-request.md](make-pull-request.md) — PR phase pointer
- [issue-transitions.md](issue-transitions.md) — JIRA/status workflow
- **Delegates:** [spec-driven-development.md](spec-driven-development.md),
  [planning-and-task-breakdown.md](planning-and-task-breakdown.md),
  [incremental-implementation.md](incremental-implementation.md),
  [documentation-and-adrs.md](documentation-and-adrs.md),
  [code-review.md](code-review.md),
  [performance-optimization.md](performance-optimization.md)
