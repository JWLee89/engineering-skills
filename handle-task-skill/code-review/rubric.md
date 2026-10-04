# Code review rubric

**Single source of truth** for **`/code-review`**. Do not duplicate criteria elsewhere — link here.

**Shared implementation bar** (correctness, design, tests, security, perf): defined in
[../engineering-rubric.md](../engineering-rubric.md). This file adds **reviewer-only** checks
(PRD/intent drift, introduced vs pre-existing, repo-wide duplicate search, severity/verdict).

Persona: **very senior engineer** — block merge when quality is not production-grade.

**Tone:** Kind and respectful; critique code, not the person.

Author self-review: [../code-review.md](../code-review.md) → [../engineering-rubric.md](../engineering-rubric.md).

______________________________________________________________________

## 1. Question (right thing, done right)

| Check | What to verify |
| ----- | -------------- |
| Engineering best practices | [../engineering-rubric.md](../engineering-rubric.md) + project conventions |
| Right thing to build | Aligns with PR purpose, linked work items, product constraints |
| Definition of done | PR / tracker DoD / referenced spec — satisfied or explicitly deferred |

**Output:** Gaps between **intent** and **implementation**.

______________________________________________________________________

## 2. Bugs

| Check | What to verify |
| ----- | -------------- |
| Defects | Logic, types, races, leaks, off-by-one, null/empty paths |
| Smells → bugs | Fragile conditionals, swallowed errors, mutable shared state |
| Origin | **Introduced by this PR** vs **pre-existing** |
| Spec soundness | Approach coherent given constraints |

**Output:** Repro steps or minimal failing snippet when possible.

______________________________________________________________________

## 3. Software design

Apply **Design & boundaries** from [../engineering-rubric.md](../engineering-rubric.md).

**Reviewer focus:** Does this PR's structure block the next change? Suggest concrete redesign if yes.

______________________________________________________________________

## 4. Tests

Apply **Correctness & testing** from [../engineering-rubric.md](../engineering-rubric.md).

**Reviewer focus:** Table requirement → test file/name; **gaps**; integration when boundaries crossed.
Cross-check [../spec-adherence.md](../spec-adherence.md) when PR references a spec.

______________________________________________________________________

## 5. Code duplicates

| Check | What to verify |
| ----- | -------------- |
| New vs existing | Search repo; prefer reuse per [../incremental-implementation.md](../incremental-implementation.md) |
| Within PR | Copy-paste that should share a helper |

**Output:** Canonical path + line ranges on both sides.

______________________________________________________________________

## 6. Code smells

Apply **Clarity & maintainability** from [../engineering-rubric.md](../engineering-rubric.md).

**Reviewer focus:** Missing **why** comments on non-obvious rules; error-prone patterns (bare except, unchecked casts).

Wire formats: [../documentation-and-adrs.md](../documentation-and-adrs.md).

______________________________________________________________________

## 7. Optimizations

Apply **Performance** from [../engineering-rubric.md](../engineering-rubric.md) — flag only plausible impact.

______________________________________________________________________

## 8. Documentation

| Check | What to verify |
| ----- | -------------- |
| PR / code docs | Background, verification, ADR links, public docstrings |
| Onboarder test | PR + diff explain **what** and **why** without oral history |

______________________________________________________________________

## Severity labels

| Label | Meaning |
| ----- | ------- |
| **Blocker** | Must fix — correctness, security, spec violation, missing critical tests |
| **Major** | Should fix now or track — design debt that hurts next change |
| **Minor** | Readability nits, low risk |
| **Question** | Clarification — not necessarily a defect |

## Verdict

| Verdict | When |
| ------- | ---- |
| **Request changes** | Any Blocker, or multiple Majors without deferral |
| **Approve with nits** | No Blockers; Majors acknowledged or fixed |
| **Approve** | No Blocker/Major |

Human merge remains the user's call.
