# Incremental implementation

Delegate for `/handle-task` Phase 7. **Orchestrates** slice execution; quality bar in
[engineering-rubric.md](engineering-rubric.md); TDD in [test-driven-development.md](test-driven-development.md);
spec proof in [spec-adherence.md](spec-adherence.md).

## Slice cycle (canonical)

```
REUSE CHECK → RED → GREEN → REFACTOR → FEATURE GATE → SPEC ADHERE → Verify → (commit) → next slice
```

| Step | Delegate |
| ---- | -------- |
| REUSE CHECK | Below |
| RED / GREEN / REFACTOR | [test-driven-development.md](test-driven-development.md) |
| FEATURE GATE | [feature-gating.md](feature-gating.md) — isolation proof when applicable |
| SPEC ADHERE | [spec-adherence.md](spec-adherence.md) — slice acceptance criteria → tests |
| Verify | Scoped command from todo / [verification.md](verification.md) (agent runs + evidence) |

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

## Minimalism bar (production code)

Keep **production** patches as small and boring as the spec allows. Prefer one public function, private data, and table-driven tests over multi-layer wiring in the same ticket when the spec allows splitting.

| Prefer | Avoid |
| ------ | ----- |
| One public entry point per slice | Frameworks, validator classes, or indirection for one call site |
| Reuse existing helpers (`get_*`, enums, wire keys) | Re-implementing logic already owned by a sibling ticket |
| Shared test fixtures (one definition, e.g. `tests/utils/`) | Same valid-input dict copied in unit + integration files |
| Product-owned tests under the product package | Product-only scenarios in shared `common/` test modules |
| 1–2 focused commits before `/pull-request` | Many incremental “feat/test/docs” commits for one behavior |

After REFACTOR, ask: **Can a reviewer understand this in one pass?** If not, delete or merge before opening the PR.

**Tests are not “minimal” in coverage** — they should be **rigorous and comprehensive** for the slice (see below and [test-driven-development.md](test-driven-development.md)). Minimalism applies to **how** tests are written (DRY, parametrized), not **how much** behavior is exercised.

## Rigorous tests (same slice)

Before GREEN is done for a logic slice:

| Require | How |
| ------- | --- |
| Spec → test map | Every acceptance criterion has at least one test (or explicit deferral in spec) |
| Happy path | At least one test per public outcome |
| Edge / failure paths | Missing, empty, invalid, boundary values; mixed valid/invalid batches when applicable |
| Regression guard | `@pytest.mark.parametrize` (or equivalent) for classes of inputs — avoid copy-paste cases that drift |
| Table / data as SSOT | Loop over alias tables or golden rows where the data **is** the contract |
| Stable assertions | Error messages via enums/constants shared with production when user-facing |

Anti-pattern: one happy-path test only. Anti-pattern: three test files asserting the same contract.

## Design & quality

Apply [engineering-rubric.md](engineering-rubric.md) axes 1–5 on every slice.

## Slicing

Prefer **vertical slices** (end-to-end path per todo item). ≤ ~5 files per slice.
See [plan-and-tasks.md](plan-and-tasks.md).

## Slice checklist

- [ ] REUSE CHECK stated
- [ ] RED → GREEN → REFACTOR ([test-driven-development.md](test-driven-development.md))
- [ ] FEATURE GATE passed or skip documented ([feature-gating.md](feature-gating.md))
- [ ] Spec adherence for slice — no Blocker gaps ([spec-adherence.md](spec-adherence.md))
- [ ] Scoped verify command passed (agent executed; summary captured)
- [ ] User notified if spec gaps found and fixed or deferred

## Anti-patterns

- Production before failing test
- 100+ lines without running tests
- Copy-paste instead of reuse
- God modules mixing I/O + rules + formatting
- "Tests green" without spec traceability
- Drive-by refactors outside scope
- Duplicating fixtures or validation already owned by another module/ticket
- Product-specific tests under shared packages (`common/`) when only one product needs the behavior
- Skipping parametrized edge cases to “keep tests small”
