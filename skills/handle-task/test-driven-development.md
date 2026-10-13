# Test-driven development (per slice)

Delegate for `/handle-task` Phase 7 — **RED / GREEN / REFACTOR** only.
Cycle context: [incremental-implementation.md](incremental-implementation.md).

**Required** for logic, APIs, CI scripts, bug fixes. **Skip RED** for docs/format-only slices.

## RED — failing test first

Derive tests from todo **acceptance criteria** and spec scenarios:

1. Match neighboring test layout and fixtures
2. **Happy path** plus **edge and failure paths** (missing, empty, invalid, boundary, mixed batches)
3. **`@pytest.mark.parametrize`** (or table loops) for every class of input — prevents copy-paste drift and guards against breaking changes
4. Named constants / enums / `load_*()` — no duplicated magic strings ([verification.md](verification.md))
5. Reuse fixtures; one shared valid-input builder (e.g. `tests/utils/`) — extend before parallel inventing
6. When data **is** the contract (alias maps, golden rows), **iterate the source table** in at least one test

Confirm the test **failed** (or would fail) before production code.

**Coverage bar:** non-trivial logic needs more than one test method — parametrization counts as rigorous coverage when it exercises distinct branches/outcomes.

**Bugs:** failing repro test before fix (Prove-It).

## GREEN — minimal code

Only what makes RED pass. Reuse or extend existing code — no renamed reimplementations.
Narrow APIs; inject dependencies at edges.

## REFACTOR — with green tests

Dedupe via reuse, not a second helper doing the same job. Log non-obvious forks in `memory.decisions`.
After adding parametrized cases, remove redundant one-off tests that duplicate the same assertions.

## Test stack

Discover from repo (`Makefile`, `pyproject.toml`, `verify.commands`) — never assume `pytest` vs `npm test`.

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Code before test | Stop at RED |
| Happy path only | Add parametrized edge/failure cases from spec |
| Copy-paste test cases | Parametrize or loop over table |
| Tests assert internals not spec behavior | Assert outcomes from acceptance criteria |
| Mock everything | Prefer production path where feasible |
| Skip REFACTOR | Duplication compounds |
| Same contract in unit + common + integration | One behavioral home per product boundary |

After REFACTOR → [spec-adherence.md](spec-adherence.md) for the slice.
