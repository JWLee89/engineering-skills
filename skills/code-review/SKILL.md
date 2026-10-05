---
name: code-review
version: "1.0.0"
domain: quality
role: reviewer
scope: pull-request
triggers:
  - /code-review
  - review this PR
  - code review
related-skills:
  - handle-task
  - pull-request
  - engineering-rubric
description: >-
  Deep pull-request review for a user-specified PR: fetch PR, linked work items, and codebase
  fresh (no prior chat context), apply an eight-axis senior-engineer rubric, draft findings
  with links and snippets in markdown, wait for user approval, then optionally post forge
  review comments. Portable across repos and issue trackers. Does not push commits. Use when
  the user says code review, review this PR, /code-review with a PR link or number, or
  /handle-task Phase 9b on the task PR.
disable-model-invocation: true
---

# Code review

**Invoke:** `/code-review` · **Companions:** `/pull-request`, `/handle-task`, `/review-ticket` ·
**Entry:** [workflow.md](workflow.md) by phase ([Load when](#load-when-do-not-read-the-whole-folder)).

**Project config (optional):** load `.handle-task/project.yaml` when present — schema in
[../project-config.md](../handle-task/project-config.md). The skill works without it; infer conventions
from the target repo.

```
RESOLVE PR → GATHER CONTEXT → RUBRIC → DRAFT MD → USER APPROVAL → [POST REVIEW]
```

## Load when (do not read the whole folder)

| Phase | Read | Defer |
| ----- | ---- | ----- |
| Start | This file, [workflow.md](workflow.md) Phase 0–1 | [rubric.md](rubric.md) until intent checkpoint |
| Context | workflow Phase 2, PR Focus areas if present | Full handle-task bundle |
| Rubric | [rubric.md](rubric.md) | [references/review-guide.md](references/review-guide.md) unless tracing spec/Jeffallan |
| Draft | [references/report-template.md](references/report-template.md), workflow Phase 4 | Publish rules until user approves draft |

Reference map: [references/review-guide.md](references/review-guide.md).

## Required input

The user must specify **which PR** to review:

- PR URL on any supported forge, or
- PR number (`#123`) when the workspace remote identifies the repo, or
- Head branch name (agent resolves via the forge CLI)

If omitted → **ask** for a link or number. Do not guess from the current branch unless the user confirms.

## Session isolation

Treat each `/code-review` as a **standalone audit**. Do not use contextual information from
previous conversations. Re-fetch the PR, linked work items, CI, and relevant codebase paths in
this session.

## Persona

Very senior engineer: highest bar for correctness, design, tests, and reviewability before
main. Be **kind and respectful** — reviews should improve the code while the author feels
**empowered, respected, and encouraged** to refine the patch. See [rubric.md](rubric.md).

## What this skill does

1. **Resolve** the target PR (or ask).
2. **Gather** PR body, diff, checks, comments, linked work items, docs, and surrounding code.
3. **Review** using the eight-axis rubric in [rubric.md](rubric.md).
4. **Draft** all findings in markdown ([references/report-template.md](references/report-template.md)) with severity,
   context links (PR lines, work items, documentation), and code excerpts.
5. **Wait** for explicit user approval of the draft.
6. **Optionally publish** forge review comments after approval — never before.
7. **Never push commits** until the user approves the review and separately requests fixes.

## Distinction from author review

| Artifact | Role |
| -------- | ---- |
| **`/code-review`** (this skill) | Reviewer pass — [rubric.md](rubric.md); draft → approve → post |
| [../engineering-rubric.md](../handle-task/engineering-rubric.md) | Author implement + self-review ([../code-review.md](../handle-task/code-review.md) pointer) |

## Boundaries

- **Always:** full rubric; draft before post; context on every finding; PR-introduced vs pre-existing for bugs
- **Never:** merge PR; push without user request; skip draft gate; rely on stale chat context
- **Ask first:** posting review to the forge; running long integration tests; reviewing a different repo than workspace

## See also

- [workflow.md](workflow.md) — phases, commands, draft template, publish rules
- [rubric.md](rubric.md) — review criteria (single source of truth)
- [../issue-tracker-adapters.md](../handle-task/issue-tracker-adapters.md) — linked work items by tracker type
- [../documentation-and-adrs.md](../handle-task/documentation-and-adrs.md) — ADRs and wire-format conventions
