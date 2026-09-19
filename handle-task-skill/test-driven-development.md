# Test-driven development (per slice)

Delegate for `/handle-task` Phase 7 — **RED / GREEN / REFACTOR** only.
Cycle context: [incremental-implementation.md](incremental-implementation.md).

**Required** for logic, APIs, CI scripts, bug fixes. **Skip RED** for docs/format-only slices.

## RED — failing test first

Derive tests from todo **acceptance criteria** and spec scenarios:

1. Match neighboring test layout and fixtures
2. Happy path + meaningful edge (skip, error, mixed input)
3. `@pytest.mark.parametrize` over copy-paste cases
4. Named constants / enums / `load_*()` — no duplicated magic strings ([verification.md](verification.md))
5. Reuse fixtures; extend before parallel inventing

Confirm the test **failed** (or would fail) before production code.

**Bugs:** failing repro test before fix (Prove-It).

## GREEN — minimal code

Only what makes RED pass. Reuse or extend existing code — no renamed reimplementations.
Narrow APIs; inject dependencies at edges.

## REFACTOR — with green tests

Dedupe via reuse, not a second helper doing the same job. Log non-obvious forks in `memory.decisions`.

## Test stack

Discover from repo (`Makefile`, `pyproject.toml`, `verify.commands`) — never assume `pytest` vs `npm test`.

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Code before test | Stop at RED |
| Tests assert internals not spec behavior | Assert outcomes from acceptance criteria |
| Mock everything | Prefer production path where feasible |
| Skip REFACTOR | Duplication compounds |

After REFACTOR → [spec-adherence.md](spec-adherence.md) for the slice.
