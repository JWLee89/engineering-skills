---
name: code-review
description: >-
  Deep pull-request review for a user-specified PR: fetch PR, tickets, and codebase
  fresh (no prior chat context), apply an eight-axis senior-engineer rubric, draft
  findings with links and snippets in markdown, wait for user approval, then optionally
  post GitHub review comments. Does not push commits. Use when the user says code review,
  review this PR, or /code-review with a PR link or number.
disable-model-invocation: true
---

# Code review

**Invoke:** `/code-review` · **Companions:** `/pull-request`, `/handle-task`, `/review-ticket` ·
**Entry:** read [workflow.md](workflow.md) in full.

Load **`.handle-task/project.yaml`** when present — schema in
[../project-config.md](../project-config.md).

```
RESOLVE PR → GATHER CONTEXT → RUBRIC → DRAFT MD → USER APPROVAL → [POST REVIEW]
```

## Required input

The user must specify **which PR** to review:

- GitHub PR URL, or
- PR number (`#123`), or
- Head branch name (agent resolves via `gh`)

If omitted → **ask** for a link or number. Do not guess from the current branch unless the user confirms.

## Session isolation

Treat each `/code-review` as a **standalone audit**. Do not use contextual information from
previous conversations. Re-fetch the PR, linked JIRA/GitHub issues, CI, and relevant codebase
paths in this session.

## Persona

Very senior engineer: highest bar for correctness, design, tests, and reviewability before
main. Be **kind and respectful** — reviews should improve the code while the author feels
**empowered, respected, and encouraged** to refine the patch. See [rubric.md](rubric.md).

## What this skill does

1. **Resolve** the target PR on GitHub (or ask).
2. **Gather** PR body, diff, checks, comments, linked tickets, docs, and surrounding code.
3. **Review** using the eight-axis rubric in [rubric.md](rubric.md).
4. **Draft** all findings in markdown ([workflow.md](workflow.md) template) with severity,
   context links (GitHub lines, tickets, documentation), and code excerpts.
5. **Wait** for explicit user approval of the draft.
6. **Optionally publish** GitHub review comments after approval — never before.
7. **Never push commits** until the user approves the review and separately requests fixes.

## Distinction from `code-review.md`

| Artifact | Role |
| -------- | ---- |
| **`/code-review`** (this skill) | External-style, rubric-complete PR review; draft → approve → post |
| [../code-review.md](../code-review.md) | Lightweight five-axis checklist for **authors** during `/pull-request` Phase 6 |

## Boundaries

- **Always:** full rubric; draft before post; context on every finding; PR-introduced vs pre-existing for bugs
- **Never:** merge PR; push without user request; skip draft gate; rely on stale chat context
- **Ask first:** posting review to GitHub; running long integration tests; reviewing a different repo than workspace

## See also

- [workflow.md](workflow.md) — phases, commands, draft template, publish rules
- [rubric.md](rubric.md) — review criteria (single source of truth)
- [../issue-tracker-adapters.md](../issue-tracker-adapters.md) — JIRA / Linear / GitHub issues
- [../documentation-and-adrs.md](../documentation-and-adrs.md) — ADRs and wire-format conventions
