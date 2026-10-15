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
| Close fit but **stricter semantics** (e.g. bounded positive number vs generic parse) | Add a **new named helper**; do not silently change the old helper’s contract |
| Value-level vs record-level parsing | Share **value coercion**; keep record/key helpers separate when callers need different missing vs invalid errors |
| Nothing fits | Add new — log what you searched |
| Duplicate logic emerging | Refactor existing function for reuse, or extract — only if clarity improves |
| Superseded by new behavior | Delete dead paths, flags, and helpers in the same slice when safe |

```
REUSE CHECK: considered [paths]; approach: reuse | extend | new (why)
```

Log non-obvious choices in `memory.decisions`.

## Minimalism bar (production code)

Prefer **simplicity, readability, and maintainability** over clever or layered designs. Keep **production** patches as small as the spec allows — implement only what the ticket needs; **delete** code that is no longer used so the codebase does not grow without reason.

Each function or type should **do or represent one thing**. When possible, keep function bodies **under ~15 lines** (excluding docstrings and blank lines); split or extract when logic branches or mixed concerns make a block hard to read — not to hit a number.

Prefer **pure functions**: given the same inputs, return the same result without hidden side effects on shared state. Use **mutation** only when it clearly fits object-oriented design **and** a reader can see why in-place update is simpler than returning new values — it must **reduce** complexity in the system or data flow, not add surprise. When the codebase already favors immutability or copy-on-write, follow that pattern.

| Prefer | Avoid |
| ------ | ----- |
| Pure transforms and explicit return values | Mutating arguments or globals for convenience |
| Mutation on a well-named object lifecycle (e.g. build → calculate → read results) | In-place tweaks scattered across call chains |
| One public entry point per slice | Frameworks or indirection for one call site |
| Explicit validation steps per group | Registry-driven loops when rules still differ per field ([design-tradeoffs.md](design-tradeoffs.md)) |
| Named resolver for legacy alias | Generic callback readers that hide which field is read |
| Production shipping shape | Milestone-only flags or RC placeholders in code ([design-tradeoffs.md](design-tradeoffs.md#production-vs-milestone-wording)) |
| Call or lightly extend an existing function | Re-implementing or renaming the same logic under a new symbol |
| Reuse existing helpers (enums, wire keys, shared parsers) | Duplicate tables, validation, or skip wiring owned elsewhere |
| Shared test fixtures (one definition in test helpers) | Same valid-input dict copied in unit + integration files |
| Product-owned tests under the product package | Product-only scenarios in shared `common/` test modules |
| Removing obsolete code in-scope | Leaving dead branches “for later” |
| 1–2 focused commits before `/pull-request` | Many incremental “feat/test/docs” commits for one behavior |

After REFACTOR, ask: **Can a reviewer understand this in one pass?** If not, delete, merge, or split before opening the PR.

When a single behavioral change touched many similar lines, extract **intent-revealing** helpers (production or `tests/utils`) so the contract is named once — [engineering-rubric.md](engineering-rubric.md#intent-revealing-helpers-production-and-tests).

## Dead code sweep (REFACTOR)

After behavior changes, design simplification, or moving validation inline, **grep the repo** for symbols you added or superseded. Senior maintainers **reduce line count** where requirements are unchanged — unused code is confusion and debt.

| Finding | Action |
| ------- | ------ |
| Production helper **only imported in tests** | Remove the helper **and** tests whose sole job was asserting that helper (unless it is a deliberate public contract — then document + real caller) |
| Abstraction replaced by explicit steps | Delete the old dispatcher, registry tags, and introspection-only paths in the **same PR** |
| Duplicate SSOT (two registries, two validators) | Keep one; delete the other |
| Feature flag / milestone branch obsolete | Remove branch and tests tied only to that path |

```
DEAD CODE SWEEP: rg [symbol]; production callers: [paths | none → removed]
```

Log intentional public surface in PR body or `memory.decisions` when something looks unused but must stay exported.

## Layer ownership (REFACTOR)

When one module mixes **source/input modeling** with **output assembly** or **external serialization**, consolidate in REFACTOR (prefer the same slice as the behavior change):

| Concern | Belongs in | Typical responsibilities |
| ------- | ---------- | ------------------------ |
| Domain / source model | Module that owns the raw input contract | Schema keys, typed fragments, parse, coerce, validate |
| Assembly / adapter | Module that owns the handoff to the next system | Map pipeline entities → output records; serialize wire/API shape |

| Rule | Action |
| ---- | ------ |
| Dependency direction | Assembly imports domain; domain must not import assembly (no cycles). |
| One resolution path | If validation and mapping read the same field (including aliases), extract one shared resolver — do not duplicate branches. |
| Move completely | Relocate symbols to the owning module; search the repo for old import paths and update callers in the same change. |
| Public surface | Prefer canonical imports over re-export shims unless a stable API must outlive a deprecation window. |

Log non-obvious boundary moves in `memory.decisions`.

**Tests are not “minimal” in coverage** — they should be **rigorous and comprehensive** for the slice (see below and [test-driven-development.md](test-driven-development.md)). Minimalism applies to **how** tests are written (DRY, table-driven, parameterized), not **how much** behavior is exercised.

## Rigorous tests (same slice)

Before GREEN is done for a logic slice:

| Require | How |
| ------- | --- |
| Spec → test map | Every acceptance criterion has at least one test (or explicit deferral in spec) |
| Happy path | At least one test per public outcome |
| Edge / failure paths | Missing, empty, invalid, boundary values; mixed valid/invalid batches when applicable |
| Realistic / stress rows | Parameterized cases mirror real payloads and robustness scenarios — not trivial permutations |
| Regression guard | Table-driven or parameterized cases for each input class — avoid copy-paste cases that drift |
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
- [ ] Dead code sweep — no production symbols with test-only callers ([dead-code-sweep-refactor](#dead-code-sweep-refactor))
- [ ] RED → GREEN → REFACTOR ([test-driven-development.md](test-driven-development.md))
- [ ] FEATURE GATE passed or skip documented ([feature-gating.md](feature-gating.md))
- [ ] Spec adherence for slice — no Blocker gaps ([spec-adherence.md](spec-adherence.md))
- [ ] Scoped verify command passed (agent executed; summary captured)
- [ ] After module moves: dependency direction respected; old import paths grep-clean; tests use canonical modules
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
- Skipping parameterized edge cases to “keep tests small”
- Long functions mixing validation, I/O, and formatting — split by responsibility
- Adding new modules when an existing function could be extended without breaking single-purpose design
- Hidden mutation (inputs or shared state changed without obvious naming or ownership)
- Over-abstracting validation to “derive everything from the registry” when humans must read the handler to see behavior
- Registry constant mistaken for a default value on missing payload fields
- Coding to milestone/RC gates instead of production behavior ([design-tradeoffs.md](design-tradeoffs.md))
