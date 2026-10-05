# Code review draft template

Copy for Phase 4 of [workflow.md](../workflow.md). Default path: `code-review-PR-<num>.md` (repo root or `/tmp/`).

```markdown
# Code review: PR #<num> — <title>

**PR:** <url>
**Branch:** `<head>` → `<base>`
**Work items:** <keys + links>
**Reviewer persona:** Senior engineer — rigorous, kind, respectful (/code-review)
**Verdict (draft):** Request changes | Approve with nits | Approve

## PR intent (checkpoint)
<One sentence — what this PR is meant to accomplish>

## Summary
<2–4 sentences: strengths, overall quality, merge recommendation>

## Positive feedback
<Required when merge-worthy: specific patterns, tests, or design choices>

## Context used
- PR description (+ gaps)
- Work items: …
- Docs: …
- CI: n/a / pending (run URL) / pass/fail + check names

## Findings

### Blockers
#### B1. <title> (Axis: …)
**Context:** [PR diff](…) · [<KEY> DoD: "…"]
**Issue:** …
**Evidence:**
```<lang>
<snippet>
```
**Suggestion:** …

### Major
…

### Minor
…

### Questions
…

## Rubric checklist
| # | Axis | Status | Notes |
|---|------|--------|-------|
| 1 | … | OK/… | … |

## Test traceability
| Requirement | Test(s) | Gap? |
|-------------|---------|------|

## Verification notes
<commands run, or "not run — reason">

## Pre-existing issues noticed (not blocking unless PR regresses)
…
```

After draft: **stop** for user approval before forge publish ([workflow.md Phase 5](../workflow.md#phase-5-publish-only-after-user-approval)).
