# Spec adherence verification

Standalone delegate for `/handle-task` Phase 7 (after each slice) and Phase 8 (before PR handoff).

**Purpose:** prove implementation and tests satisfy the **approved spec** — not just that tests pass.
Catch shortcuts over core business requirements, success criteria, and **non-negotiables** before merge.

## When to run

| Timing | Scope |
| ------ | ----- |
| **End of each behavioral slice** | Acceptance criteria for that slice only |
| **Phase 8 (full verify)** | All spec success criteria + testing strategy table |
| **User reports a gap** | Re-audit; fix tests/code; notify user |

**Skip** for docs-only slices with no behavioral acceptance criteria.

## Audit process

1. **Open the approved spec** — `{local_specs}/<ticket>/SPEC-*.md` (and capability map if multi-module).
2. **Build a traceability matrix** — every success criterion and non-negotiable maps to evidence:

| Spec item | Type | Evidence (test / code / CI) | Status |
| --------- | ---- | --------------------------- | ------ |
| … | success criterion / boundary / non-negotiable | `tests/...::test_foo` or file:line | ✅ / ⚠️ gap / ❌ missing |

3. **Classify gaps:**

   | Severity | Meaning | Action |
   | -------- | ------- | ------ |
   | **Blocker** | Core requirement or non-negotiable untested or unimplemented | Fix before next slice or PR |
   | **Gap** | Spec scenario listed but no test (e.g. mixed-push, edge case) | Add test + code; tell user |
   | **Deferred** | Explicitly out of scope in spec | Document in task memory + PR |
   | **CI-only** | Cannot prove locally | Note in PR verification; plan CI scenario |

4. **Anti-shortcut checks** — ask explicitly:

   - Did tests assert **behavior** from the spec, or only implementation details?
   - Are **negative paths** covered (skip when should skip, reject when should reject)?
   - Do tests use **production path** (real config, enums, loaders) not parallel fake constants?
   - Does any spec **testing strategy row** lack a unit or CI scenario?
   - Were **boundaries / Never** rules violated?

5. **Report to user** when any Blocker or Gap exists:

   > **Spec adherence:** N items fully covered, M gaps found.
   > - [Gap] … — adding test `…` / fixing …
   > Approve deferrals or confirm fix direction.

   Do **not** silently ship partial spec coverage.

6. **Fix loop:** add missing tests (RED first if new behavior) → GREEN → re-run matrix until
   Blockers cleared or user accepts documented deferral.

## Non-negotiables

Treat as **Blocker** if missing:

- Spec **Boundaries → Never** and **Out of scope** violations
- Ticket **DoD** items marked in scope
- User-stated non-negotiables from spec approval (assumptions they did *not* correct)
- Regressions on existing behavior the spec says must be preserved

## Output artifacts

- **Task session log** — brief gap/fix notes under committed task memory
- **PR verification** — spec matrix summary or link; unchecked items need user ack
- **Self-improvement** — if the gap was a **process** failure (skill didn't catch it), follow
  [self-improvement.md](self-improvement.md)

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| "Tests pass" = spec done | Run traceability matrix |
| Happy-path-only tests | Map spec scenarios including skip/error/mixed cases |
| Duplicated test constants drift from production | Single source (enum, JSON loader, `fields()`) |
| Deferring spec item without user notice | Report Gap; get explicit ack |
| Skipping audit because slice "felt done" | Matrix after every behavioral slice |

## Cross-references

- [test-driven-development.md](test-driven-development.md) — tests derive from acceptance criteria
- [verification.md](verification.md) — commands after adherence audit
- [code-review.md](code-review.md) — second pass before PR ready
