# Test-driven development (per slice)

Delegate for `/handle-task` Phase 7 — **RED / GREEN / REFACTOR** only.
Cycle context: [incremental-implementation.md](incremental-implementation.md).

**Required** for logic, APIs, CI scripts, bug fixes. **Skip RED** for docs/format-only slices.

## RED — failing test first

Derive tests from todo **acceptance criteria** and spec scenarios:

1. Match neighboring test layout and fixtures
2. **Happy path** plus **edge and failure paths** (missing, empty, invalid, boundary, mixed batches)
3. **Table-driven or parameterized cases** for every class of input — each row must exercise a **distinct outcome or risk**, not a cosmetic tweak
4. **Explicit failure assertions** — when the contract is “this input must fail with error *E*” (validation, parse, I/O boundary), use the test runner’s **expected-failure** mechanism (assert that the call throws or returns a typed error), not only happy-path wrappers that accumulate errors. Cover failure modes in the same table-driven suites as success paths where the API throws; use outcome assertions on error collections only when the production API is intentionally non-throwing.
5. **Realistic inputs** — shapes, sizes, and combinations that mirror production or integrator payloads (including partially filled records and sloppy types where the boundary allows)
6. **Stress / robustness** — where spec implies it: large batches, repeated failures, alias vs canonical keys, concurrent or ordered edge sequences the domain cares about
7. Named constants / enums / shared loaders — no duplicated magic strings ([verification.md](verification.md))
8. Reuse fixtures; one shared valid-input builder in test helpers — extend before parallel inventing
9. When data **is** the contract (alias maps, golden rows), **iterate the source table** in at least one test

Confirm the test **failed** (or would fail) before production code.

**Coverage bar:** non-trivial logic needs more than one meaningful case. Parameterized suites count as rigorous when rows map to **branches, error codes, or real-world scenarios** — not three obvious permutations of the same success path.

**Bugs:** failing repro test before fix (Prove-It).

## GREEN — minimal code

Only what makes RED pass. **Reuse** an existing function when a small extension fits single-purpose design; do not copy logic under a new name.
Keep new functions short and focused; prefer pure transforms unless mutation is the idiomatic, reader-obvious choice for that type; narrow public APIs; inject dependencies at edges.

## REFACTOR — with green tests

Dedupe via reuse, not a second helper doing the same job. Split or extract only when readability or single responsibility improves — prefer small functions over large blocks.
When one **behavioral contract** drove many line changes (especially asserts or “only update when …” branches), extract **intent-revealing** helpers so readers see purpose at a glance — production and test utils ([engineering-rubric.md](engineering-rubric.md#intent-revealing-helpers-production-and-tests)).
Remove redundant tests after parameterized cases land; **delete** production code that is no longer reachable. Log non-obvious forks in `memory.decisions`.

## Test stack

Discover from repo config (`verify.commands`, CI workflows, package scripts) — never assume a default test runner.

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Code before test | Stop at RED |
| Happy path only | Add realistic edge/failure/stress cases from spec |
| Copy-paste test cases | Table-driven suite — each row must justify its existence |
| Trivial parameterized rows | Replace with domain-realistic fixtures and boundaries ([design-tradeoffs.md](design-tradeoffs.md#test-design-vs-production-design)) |
| Tests assert internals not spec behavior | Assert outcomes from acceptance criteria |
| Mock everything | Prefer production path where feasible |
| Skip REFACTOR | Duplication compounds |
| Many tests repeat the same assert for one rule | Named test helper (e.g. preserve raw on failure) + reuse |
| New code when extend would do | Extend or refactor the existing function |
| Thin wrapper around one built-in (e.g. map lookup with default) | Use the native API unless semantics truly differ |
| Growing the codebase without deleting obsolete code | Remove superseded paths in the same slice |
| Side-effect-heavy helpers | Return new values or use explicit object methods whose name signals mutation |
| Same contract in unit + common + integration | One behavioral home per product boundary |

After REFACTOR → [spec-adherence.md](spec-adherence.md) for the slice.
