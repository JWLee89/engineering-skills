# Incremental implementation

Standalone delegate for `/handle-task` Phase 7. Implements approved plan slices with
**simple, maintainable, testable, extensible** code.

## When to use

- Any multi-file change
- Executing items from `{local_specs}/todo-<ticket_key_lower>.md`

**Skip:** trivial single-file edits.

## Increment cycle

```
Implement → Test → Verify → Commit (when asked) → Next slice
```

After each slice: project builds, existing tests pass, slice acceptance criteria met.

## DRY — reuse before you add (required)

**Do not reinvent the wheel.** Before writing new code, search the codebase for existing
helpers, types, tasks, protocols, and tests that already solve part of the problem — or
the whole problem.

| Situation | Do this |
| --------- | ------- |
| Existing function does exactly what you need | **Call it** — do not copy or reimplement |
| Existing function is close | **Extend or parameterize** it when both old and new cases stay clear |
| No existing code fits | **Add new code** — but state what you searched and why reuse failed |
| Same logic would appear twice | **Extract once** — only when the shared form is easier to read than two copies |

Rules:

1. **Search first** — grep, jump to definitions, read neighboring modules and tests.
2. **Prefer tweak over duplicate** — a small, focused change to existing code beats a
   parallel implementation with renamed variables.
3. **Abstract only when earned** — introduce a shared helper or type when it removes
   duplication *and* stays easier to read than two straightforward copies. Three similar
   lines beat a premature abstraction.
4. **Match conventions** — naming, module boundaries, registry patterns, and test layout
   should match surrounding code (read before writing).

When you choose reuse vs new code vs new abstraction, log the choice in
`memory.decisions` if non-obvious ([documentation-and-adrs.md](documentation-and-adrs.md)).

```
REUSE CHECK (state before coding):
- Existing code considered: [paths or "none found"]
- Approach: reuse as-is | extend | new abstraction | new code (justify)
```

## SOLID — maintainable, testable, extensible code

Follow [SOLID](https://en.wikipedia.org/wiki/SOLID) as practical guardrails, not ceremony.
Each slice should leave code that is easy to **maintain**, **test**, and **extend**.

| Principle | In practice (handle-task) |
| --------- | ------------------------- |
| **S** — Single responsibility | One task/function/module reason to change. Split when a slice mixes I/O, wire format, and business rules. |
| **O** — Open/closed | Extend via parameters, registries, or new subclasses — avoid editing stable shared code for every product variant. |
| **L** — Liskov substitution | Subtypes and protocol implementations must honor the same contracts; tests should not need special cases per variant. |
| **I** — Interface segregation | Narrow public surfaces — typed entities and small protocol methods; don't force callers to depend on unused fields. |
| **D** — Dependency inversion | Depend on abstractions (protocols, registries, interfaces) at boundaries; keep concrete I/O and framework details at the edges. |

Applied habits:

- **Minimal diff** — touch only what the task requires; note unrelated smells, don't fix them.
- **Explicit boundaries** — typed entities, clear module ownership; avoid leaking feature logic into shared layers.
- **Single source of truth** — wire keys from models (`fields()`, `asdict()`); config in one file when humans edit path lists or constants.
- **Test with the production path** — reuse fixtures and helpers; parametrize instead of copy-paste tests ([code-review.md](code-review.md)).
- **Inject or pass dependencies** — prefer constructor/task inputs over hidden globals so unit tests can substitute fakes.

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
- Does each new type/function have one clear job (SRP)?
- Can the next ticket extend this without editing unrelated modules (OCP)?

## Increment checklist

After each slice:

- [ ] REUSE CHECK completed — existing code searched; approach recorded if non-obvious
- [ ] Slice does one thing; builds and existing tests pass
- [ ] New behavior covered by reusing or extending existing tests/fixtures where possible
- [ ] No duplicate logic introduced without justification in `memory.decisions`

## Anti-patterns

- 100+ lines before running tests
- New module for logic that belongs in an existing product package
- Copy-paste with renamed variables instead of calling or extending existing code
- Reimplementing a helper that already exists one import away
- God tasks/functions that mix gather, transform, validate, and I/O in one place
- Drive-by refactors outside task scope
- Leaking product-specific rules into shared layers "for convenience"
