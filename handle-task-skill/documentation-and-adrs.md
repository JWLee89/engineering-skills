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

Optimize for **clean, maintainable, testable, extensible** code — the same bar as
[incremental-implementation.md](incremental-implementation.md) Phase 7.

### DRY — don't reinvent

Before adding code:

1. **Search** for existing helpers, types, tasks, protocols, and tests
2. **Reuse as-is** when an existing function already does what you need
3. **Extend or parameterize** when it almost fits and both cases stay readable
4. **Add new code only** when reuse fails — record what you searched and why

### SOLID — practical guardrails

| Capture in ADR when it affects maintenance | Example |
| ------------------------------------------ | ------- |
| Why extend vs fork | Added YAML `parameters` to shared task instead of NGIQ-only duplicate |
| Boundary choice | Feature logic stays in product package; shared layer stays generic |
| Abstraction timing | Shared helper extracted after second identical copy, not speculatively |

When the fork matters for long-term maintenance, record briefly:

- What existing code was considered
- Why reuse / extend / abstract / rewrite
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
- New modules when extending existing code would suffice
- Duplicate logic without documenting why reuse was rejected
