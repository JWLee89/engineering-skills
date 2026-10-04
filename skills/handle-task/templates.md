# Handle task templates

Copy and fill. Save under `memory.local_specs` from config (e.g. `tasks/`) — **never commit**.

**Path convention:** lowercase ticket key in filenames — `proj-123` for `PROJ-123`.  
Load `ticket.prefix`, `git.default_base`, and `integrations.issue_tracker.url_template` from
[project-config.md](project-config.md).

| Workflow step | Reference |
| ------------- | --------- |
| Spec + approval gate | [specify.md](specify.md) |
| Plan + todo + approval gate | [plan-and-tasks.md](plan-and-tasks.md) |
| PR lifecycle | [../pull-request/workflow.md](../pull-request/workflow.md) |
| Subtask (tracker) | [subtask-template.md](subtask-template.md) |
| PR body shape | [../pull-request/references/reviewer-friendly-pr-body.md](../pull-request/references/reviewer-friendly-pr-body.md) |

**Deep templates** live under [references/templates/](references/templates/) — load **one** file for the current phase.

______________________________________________________________________

## Subtask description (tracker — not a local file)

When splitting a parent ticket, create **real child issues**. Each description needs Background,
Description, Scope, DoD, Verification plan, and Parent/Depends/Blocks links. Branch = child key.

Full template: [subtask-template.md](subtask-template.md)

______________________________________________________________________

## Spec (`{local_specs}/<ticket_key_lower>/SPEC-<slug>.md`)

Used during Phase 2–4 — see [specify.md](specify.md).

**Full copy-paste template:** [references/templates/spec.md](references/templates/spec.md)

______________________________________________________________________

## Capability map (`{local_specs}/<ticket_key_lower>/CAPABILITY-MAP.md`)

Multi-module specs only — see [specify.md](specify.md#phase-2-scope-check-multi-capability).

**Template:** [references/templates/capability-map.md](references/templates/capability-map.md)

______________________________________________________________________

## Plan (`{local_specs}/plan-<ticket_key_lower>.md`)

After **spec approval** — [plan-and-tasks.md](plan-and-tasks.md).

**Template:** [references/templates/plan.md](references/templates/plan.md)

______________________________________________________________________

## Todo (`{local_specs}/todo-<ticket_key_lower>.md`)

Written with the plan, before **plan approval**.

**Template:** [references/templates/todo.md](references/templates/todo.md)

______________________________________________________________________

## Committed task memory (`{memory.committed_tasks}/<ticket_key_lower>-<slug>.md`)

Short scratchpad — link local spec; skip when `memory.committed_tasks` is `null`.

**Template:** [references/templates/task-memory.md](references/templates/task-memory.md)

______________________________________________________________________

## Verification plan (PR body)

Phase 2 of [pull-request.md](pull-request.md) / `/pull-request`. Required under `## Verification`.

**Template:** [references/templates/verification-pr-body.md](references/templates/verification-pr-body.md)

______________________________________________________________________

## Draft PR title and body

After verify — `gh pr create --draft`. Reviewer-friendly body required.

**Template:** [references/templates/draft-pr.md](references/templates/draft-pr.md)

______________________________________________________________________

## Decision entry (`{memory.decisions}`) — append-only

See [documentation-and-adrs.md](documentation-and-adrs.md).

**Template:** [references/templates/decision-entry.md](references/templates/decision-entry.md)
