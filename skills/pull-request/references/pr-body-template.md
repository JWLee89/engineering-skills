# PR body template (copy for agents)

Industry-aligned author template. **Example filled:** [PR #8](https://github.com/JWLee89/engineering-skills/pull/8).
**Review-side counterpart (Jeffallan):** [code-reviewer report-template](https://github.com/Jeffallan/claude-skills/blob/main/skills/code-reviewer/references/report-template.md).

Replace `{owner}`, `{repo}`, `{n}`, `{sha}`, `{TICKET}` before posting.

```markdown
## Background

<Problem space and constraints. What existed before this change?>

- Issue: [{TICKET}](<tracker-url>)
- Spec / design: <link to local spec path, ADR, or committed task memory — enables spec-compliance review>

## Purpose

<Single paragraph: what this PR delivers and why now.>

## Review guide

### Summary for reviewers

<2–4 sentences: approach, risky/subtle areas, what to skip.>

### Commits

| Commit | Message (short) | What changed (human) |
| ------ | --------------- | -------------------- |
| [shortsha](https://github.com/{owner}/{repo}/commit/{fullsha}) | subject | plain-language delta |

**Start here:** [Review all changes on this PR](https://github.com/{owner}/{repo}/pull/{n}/changes)

### Focus areas (read in this order)

1. **Review:** [path Lstart–Lend (this PR)](https://github.com/{owner}/{repo}/pull/{n}/changes#diff-{sha256_path}Rstart-Rend) ·
   **Source:** [Lstart–Lend](https://github.com/{owner}/{repo}/blob/{sha}/path?plain=1#Lstart-Lend) —
   <why read this>. Commit [shortsha](https://github.com/{owner}/{repo}/commit/{fullsha}).

## Changes made

| Layer | Change | Δ lines |
| ----- | ------ | ------- |
| <layer> | <one line> | **+N / −M** |

## Verification

### Steps run (author)

- [x] `<command>` — exit 0; <evidence>; commit [shortsha](https://github.com/{owner}/{repo}/commit/{sha})

### Test plan (reviewer / CI)

- [ ] Reviewer: follow focus areas above; confirm behavior matches Purpose
- [ ] CI: <workflow name or n/a>

### Test coverage (when code changes)

- [ ] Happy path covered
- [ ] Error / edge paths covered
- [ ] Spec criteria traced (see spec link in Background)

### Out of scope

- <deferred item>
```

Mechanics for `#diff-{sha256_path}`: [workflow.md Phase 2](../workflow.md#phase-2-review-friendly-pr-plan--verification-plan).
