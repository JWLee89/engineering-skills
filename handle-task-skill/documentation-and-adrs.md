# Documentation and ADRs

Standalone delegate for `/handle-task` and `/make-pull-request`. Records **why**, not
just what.

## When to use

- Architectural or protocol choices
- Reuse vs new abstraction decisions ([incremental-implementation.md](incremental-implementation.md))
- Public API or wire-format changes
- PR feedback that changes design direction

**Skip:** obvious one-liners; comments that restate the code.

## Match repo convention first

Read `memory.decisions`, `docs/decisions/`, or any path configured in
`.handle-task/project.yaml` before adding entries. Follow existing table/format — do not
introduce a second ADR scheme.

When `memory.decisions` is set in config, append there (typically newest-first).

## What to document

| Document           | Capture                                              |
| ------------------ | ---------------------------------------------------- |
| ADR / decision row | Context, choice, alternatives rejected, consequences |
| Inline comment     | Non-obvious *why* only                               |
| Spec / HAC task    | Links to decisions; keep scratchpad concise          |
| PR body            | Verification evidence, not full spec paste           |

## Implementation design (document when non-obvious)

Optimize for **clean, maintainable, testable** code. Before adding:

1. Search for existing helpers, types, and tests to reuse
2. Prefer extending existing code over parallel implementations
3. Introduce abstractions only when they reduce duplication *and* improve clarity

When the fork matters for long-term maintenance, record briefly:

- What existing code was considered
- Why extend / reuse / abstract / rewrite
- Trade-off (maintenance, test surface, coupling)

This prevents the next agent from re-debating the same fork. Full principles also live in
the user-level `documentation-and-adrs` skill; this file is the handle-task delegate.

## ADR template (when no repo format exists)

```markdown
## [Date] — [Short title]

**Context:** …
**Decision:** …
**Alternatives:** … (why rejected)
**Consequences:** …
```

## Schema and wire formats

- Prefer model field names as wire keys; use `asdict()` / `fields(Model)` in tests
- Named mapping dicts only when internal and external names intentionally differ
- One canonical list for path rules, constants, or enums — generate consumers when needed

## Anti-patterns

- Comments that narrate obvious code
- Duplicated field lists in model, serializer, and tests
- Retroactive task files for completed work
- Committing local `tasks/` specs
