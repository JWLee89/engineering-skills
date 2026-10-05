# Pull request — workflow

Create, **update**, and harden pull requests until they are **merge-ready**: clear
description, green CI, conflicts resolved, review feedback addressed, and code quality
suitable for human review.

**Portable:** load **`.handle-task/project.yaml`** first ([../project-config.md](../handle-task/project-config.md)).
If missing, infer from `CONTRIBUTING.md`, `Makefile`, `package.json`, and ask once.

**Single source of truth:** `skills/pull-request/` (symlinked as `/pull-request`).

**Delegates (in `skills/handle-task/`):**

| Need | File |
| ---- | ---- |
| Local verify | [../verification.md](../handle-task/verification.md) (agentic evidence **required**) |
| Isolation gates | [../feature-gating.md](../handle-task/feature-gating.md) |
| Author self-review | [../engineering-rubric.md](../handle-task/engineering-rubric.md) |
| Deep PR review | [../code-review/workflow.md](../code-review/workflow.md) (`/code-review`) |
| Performance | [../performance-optimization.md](../handle-task/performance-optimization.md) |
| ADR / why docs | [../documentation-and-adrs.md](../handle-task/documentation-and-adrs.md) |

Also: user `creating-pull-requests` rule; `ci-investigator` subagent for a single failing check.

______________________________________________________________________

## When to use

- User says `/pull-request`, "open PR", "update the PR", "fix CI", "address review"
- After `/handle-task` implementation is complete
- **Existing PR:** CI red, merge conflicts, reviewer comments, scope creep, or description drift
- User wants history squashed, body refreshed, or branch rebased onto latest base

**When NOT to use:** spec/plan not approved; greenfield implementation not started; trivial
one-liner with no PR expected.

______________________________________________________________________

## Workflow overview

```
CONFIG → PRE-FLIGHT → PLAN (body + Δ lines + verification)
  → CREATE/UPDATE PR → VERIFY → FIX (CI | conflicts | review | quality) → REVIEW → READY
```

Checklist:

```
- [ ] Project config loaded
- [ ] Pre-flight: git diff vs base; existing PR; tracker comments if configured
- [ ] Changes made table includes Layer | Change | Δ lines (from git diff --numstat)
- [ ] Review guide: human summary + **clickable** commit/file line links (not backtick-only)
- [ ] Verification plan: author steps + CI workflows (unchecked until run)
- [ ] Draft PR created OR open PR body/branch updated
- [ ] CI green with run URLs; conflicts resolved if any
- [ ] Review feedback triaged (fixed or replied with rationale)
- [ ] Pre-merge code review: no blockers
- [ ] gh pr ready only after ready gate
```

______________________________________________________________________

## Phase 0: Load project config

Read `.handle-task/project.yaml` when present. Note `git.pr_target`, `verify.*`, `pr.*`,
`integrations.issue_tracker`.

______________________________________________________________________

## Phase 1: Pre-flight

Run in parallel where possible:

```bash
git status
git fetch origin <base>
git log origin/<base>..HEAD --oneline
git log origin/<base>..HEAD --format='%h %s'
git diff origin/<base>...HEAD --stat
git diff origin/<base>...HEAD --numstat
```

For the **Review guide** (multi-commit PRs), map commits to files and line anchors:

```bash
git log origin/<base>..HEAD --format='%h %s' --reverse
git show --stat --oneline <sha>
git diff origin/<base>...HEAD -U0 -- <path>
```

**Focus-area URLs:** [references/pr-diff-links.md](references/pr-diff-links.md) (after PR exists, refresh `/pull/{n}/changes#diff-…` in Phase 3/4).

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
git rev-parse HEAD
git rev-parse --short HEAD
gh pr view --json number,url -q .url
```

```bash
gh pr list --head "$(git branch --show-current)" --json number,state,isDraft,url,mergeable
```

- Task memory (`memory.committed_tasks`), local spec gaps
- Issue tracker: new comments since last push (when MCP configured)
- **Blockers:** secrets in diff; local-only spec files staged

If a PR already exists, treat this as an **update** pass — do not open a duplicate.

______________________________________________________________________

## Phase 2: Review-friendly PR plan + verification plan

Build **before** `gh pr create`; **refresh** after every significant push (CI fix, review round, conflict merge).

**Body format SSOT:** [references/reviewer-friendly-pr-body.md](references/reviewer-friendly-pr-body.md) · skeleton [references/pr-body-template.md](references/pr-body-template.md) · example [PR #8](https://github.com/JWLee89/engineering-skills/pull/8) · diff links [references/pr-diff-links.md](references/pr-diff-links.md).

Checklist:

```
- [ ] Sections: Background, Purpose, Review guide, Changes made (Δ), Verification, Out of scope
- [ ] Review guide: Summary, Commits (linked SHAs), Start here, Focus areas (PR diff primary)
- [ ] Changes made: Layer | Change | Δ from git diff --numstat (group by layer, not file laundry)
- [ ] Verification: author evidence ([../verification.md](../handle-task/verification.md)); CI plan; isolation gates if behavioral ([../feature-gating.md](../handle-task/feature-gating.md))
- [ ] Author steps already run in `/handle-task` Phase 8 — no "TBD" checkboxes
```

Verification subsection blocks: [../handle-task/references/templates/verification-pr-body.md](../handle-task/references/templates/verification-pr-body.md).

______________________________________________________________________

## Phase 3: Create or update PR + labels

1. **Push:** `git push -u origin HEAD` or `--force-with-lease` when user approved history rewrite
2. **Create** if none: `gh pr create --draft` with Phase 2 body
3. **Update** if exists: `gh pr edit <num> --body-file …`, title/labels as needed
4. **Labels:** from `pr.labels` (`gh label list` — never invent labels)
5. **After create or push:** refresh body with `/pull/{n}/changes#diff-…` focus links (needs PR number)

