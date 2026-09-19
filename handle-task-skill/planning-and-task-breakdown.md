# Planning and task breakdown

Standalone delegate for `/handle-task`. Local paths and the plan approval gate live in
[plan-and-tasks.md](plan-and-tasks.md).

## When to use

- Approved spec exists
- Work spans multiple files or sessions
- Implementation order is not obvious

## Planning process (read-only)

1. Read approved spec + relevant codebase — **no code yet**
2. Map dependency graph (foundations before dependents)
3. Prefer **vertical slices** (end-to-end paths) over horizontal layers
4. Size tasks: ≤ ~5 files, one focused session each
5. Write `plan-<ticket_key_lower>.md` and `todo-<ticket_key_lower>.md` under `memory.local_specs`

## Task shape

Each todo item includes:

- Acceptance criteria (testable)
- **Tests first** — expected test file(s) and cases before production files ([test-driven-development.md](test-driven-development.md))
- Verify command from [verification.md](verification.md) / project config
- Files expected to touch (test paths listed before implementation paths)
- Dependencies on prior tasks

## Reuse discovery (before planning new modules)

During planning, search for existing code to extend:

- Similar tasks, protocols, entities, or test helpers in the same product area
- Shared utilities under `core/`, `common/`, or product `entities/`
- YAML/config patterns already used for the same concern

Prefer **extend existing** over **add parallel implementation**. If a new abstraction
is needed, name it in the plan with rationale (see [incremental-implementation.md](incremental-implementation.md)).

## Slicing preference

```
Good:  schema + API + UI for "create task" → verify → next slice
Bad:   all schema → all API → all UI → integrate at end
```

## Anti-patterns

- Planning before spec approval
- Tasks without verify commands
- Todo items that list only production files — add test-first steps for behavioral slices
- Horizontal "build all X then all Y" when vertical slices are possible
