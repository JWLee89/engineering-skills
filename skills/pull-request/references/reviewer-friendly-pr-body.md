# Reviewer-friendly PR body

**Goal:** A reviewer who has **not** read the ticket thread can understand **what** changed,
**why**, and **where to look** — with clickable links into the PR diff and source.

**Gold example (this repo):** [PR #8 — add /code-review sub-skill](https://github.com/JWLee89/engineering-skills/pull/8)

Mechanics (diff anchors, `?plain=1`, SHA-256 path): [workflow.md Phase 2](../workflow.md#phase-2-review-friendly-pr-plan--verification-plan).

______________________________________________________________________

## Required sections (order)

| Section | Reader gets |
| ------- | ----------- |
| **Background** | Problem space, constraints, what existed before |
| **Purpose** | One clear “what this PR delivers and why now” |
| **Review guide** | Onboarding path — summary, commits, **Start here**, numbered **Focus areas** with links |
| **Changes made** | Layer table with **Δ lines** (not a raw file list) |
| **Verification** | Author steps (checked + evidence), reviewer/CI plan, **Out of scope** |

Do **not** ship a PR with only a “Summary” bullet list. Use `/pull-request` Phase 2.

______________________________________________________________________

## Review guide (required subsections)

### Summary for reviewers

2–4 sentences: approach, risky/subtle areas, what to skip (generated files, HAC-only, etc.).

### Commits

| Commit | Message (short) | What changed (human) |
| ------ | --------------- | -------------------- |
| [shortsha](https://github.com/{owner}/{repo}/commit/{fullsha}) | subject | plain-language delta |

Build from `git log origin/<base>..HEAD --format='%h %s' --reverse`.

### Start here

After the PR exists:

```markdown
**Start here:** [Review all changes on this PR](https://github.com/{owner}/{repo}/pull/{n}/changes)
```

### Focus areas (read in this order)

Number **3–7** items (small PR: up to 5). Order: **core logic → wiring → config → tests**.

Each item includes:

1. **Review:** `[path Lstart–Lend (this PR)](…/pull/{n}/changes#diff-{sha256}Rstart-Rend)` — primary link
2. **Source:** optional blob at PR tip; use `?plain=1` before `#L` for markdown
3. One sentence **why** a reviewer should read this hunk
4. **Commit** link when multi-commit PRs tell a story

Example shape (from [PR #8](https://github.com/JWLee89/engineering-skills/pull/8)):

```markdown
1. **Review:** [workflow.md L1–L50 (this PR)](…/pull/8/changes#diff-…) ·
   **Source:** [L1–L50](…/blob/{sha}/skills/code-review/workflow.md?plain=1#L1-L50) —
   Hard rules (tone, PR required, draft gate). Commit [d4100f0](…/commit/d4100f0…).
```

Refresh focus areas and line numbers after every significant push.

______________________________________________________________________

## Changes made (required table)

From `git diff origin/<base>...HEAD --numstat` — group by **layer** (product, tests, skills, CI, docs):

```markdown
| Layer | Change | Δ lines |
| ----- | ------ | ------- |
| Skills | New `code-review/` entry skill | **+452** |
| Tooling | `install-skills.sh` registers skill | **+8 / −1** |
```

Bold Δ when \|net\| > 100 or the row is the main story.

______________________________________________________________________

## Verification

Under `## Verification`, always include:

- **Steps run (author)** — `- [x]` with command, exit code, commit or CI URL
- **Test plan (reviewer / CI)** — what humans/CI should confirm
- **Out of scope** — explicit deferrals

Template blocks: [templates.md#verification-plan-pr-body](../../handle-task/templates.md#verification-plan-pr-body).

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| File list with no line links | Focus areas with PR `#diff-…R` anchors |
| Backtick SHAs only | Markdown links to `/commit/{sha}` |
| Stale line numbers after push | Re-run Phase 2; update body |
| Duplicate entire diff in prose | Summary + linked hunks + Changes made Δ |