______________________________________________________________________

## Phase 4: Execute verification plan

Run each author checkbox (agentic — Shell in session); on success, check box and add
evidence (command, summary line, `tests/...::test`, commit SHA, coverage note, or CI
URL). Re-run isolation gates when applicable. Update body with
`gh pr edit <num> --body-file /tmp/pr-body.md`.

Watch CI:

```bash
gh run list --branch "$(git branch --show-current)" --limit 5
gh run watch <run-id> --exit-status
```

Record **run URLs** on green. On failure → Phase 5.

______________________________________________________________________

## Phase 5: Fix loops

### 5a. CI/CD

```
FAIL → logs → root cause → minimal fix → commit → push → watch CI
```

One logical fix per commit; project `commit.message_format`. No `--no-verify` unless user asks.

### 5b. Merge conflicts

When `mergeable: CONFLICTING`:

```bash
git fetch origin <base>
git merge origin/<base>   # or rebase if project prefers — ask if unclear
# resolve, git add, commit
git push --force-with-lease   # after rebase; plain push after merge commit
```

Refresh **Changes made** Δ lines and Verification after conflict resolution.

### 5c. Code quality / reviewability (proactive)

Before re-requesting review, apply [../engineering-rubric.md](../handle-task/engineering-rubric.md):

- Remove duplication; reuse existing helpers
- Split oversized commits only when user asked to squash/simplify history
- Fix naming, dead code, over-engineered abstractions **in files this PR already touches**
- Document non-obvious choices in PR body or `.hac/decisions.md` when configured

### 5d. Review feedback

1. Fetch comments: `gh pr view <num> --comments`, review threads, Copilot/Bugbot if present
2. **Triage:** must-fix (correctness, security, CI) vs nit vs optional
3. Fix must-fix in focused commits; push; reply with commit SHA / explanation on nits
4. Update PR body (Review guide focus areas + commit map / Changes made Δ) when behavior or scope changed
5. Re-run failed verification steps; wait for CI

Repeat until required checks green and blocking comments addressed.

### 5e. Scenario verification commits (optional)

Small commits to prove CI behavior (docs-only skip, etc.). Link run IDs. Squash only if user asks.

______________________________________________________________________

## Phase 6: Pre-merge code review

Author self-review: full pass [../engineering-rubric.md](../handle-task/engineering-rubric.md) before `gh pr ready`.
Fix blockers; note residual nits in PR comment for human reviewer.

**`/handle-task`:** Phase 9b **requires** **`/code-review`** on the task PR before Phase 7
ready gate — not optional. See [../handle-task/SKILL.md](../handle-task/SKILL.md#phases-detail-in-linked-files) (deep review / 9b).

For other callers, **`/code-review`** is the eight-axis rubric pass (draft markdown before
forge review comments) — [../code-review/workflow.md](../code-review/workflow.md).

______________________________________________________________________

## Phase 7: Ready gate + finalize

**All required before `gh pr ready`:**

- When using **`/handle-task`:** Phase 9b **`/code-review`** completed — draft approved; no
  **Blockers** (Majors fixed or user-acknowledged)
- Author verification checkboxes done with strong evidence (not placeholders); CI-only
  items have run URLs when available
- Required CI workflows green (URLs in body)
- No unresolved merge conflicts
- Blocking review feedback addressed (or explicitly deferred with user ack)
- Author self-review ([../engineering-rubric.md](../handle-task/engineering-rubric.md)): no blockers (deep `/code-review`
  tracked separately above for `/handle-task` callers)

Then: update body (Review guide with current line ranges, full Verification + **Changes made** with final Δ lines) →
`gh pr ready` → issue transition per [../issue-transitions.md](../handle-task/issue-transitions.md) →
comment with PR URL + CI links.

Do **not** merge unless user asks.

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| PR body without line deltas | Run `--numstat`; fill **Changes made** table |
| Review guide is only a file list | Add Summary + Commits + linked line-range focus areas |
| SHAs/paths only in backticks | Use `commit/`, `pull/…/changes#diff-…`, and blob links |
| Markdown blob without `?plain=1` | Rendered doc view — add `?plain=1` for source lines |
| Focus areas only link to blob | Primary link must be **this PR** `/changes#diff-…` when PR exists |
| Stale line numbers after new pushes | Re-diff; refresh Review guide in Phase 2 / 5d / 7 |
| Only creates PR, never updates | Re-run Phases 2–5 on every review/CI round |
| `gh pr ready` before CI green | Phase 4–5 |
| Author verification without command output | [../verification.md](../handle-task/verification.md) evidence bundle |
| Behavioral PR with no isolation proof | [../feature-gating.md](../handle-task/feature-gating.md) |
| Huge conflict merge without re-verify | Re-run tests + CI |
| Ignoring review comments | Phase 5d triage |
| Duplicate skill folders | Edit only `skills/pull-request/` |

______________________________________________________________________

## Bundled with handle-task

Ticket flow: `/handle-task` → [../SKILL.md](../handle-task/SKILL.md). Templates: [../templates.md](../handle-task/templates.md).
