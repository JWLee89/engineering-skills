# Engineering rubric

**Single source of truth** for **writing code** and **author self-review** (`/handle-task` Phase 7,
`/pull-request` Phase 6). Do not duplicate these axes elsewhere — link here.

For **deep PR review** by a reviewer pass, use **`/code-review`** → [code-review/rubric.md](code-review/rubric.md).
For **ticket text quality**, use [review-ticket/quality-gate.md](review-ticket/quality-gate.md).

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
| Edge / error paths | Cover null, empty, boundaries, and handled failure modes |

**Red flags:** production logic without tests for new behavior; "green" without spec traceability.

### 2. Clarity & maintainability

| Check | Action |
| ----- | ------ |
| Naming | Matches project conventions (`memory.agent_guide`, existing modules) |
| Simplicity | Prefer boring code; no unnecessary cleverness |
| Reuse | Search first ([incremental-implementation.md](incremental-implementation.md)); extend before rewrite |
| Minimal diff | Only what the task requires |

**Structural remedies:** dispatcher vs conditional chains; move feature logic to owning package;
reuse canonical helper; split oversized files (~1000+ lines).

### 3. Design & boundaries

Pragmatic [SOLID](https://www.designgurus.io/course-play/grokking-solid-design-principles/doc/solid-design-principles) — not pedantry:

| Principle | Practice |
| --------- | -------- |
| **S** | One reason to change per unit |
| **O** | Extend via types/composition, not editing stable core for every variant |
| **L** | Subtypes honor contracts |
| **I** | Narrow public APIs |
| **D** | Inject abstractions at boundaries; test with fakes |

New abstraction only when duplication removal **and** clarity both improve. Single source of truth
for constants and wire keys.

### 4. Security & data

- Validate input at boundaries; no secrets in code or logs
- Parameterized queries; safe defaults
- Fail closed on auth and permission checks

### 5. Performance (proportional)

- Hot-path changes: see [performance-optimization.md](performance-optimization.md)
- Flag N+1, unbounded work, missing pagination — only when plausible for this change

______________________________________________________________________

## Testing & wire formats (Python / typed models)

When tests or APIs use structured records:

| Problem | Remedy |
| ------- | ------ |
| Magic numbers in fixtures **and** separate asserts | Named constants; same names in fixture and assert |
| Copy-pasted tests differing only by input | `@pytest.mark.parametrize` |
| Wire keys repeated in fixture, assert, production | Derive from `fields(Model)` / `asdict()`; keys defined once in model module |

Legacy aliases → **named constants** on the type or module. Details:
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
- [ ] Invoke **`/code-review`** on the task PR before `gh pr ready` ([SKILL.md](SKILL.md) Phase 9b)
