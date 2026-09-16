# Incremental implementation

Standalone delegate for `/handle-task` Phase 7. Implements approved plan slices with
**simple, maintainable, testable** code.

## When to use

- Any multi-file change
- Executing items from `{local_specs}/todo-<ticket_key_lower>.md`

**Skip:** trivial single-file edits.

## Increment cycle

```
Implement → Test → Verify → Commit (when asked) → Next slice
```

After each slice: project builds, existing tests pass, slice acceptance criteria met.

## Reuse before you add (required)

Before writing new code:

1. **Search** the codebase for existing helpers, types, tasks, protocols, and tests
   that already solve part of the problem.
2. **Prefer tweak over duplicate** — extend or parameterize existing code when it
   accommodates both the old and new case without obscuring intent.
3. **Abstract only when earned** — introduce a shared helper or type when it
   removes duplication *and* stays easier to read than two straightforward copies.
   Three similar lines beat a premature abstraction.
4. **Match conventions** — naming, module boundaries, registry patterns, and test
   layout should match surrounding code (read before writing).

When you choose reuse vs new code vs new abstraction, log the choice in
`memory.decisions` if non-obvious ([documentation-and-adrs.md](documentation-and-adrs.md)).

```
REUSE CHECK (state before coding):
- Existing code considered: [paths or "none found"]
- Approach: extend | reuse as-is | new abstraction | new code (justify)
```

## Design principles

- **Minimal diff** — touch only what the task requires; note unrelated smells, don't fix them.
- **Explicit boundaries** — typed entities, clear module ownership; avoid leaking feature logic into shared layers.
- **Single source of truth** — wire keys from models (`fields()`, `asdict()`); config in one file when humans edit path lists or constants.
- **Test with the production path** — reuse fixtures and helpers; parametrize instead of copy-paste tests ([code-review.md](code-review.md)).

## Slicing strategies

| Strategy       | Use when                                           |
| -------------- | -------------------------------------------------- |
| Vertical slice | Default — one user-visible path per slice          |
| Contract-first | Parallel backend/frontend — define types/API first |
| Risk-first     | Highest uncertainty first — fail fast              |

## Simplicity check (after each slice)

- Can this be done in fewer lines without losing clarity?
- Are abstractions earning their complexity?
- Would a staff engineer ask "why didn't you just use X?" — if X exists in repo, use it.

## Anti-patterns

- 100+ lines before running tests
- New module for logic that belongs in an existing product package
- Copy-paste with renamed variables instead of shared helper
- Drive-by refactors outside task scope
