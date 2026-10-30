# Engineering rubric

**Single source of truth** for **writing code** and **author self-review** (`/handle-task` Phase 7,
`/pull-request` Phase 6). Do not duplicate these axes elsewhere — link here.

For **deep PR review** by a reviewer pass, use **`/code-review`** → [code-review/rubric.md](../code-review/rubric.md).
For **ticket text quality**, use [review-ticket/quality-gate.md](../review-ticket/quality-gate.md).

**Approve when** the change improves overall code health and meets the spec — not when it matches
personal style perfectly.

______________________________________________________________________

## Core axes (non-trivial code)

### 1. Correctness & testing

| Check | Action |
| ----- | ------ |
| Spec / acceptance | Every success criterion mapped to tests or explicit deferral ([spec-adherence.md](spec-adherence.md)) |
| TDD order | Behavioral changes: failing test first or co-evolved ([test-driven-development.md](test-driven-development.md)) |
| Behavior vs implementation | Tests assert outcomes, not internal trivia |
| Edge / error paths | Cover null, empty, boundaries, and handled failure modes; use **expected-failure** tests where the contract is to throw or return a typed error ([test-driven-development.md](test-driven-development.md)) |
| Realistic & stress cases | Parameterized/table suites use **domain-realistic** inputs and **robustness** cases (partial records, messy types, batch mixes, boundary magnitudes) — not cosmetic variants of the happy path ([test-driven-development.md](test-driven-development.md)) |
| Domain invariants | When the spec implies ordering, monotonicity, or boundary rules, test violations and out-of-range inputs — not only mid-range success ([test-driven-development.md](test-driven-development.md)) |
| Declarative wiring | Config or manifest changes stay aligned with fixtures and wiring tests ([verification.md](verification.md#declarative-config-and-wiring)) |
| Comprehensive coverage | Exercise each class of input so regressions are caught; map every spec acceptance item to a test ([test-driven-development.md](test-driven-development.md)) |
| DRY test structure | Shared fixtures, data tables, loops over case rows — not duplicate test modules re-asserting the same contract |

**Red flags:** production logic without tests for new behavior; "green" without spec traceability; happy-path-only tests for non-trivial logic; parameterized rows that only tweak trivial literals with no new branch or risk; production functions/constants **only referenced from tests** (delete or wire a real caller).

### 2. Clarity & maintainability

| Check | Action |
| ----- | ------ |
| Naming | Matches project conventions (`memory.agent_guide`, existing modules) |
| Simplicity | Prefer readable, boring code over clever or nested complexity; avoid helpers that only wrap a single built-in (e.g. dictionary lookup) when semantics match the built-in |
| Single purpose | Each function and object does or represents one job; split when responsibilities mix |
| Small functions | Aim for ~15 lines per function body when feasible; extract helpers when a block is hard to follow |
| Pure by default | Prefer functions that return results from inputs without hidden side effects; mutation only when OOP ownership makes in-place update clearer and **simplifies** data flow for the reader |
| Reuse | Search first ([incremental-implementation.md](incremental-implementation.md)); call, extend, or refactor existing code before adding parallel implementations |
| Minimal diff | Only what the task requires — no “nice to have” helpers, abstractions, or tests outside product boundary |
| Shrink when safe | Delete unused code, flags, and dead paths in the same change when behavior is superseded |
| No orphan APIs | Before merge: every new or touched **production** symbol has a **non-test** caller, or delete it (and tests that only existed to lock the orphan) — see [incremental-implementation.md](incremental-implementation.md#dead-code-sweep-refactor) |
| Fewer lines, same behavior | Prefer deleting superseded code over leaving “might be useful” helpers; meet requirements with the **smallest** clear surface ([design-tradeoffs.md](design-tradeoffs.md)) |
| No unnecessary code | If logic exists upstream (merged PR / lib), call it; do not duplicate tables, skip wiring, or validation layers |
| Simple production code | Minimalism applies to **production** code, not to skipping edge-case tests |

**Structural remedies:** dispatcher vs conditional chains; move feature logic to owning package;
reuse canonical helper; split oversized files (~1000+ lines).

**Reference shape:** thin library + immutable data + one exported function + tests that iterate the data and cover edge inputs via tables or parameterized cases.

### Intent-revealing helpers (production and tests)

**Goal:** Make maintenance and code review **less taxing** — readers see **what contract holds** from names and reuse, not from decoding repeated lines.

| Situation | Action |
| --------- | ------ |
| One **behavioral rule** appears in many places (branches, asserts, setup) | Extract a **named function** whose name states the rule — production helper, test util, or small method on the type that owns the behavior |
| Several tests share the same **post-condition** after different inputs | Reuse one assertion helper (e.g. `assert_manufacturer_remains_identical`) or a table-driven suite; pair with a named helper for the **success** path when that clarifies intent (e.g. `assert_manufacturer_normalized_to`) |
| Reviewer or author asks “why these lines?” | Prefer a named helper over comment-only explanation when the name can carry the contract |
| Single call site, rule obvious in context | Inline is fine — do not extract for ceremony |

**Production:** conditional updates, guard clauses, and “only mutate when X” policies benefit from named functions when reused or non-obvious (e.g. overwrite a wire field only when normalization succeeds).

**Tests:** assert **outcomes** ([axis 1](#1-correctness--testing)); when the outcome *is* the contract (“raw input preserved on failure”), name that contract in the helper so each test reads as scenario + expected errors + **one intent line**.

**Not the same as** a thin wrapper around a single built-in with **no added semantics** — see simplicity row in axis 2.

### 3. Design & boundaries

Pragmatic [SOLID](https://www.designgurus.io/course-play/grokking-solid-design-principles/doc/solid-design-principles) — not pedantry:

| Principle | Practice |
| --------- | -------- |
| **S** | One reason to change per unit — one function, one outcome |
| **O** | Extend via types/composition, not editing stable core for every variant |
| **L** | Subtypes honor contracts |
| **I** | Narrow public APIs |
| **D** | Inject abstractions at boundaries; test with fakes |

Introduce abstractions when they improve maintainability and reasoning — document benefits when
complexity is justified ([design-tradeoffs.md](design-tradeoffs.md)). Single source of truth for
external field names and shared constants.

| Check | Action |
| ----- | ------ |
| Layer separation | Keep domain parse/validate/constants separate from record assembly and external serialization |
| Shared field logic | One resolver when validation and mapping read the same source field (including aliases) |
| Import graph | Assembly → domain only; update all callers when symbols move; avoid permanent re-export shims |
| Registry vs rules | Field registry for SSOT and introspection; **validation explicit** when rules diverge ([design-tradeoffs.md](design-tradeoffs.md)) |
| Indirection | Avoid generic callbacks/readers where the signature hides which field or alias is read — prefer named helpers |
| Ship for production | No milestone-only placeholders in code/API; tracker may describe phases ([design-tradeoffs.md](design-tradeoffs.md#production-vs-milestone-wording)) |

### 4. Security & data

- Validate input at boundaries; no secrets in code or logs
- Parameterized queries; safe defaults
- Fail closed on auth and permission checks

**OWASP Top 10 baseline** (when change touches auth, input, data, or dependencies — checklist;
deeper review: **`/code-review`** and optional global `security-and-hardening`):

| Risk area | Quick check |
| --------- | ----------- |
| Injection | Parameterized queries / bound params; no string-built SQL/shell |
| Broken auth | Session/token validation on protected paths; fail closed |
| Sensitive data | No secrets in repo/logs; minimize PII in errors |
| XSS / unsafe output | Encode or sanitize user-controlled output in UI/API |
| Misconfiguration | Secure defaults; no debug flags in production paths |
| Vulnerable components | Note dependency bumps; avoid known-bad versions without reason |
| Access control | Authorization checked server-side for each sensitive action |
| Logging & monitoring | Security-relevant failures logged without leaking secrets |

Not every PR needs every row — skip rows clearly out of scope and say so in the PR.

### 5. Performance (proportional)

- Hot-path changes: see [performance-optimization.md](performance-optimization.md)
- Flag N+1, unbounded work, missing pagination — only when plausible for this change

______________________________________________________________________

## Testing & structured contracts

When tests or APIs use structured records:

| Problem | Remedy |
| ------- | ------ |
| Magic literals in fixtures **and** separate asserts | Named constants; same names in fixture and assert |
| Copy-pasted tests differing only by input | One parameterized or table-driven test — rows must be **meaningful** (see axis 1) |
| Same behavioral post-condition asserted many ways | Shared intent-revealing helper in test utils ([Intent-revealing helpers](#intent-revealing-helpers-production-and-tests)) |
| External keys repeated in fixture, assert, production | Import from the schema registry or shared constants module |

Legacy aliases → **named resolver** shared by tests and production. Details:
[documentation-and-adrs.md](documentation-and-adrs.md) · [verification.md](verification.md#test-robustness).

______________________________________________________________________

## Optional extensions (read when spec/plan tags the domain)

| Extension | Apply when |
| --------- | ---------- |
| **API & contracts** | Public HTTP/GraphQL/events — versioning, error model, backward compatibility |
| **Observability** | Production services — logging, metrics, trace points for new paths |
| **Accessibility & UX** | User-facing UI — WCAG-oriented checks, keyboard/focus |
| **Operational readiness** | Deploy/migrate — rollback, feature flags, safe migrations |

______________________________________________________________________

## Author self-review checklist (quick)

Before `/pull-request` ready gate:

- [ ] Core axes 1–5 addressed for this diff
- [ ] No drive-by refactors outside PR scope
- [ ] Duplicated logic calls existing helpers
- [ ] Repeated behavioral rules use intent-revealing names (production or tests), not copy-pasted asserts/branches
- [ ] **Positive feedback:** note at least one thing the diff does well (for PR body or self-review)
- [ ] Invoke **`/code-review`** on the task PR before `gh pr ready` ([SKILL.md](SKILL.md) Phase 9b)
