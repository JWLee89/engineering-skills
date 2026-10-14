# Test-driven development (per slice)

Delegate for `/handle-task` Phase 7 — **RED / GREEN / REFACTOR** only.
Cycle context: [incremental-implementation.md](incremental-implementation.md).

**Required** for logic, APIs, CI scripts, bug fixes. **Skip RED** for docs/format-only slices.

## RED — failing test first

Derive tests from todo **acceptance criteria** and spec scenarios:

1. Match neighboring test layout and fixtures
2. **Happy path** plus **edge and failure paths** (missing, empty, invalid, boundary, mixed batches)
3. **Table-driven or parameterized cases** for every class of input (loop over rows or the project’s equivalent) — prevents copy-paste drift and guards against breaking changes
4. Named constants / enums / shared loaders — no duplicated magic strings ([verification.md](verification.md))
5. Reuse fixtures; one shared valid-input builder in the repo’s test helpers — extend before parallel inventing
6. When data **is** the contract (alias maps, golden rows), **iterate the source table** in at least one test

Confirm the test **failed** (or would fail) before production code.

**Coverage bar:** non-trivial logic needs more than one test case — parameterized or table-driven suites count as rigorous coverage when they exercise distinct branches/outcomes.

**Bugs:** failing repro test before fix (Prove-It).

## GREEN — minimal code

Only what makes RED pass. **Reuse** an existing function when a small extension fits single-purpose design; do not copy logic under a new name.
Keep new functions short and focused; prefer pure transforms unless mutation is the idiomatic, reader-obvious choice for that type; narrow public APIs; inject dependencies at edges.

## REFACTOR — with green tests

Dedupe via reuse, not a second helper doing the same job. Split or extract only when readability or single responsibility improves — prefer small functions over large blocks.
Remove redundant tests after parameterized cases land; **delete** production code that is no longer reachable. Log non-obvious forks in `memory.decisions`.

## Test stack

Discover from repo config (`verify.commands`, CI workflows, package scripts) — never assume a default test runner.

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Code before test | Stop at RED |
| Happy path only | Add parameterized edge/failure cases from spec |
| Copy-paste test cases | Table-driven or parameterized suite over case rows |
| Tests assert internals not spec behavior | Assert outcomes from acceptance criteria |
| Mock everything | Prefer production path where feasible |
| Skip REFACTOR | Duplication compounds |
| New code when extend would do | Extend or refactor the existing function |
| Growing the codebase without deleting obsolete code | Remove superseded paths in the same slice |
| Side-effect-heavy helpers | Return new values or use explicit object methods whose name signals mutation |
| Same contract in unit + common + integration | One behavioral home per product boundary |

After REFACTOR → [spec-adherence.md](spec-adherence.md) for the slice.
