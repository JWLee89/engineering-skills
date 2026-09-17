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
functions, classes, modules, and tests that already solve part of the problem — or the
whole problem.

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
4. **Match conventions** — naming, module boundaries, and test layout should match
   surrounding code (read before writing).

When you choose reuse vs new code vs new abstraction, log the choice in
`memory.decisions` if non-obvious ([documentation-and-adrs.md](documentation-and-adrs.md)).

```
REUSE CHECK (state before coding):
- Existing code considered: [paths or "none found"]
- Approach: reuse as-is | extend | new abstraction | new code (justify)
```

## SOLID — maintainable, testable, extensible code

Follow the five [SOLID principles of object-oriented design](https://www.digitalocean.com/community/conceptual-articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design)
(Robert C. Martin) as practical guardrails, not ceremony. Each slice should leave code
that is easy to **maintain**, **test**, and **extend**.

| Principle | Definition (DigitalOcean) | In practice (each slice) |
| --------- | ------------------------- | ------------------------ |
| **S** — Single-responsibility | A class should have one and only one reason to change — one job. | Split when a unit mixes unrelated jobs (e.g. compute + format + persist). |
| **O** — Open-closed | Open for extension, closed for modification. | Add behavior via new types, parameters, or composition — avoid editing stable shared code for every variant. |
| **L** — Liskov substitution | Subtypes must be replaceable for their base type without breaking correctness. | Subclasses and interface implementations honor the same contract; tests need no special cases per variant. |
| **I** — Interface segregation | Clients must not depend on methods or interfaces they do not use. | Keep public APIs narrow; split bloated interfaces rather than forcing unused methods on callers. |
| **D** — Dependency inversion | High-level modules must not depend on low-level modules; both depend on abstractions. | Inject or pass abstractions (interfaces, ports) at boundaries; keep concrete I/O and framework details at the edges. |

Applied habits:

- **Minimal diff** — touch only what the task requires; note unrelated smells, don't fix them.
- **Explicit boundaries** — clear module ownership; avoid leaking feature logic into shared utilities.
- **Single source of truth** — derive schema or field names from models/types; avoid duplicated constant lists.
- **Test with the production path** — reuse fixtures and helpers; parametrize instead of copy-paste tests ([code-review.md](code-review.md)).
- **Inject or pass dependencies** — prefer constructor or function parameters over hidden globals so unit tests can substitute fakes (DIP).

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
- New module for logic that belongs in an existing package
- Copy-paste with renamed variables instead of calling or extending existing code
- Reimplementing a helper that already exists one import away
- God classes/functions that mix unrelated responsibilities (I/O, formatting, business rules) in one place
- Drive-by refactors outside task scope
- Leaking feature-specific rules into shared layers "for convenience"
