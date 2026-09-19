# Test-driven development (per slice)

Standalone delegate for `/handle-task` Phase 7. Use with
[incremental-implementation.md](incremental-implementation.md) on **every slice that changes
behavior** (logic, APIs, CI scripts, config-driven runtime paths).

**Skip TDD** for docs-only, pure formatting, or static content with no testable behavior —
still run linters and existing tests.

## Why TDD here

Production code must **scale**, stay **easy to test, maintain, and extend**, and **reuse**
existing helpers instead of reimplementing them. Writing the test first:

- Locks acceptance criteria before implementation drift
- Produces testable seams (DIP) by design
- Proves the slice works; green tests are the definition of done for behavior

## Slice cycle (required order)

```
REUSE CHECK → RED → GREEN → REFACTOR → Verify → (commit when asked) → next slice
```

| Step | Action |
| ---- | ------ |
| **REUSE CHECK** | Search codebase for existing code/tests to call or extend ([incremental-implementation.md](incremental-implementation.md)) |
| **RED** | Write or extend a **failing** test for this slice's acceptance criteria |
| **GREEN** | Write **minimal** production code to pass; do not add unrequested behavior |
| **REFACTOR** | Clean up; deduplicate; extract only when reuse is real — tests must stay green |
| **Verify** | Run scoped test command from todo; then broader suite if the slice touched shared code |

A test that passes on first write without new code proves nothing — confirm it failed (or
would fail) before GREEN.

## RED — tests first

Before editing production code for the slice:

1. Read neighboring tests — match layout, fixtures, and naming
2. Derive cases from todo **acceptance criteria** (happy path + one meaningful edge)
3. Prefer `@pytest.mark.parametrize` when behavior varies by input
4. Use **named constants** for dimensions, wire keys, and profile names — single source
   ([verification.md](verification.md#test-robustness))
5. Reuse existing fixtures/helpers; extend before inventing parallel ones

**Bug fixes:** reproduce the bug in a failing test before changing production code (Prove-It).

## GREEN — minimal implementation

- Implement only what the failing test requires
- **Reuse or extend** existing functions — do not copy-paste with renamed variables
- Keep public surfaces narrow (ISP); inject dependencies at boundaries (DIP)
- One reason to change per unit (SRP)

## REFACTOR — production quality

After green:

- Remove duplication by calling or extending existing code — not by adding a second helper
  that does the same thing under a new name
- Confirm the slice is **extensible** (next ticket can add behavior without rewriting unrelated modules)
- Log non-obvious reuse vs new-code choices in `memory.decisions`

## Discover the project's test stack

Before the first RED step in a repo, find how **this** project runs tests:

- `Makefile`, `pyproject.toml`, `package.json`, CI workflows, `verify.commands` in
  `.handle-task/project.yaml`
- Use **scoped** commands during the loop; full suite before handoff to `/make-pull-request`

Never assume a default runner — use the repo's commands.

## When TDD applies to a slice

| Slice type | TDD |
| ---------- | --- |
| New logic, bug fix, behavior change | **Required** — RED first |
| Refactor with same behavior | Extend existing tests first; add characterization test if coverage gap |
| New CI script / detector | Unit test the script's pure functions before wiring YAML |
| Docs, markdown, comments only | Skip RED; run format/lint |
| Config value tweak with no new branches | Existing tests must pass; add test only if behavior changes |

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Production code before any test | Stop; write failing test (RED) |
| 100+ lines of code then run tests | RED → GREEN in small steps |
| Copy-paste test bodies | Parametrize or shared fixtures |
| New helper when an import already exists | REUSE CHECK; extend or call |
| Tests that mock everything | Assert through production path where feasible |
| Skipping REFACTOR | Duplication ships to the next slice |

## Cross-references

- [incremental-implementation.md](incremental-implementation.md) — DRY, SOLID, reuse check
- [verification.md](verification.md) — test robustness, verify commands
- [code-review.md](code-review.md) — five-axis review before PR ready
