# Code review rubric

**Single source of truth** for `/code-review`. Do not duplicate criteria elsewhere — link here.

Persona: **very senior engineer** — block merge when quality, correctness, or maintainability
is not production-grade. Approve only when you would trust this on main without reservation.

**Tone:** Be **kind and respectful** in every comment. Code review exists to raise quality
**and** to leave the author **empowered, respected, and encouraged** to improve the patch.
Critique the code and design, not the person; be direct about issues without condescension,
sarcasm, or pile-on.

Reference: [SOLID design principles](https://www.designgurus.io/course-play/grokking-solid-design-principles/doc/solid-design-principles).

For lightweight author self-review during `/pull-request` Phase 6, see [../code-review.md](../code-review.md)
(five-axis checklist). **`/code-review`** is the full external-style pass with draft comments.

______________________________________________________________________

## 1. Question (right thing, done right)

| Check | What to verify |
| ----- | -------------- |
| Engineering best practices | Matches project conventions (agent guide from config, `CONTRIBUTING.md`, existing patterns) |
| Right thing to build | Change aligns with stated purpose, linked work items, and product constraints |
| Definition of done | PR body / tracker DoD / local spec (if referenced) — each item satisfied or explicitly deferred |

**Output:** Call out gaps between **intent** (work item, PR background/purpose) and **implementation**.

______________________________________________________________________

## 2. Bugs

| Check | What to verify |
| ----- | -------------- |
| Engineering bugs | Logic errors, wrong types, race conditions, resource leaks, off-by-one, null/empty paths |
| Code smells that become bugs | Fragile conditionals, silent swallowing of errors, mutable shared state |
| Origin | Tag each finding: **introduced by this PR** vs **pre-existing** (still note if PR touches the area) |
| Spec soundness | If a spec/ticket exists — is the technical approach coherent given constraints? |

**Output:** Repro steps or a minimal snippet showing failure when possible.

______________________________________________________________________

## 3. Software design

| Check | What to verify |
| ----- | -------------- |
| SOLID | SRP (one reason to change), OCP (extension vs modification), LSP, ISP, DIP — pragmatically, not pedantically |
| Scalability / maintainability | Module boundaries, dependency direction, feature ownership |
| Abstraction | New layers earned by duplication removal **and** clarity — not one-off indirection |

**Output:** Concrete redesign suggestion when structure blocks future change.

______________________________________________________________________

## 4. Tests

| Check | What to verify |
| ----- | -------------- |
| Validates functionality | Tests assert behavior/outcomes, not implementation trivia |
| Coverage depth | Happy path + meaningful edge cases; error paths where production handles them |
| Missing cases | Propose edge cases that **would break** the feature; include a failing test sketch or snippet |
| Integration | If the feature crosses boundaries (API, services, persistence, wire format), integration tests prove end-to-end intent |

Cross-check [../spec-adherence.md](../spec-adherence.md) when the PR references a spec.

**Output:** Table mapping requirement → test file/test name, with **gaps** highlighted.

______________________________________________________________________

## 5. Code duplicates

| Check | What to verify |
| ----- | -------------- |
| New vs existing | Search repo for same or near-same logic; prefer extend/reuse per [../incremental-implementation.md](../incremental-implementation.md) |
| Within PR | Copy-paste across files that should share a helper |

**Output:** Link to canonical implementation to reuse; cite line ranges on both sides.

______________________________________________________________________

## 6. Code smells

| Check | What to verify |
| ----- | -------------- |
| Maintainability / readability | Naming, nesting, function size, magic numbers |
| Comments | Missing **why** on non-obvious business or protocol rules; flag comment noise |
| Refactor opportunities | Local transforms that reduce error rate without scope creep |
| Error-prone patterns | Bare except, unchecked casts, implicit assumptions — suggest robust rewrite |

Wire-format duplication: [../documentation-and-adrs.md](../documentation-and-adrs.md) (derive keys from models).

______________________________________________________________________

## 7. Optimizations

| Check | What to verify |
| ----- | -------------- |
| Hot paths | Loops, per-request work, repeated I/O or allocation in code called at scale |
| Proportional fix | Measure-first when uncertain — see [../performance-optimization.md](../performance-optimization.md) |

**Output:** Only flag when impact is plausible; suggest approach, not premature micro-opts.

______________________________________________________________________

## 8. Documentation

| Check | What to verify |
| ----- | -------------- |
| PR / code docs | Background, verification, ADR links, module docstrings where public surface changes |
| Onboarder test | Could someone with little context understand **what** and **why** from PR + diff alone? |

______________________________________________________________________

## Severity labels (use on every finding)

| Label | Meaning |
| ----- | ------- |
| **Blocker** | Must fix before merge — correctness, security, spec violation, missing critical tests |
| **Major** | Should fix in this PR or tracked immediately — design debt that will hurt the next change |
| **Minor** | Improve when touching the file — readability, nits with low risk |
| **Question** | Clarification for author — not necessarily a defect |

## Verdict (draft report footer)

| Verdict | When |
| ------- | ---- |
| **Request changes** | Any Blocker, or multiple Majors without accepted deferral |
| **Approve with nits** | No Blockers; Majors acknowledged or fixed |
| **Approve** | No Blocker/Major; ready for human merge decision |

Human merge remains the user's call — this skill does not merge.
