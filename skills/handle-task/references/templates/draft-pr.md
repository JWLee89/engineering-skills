## Draft PR title

Expand `pr.title_format` from `.handle-task/project.yaml`:

```
[{prefix}-{number}]({tag}): {summary}
```

Example: `[PROJ-42](feat): Add user authentication endpoint`

| Part        | Rule                                                             |
| ----------- | ---------------------------------------------------------------- |
| `{tag}`     | Primary semantic type (`commit.tags`: `feat`, `fix`, `chore`, …) |
| `{summary}` | What the PR delivers — not the full issue title                   |

PR titles use a colon after `({tag})`. Commits use a space: `[PROJ-42](feat) Summary`.

______________________________________________________________________

## Draft PR body (local — not committed)

Use after commits + verify, when the user approves opening a PR. **Always** create with
`gh pr create --draft`. Full workflow: [pull-request.md](pull-request.md).

**Reviewer-friendly shape (required):** [../pull-request/references/reviewer-friendly-pr-body.md](../pull-request/references/reviewer-friendly-pr-body.md).
**Example:** [engineering-skills PR #8](https://github.com/JWLee89/engineering-skills/pull/8).

```markdown
## Background

<Problem space and ticket context. Link parent epic or blocking tickets if relevant.
Mention constraints from committed decision log when configured.>

- Issue: [{TICKET-KEY}](<url from url_template>)
- Task memory: `{memory.committed_tasks}/<ticket_key_lower>-<slug>.md` (if configured)
- Local spec: `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md` (not committed)

## Purpose

<Single clear statement of what this PR delivers and why now.>

## Review guide

### Summary for reviewers

<2–4 sentences: approach, subtle/risky areas, what to skip.>

### Commits

| Commit | Message (short) | What changed (human) |
| ------ | --------------- | -------------------- |
| [<shortsha>](https://github.com/{owner}/{repo}/commit/{fullsha}) | `<subject>` | <plain-language delta> |

**Start here:** [Review all changes on this PR](https://github.com/{owner}/{repo}/pull/{n}/changes)

### Focus areas (read in this order)

1. **Review:** [file.py Lstart–Lend (this PR)](https://github.com/{owner}/{repo}/pull/{n}/changes#diff-{sha256_path}Rstart-Rend) ·
   **Source:** [Lstart–Lend](https://github.com/{owner}/{repo}/blob/{head_sha}/path/to/file.py#Lstart-Lend) —
   <why a reviewer should read this>. Commit [<shortsha>](https://github.com/{owner}/{repo}/commit/{fullsha}).

For `.md` source links use `?plain=1` before `#L`. `sha256_path` = SHA-256 hex of repo-relative path — [pull-request/workflow.md](../pull-request/workflow.md).

<Core logic → wiring → config → tests. Refresh diff anchors after each push — [pull-request/workflow.md](../pull-request/workflow.md).>

## Changes made

| Layer | Change | Δ lines |
| ----- | ------ | ------- |
| <e.g. Tests> | <one-line summary> | **+N / −M** (net ±K) |

Populate from `git diff origin/<base>...HEAD --numstat` (group by layer). Bold Δ when \|net\| > 100 or row is the main story. Optional file-level table for top churn paths.

- <Explicit "not in this PR" only under Verification → Out of scope>

## Verification

### Steps run (author)

- [ ] `<commands from verify.commands>`

### Test plan (reviewer / CI)

- [ ] Reviewer: smoke steps if any manual checks apply
- [ ] CI: <workflow name> — especially for tests not runnable locally

### Out of scope

- <Follow-up ticket or deferred wiring>
```

**Agent prompt after commit (copy/adapt):**

> Commits for {TICKET-KEY} are on branch `{TICKET-KEY}`. Verify: \[passed commands\].
> Gaps: \[CI-only tests\]. Should I run `/pull-request` (draft PR + verification plan +
> CI watch)?

**Agent prompt at finalize (copy/adapt):**

> CI green on run \[link\]. Code review pass complete. Updating PR description, marking
> ready for review, and transitioning issue to ready-for-review (per
> `status_transitions.pr_ready` in config).
