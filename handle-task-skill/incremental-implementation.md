# Incremental implementation

Delegate for `/handle-task` Phase 7. **Orchestrates** slice execution; TDD detail in
[test-driven-development.md](test-driven-development.md); spec proof in
[spec-adherence.md](spec-adherence.md).

## Slice cycle (canonical)

```
REUSE CHECK → RED → GREEN → REFACTOR → SPEC ADHERE → Verify → (commit) → next slice
```

| Step | Delegate |
| ---- | -------- |
| REUSE CHECK | Below |
| RED / GREEN / REFACTOR | [test-driven-development.md](test-driven-development.md) |
| SPEC ADHERE | [spec-adherence.md](spec-adherence.md) — slice acceptance criteria → tests |
| Verify | Scoped command from todo / [verification.md](verification.md) |

After each slice: behavior tested (failed before GREEN), spec items for slice covered or gaps reported, build green.

## REUSE CHECK (before RED)

Search codebase first — **do not reinvent the wheel.**

| Situation | Action |
| --------- | ------ |
| Existing code fits | Call it |
| Close fit | Extend or parameterize |
| Nothing fits | Add new — log what you searched |
| Duplicate logic emerging | Extract only if clearer than two copies |

```
REUSE CHECK: considered [paths]; approach: reuse | extend | new (why)
```

Log non-obvious choices in `memory.decisions`.

## SOLID (guardrails)

| Principle | Practice |
| --------- | -------- |
| **S** | One reason to change per unit |
| **O** | Extend via types/composition, not editing stable core for every variant |
| **L** | Subtypes honor contracts |
| **I** | Narrow public APIs |
| **D** | Inject abstractions at boundaries; test with fakes |

Also: minimal diff, explicit module ownership, single source of truth for constants/keys.

## Slicing

Prefer **vertical slices** (end-to-end path per todo item). ≤ ~5 files per slice.
See [planning-and-task-breakdown.md](planning-and-task-breakdown.md).

## Slice checklist

- [ ] REUSE CHECK stated
- [ ] RED → GREEN → REFACTOR ([test-driven-development.md](test-driven-development.md))
- [ ] Spec adherence for slice — no Blocker gaps ([spec-adherence.md](spec-adherence.md))
- [ ] Scoped verify command passed
- [ ] User notified if spec gaps found and fixed or deferred

## Anti-patterns

- Production before failing test
- 100+ lines without running tests
- Copy-paste instead of reuse
- God modules mixing I/O + rules + formatting
- "Tests green" without spec traceability
- Drive-by refactors outside scope
