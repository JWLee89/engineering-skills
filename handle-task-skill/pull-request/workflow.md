# Pull request — workflow

Create, **update**, and harden pull requests until they are **merge-ready**: clear
description, green CI, conflicts resolved, review feedback addressed, and code quality
suitable for human review.

**Portable:** load **`.handle-task/project.yaml`** first ([../project-config.md](../project-config.md)).
If missing, infer from `CONTRIBUTING.md`, `Makefile`, `package.json`, and ask once.

**Single source of truth:** `handle-task-skill/pull-request/` (symlinked as `/pull-request`).

**Delegates (in `handle-task-skill/`):**

| Need | File |
| ---- | ---- |
| Local verify | [../verification.md](../verification.md) (agentic evidence **required**) |
| Isolation gates | [../feature-gating.md](../feature-gating.md) |
| Author self-review | [../engineering-rubric.md](../engineering-rubric.md) |
| Deep PR review | [../code-review/workflow.md](../code-review/workflow.md) (`/code-review`) |
| Performance | [../performance-optimization.md](../performance-optimization.md) |
| ADR / why docs | [../documentation-and-adrs.md](../documentation-and-adrs.md) |

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

Build **clickable GitHub URLs** for the PR body (adjust host/path for other forges):

```bash
gh repo view --json nameWithOwner -q .nameWithOwner   # owner/repo
git rev-parse HEAD                                     # full SHA for blob links
git rev-parse --short HEAD
gh pr view --json number,url -q .url                   # after PR exists
```

| Target | URL pattern |
| ------ | ----------- |
| **Commit** | `https://github.com/{owner}/{repo}/commit/{sha}` |
| **PR diff (preferred for review)** | `https://github.com/{owner}/{repo}/pull/{n}/changes#diff-{diff_id}R{start}-R{end}` |
| **File at commit (source)** | `https://github.com/{owner}/{repo}/blob/{sha}/{path}#L{start}-L{end}` |
| **Markdown at commit (plain source)** | same as file, but insert **`?plain=1`** before `#L` — e.g. `…/doc.md?plain=1#L90-L112` |

**PR diff anchor `diff_id`:** SHA-256 hex digest of the **repo-relative file path** (UTF-8):

```bash
python3 -c "import hashlib,sys; print(hashlib.sha256(sys.argv[1].encode()).hexdigest())" "path/to/file.md"
```

Use **`R{line}`** on the diff anchor for the **new** side (right column) — that is the
change reviewers should read. Line numbers come from the file at the PR tip (same as
`git diff` / IDE line numbers on the branch).

Use the **PR tip commit** (`HEAD` after push) for `blob/{sha}/…` source links.
After **`gh pr create`**, refresh the body with `/pull/{n}/changes#diff-…` links (they
need the PR number). Until a PR exists, use blob links only, then update in Phase 3/4.

In markdown, **link text must be human-readable** — do not leave bare backticks as the only
navigation aid. For each focus area, prefer **two links**:

```markdown
**Review:** [workflow.md L90–112 (this PR)](https://github.com/org/repo/pull/7/changes#diff-e0a158…R90-R112) ·
**Source:** [plain L90–112](https://github.com/org/repo/blob/abc123…/workflow.md?plain=1#L90-L112)
[abc1234](https://github.com/org/repo/commit/abc1234…)
```

Non-markdown source (`.py`, `.yaml`, …): **Review** diff link + optional **Source** blob
link without `?plain=1`.

```bash
gh pr list --head "$(git branch --show-current)" --json number,state,isDraft,url,mergeable
```

- Task memory (`memory.committed_tasks`), local spec gaps
- Issue tracker: new comments since last push (when MCP configured)
- **Blockers:** secrets in diff; local-only spec files staged

If a PR already exists, treat this as an **update** pass — do not open a duplicate.

______________________________________________________________________

## Phase 2: Review-friendly PR plan + verification plan

Build **before** `gh pr create` and **refresh** after every significant push (CI fix,
review round, conflict merge).

### Required body sections

| Section | Purpose |
| ------- | ------- |
| **Background** | Problem, ticket link, stack context |
| **Purpose** | What this PR achieves |
| **Review guide** | Human summary, commit map, **clickable** line-range focus areas ([below](#review-guide-human-readable)) |
| **Changes made** | Table: **Layer \| Change \| Δ lines** (required) |
| **Verification** | Author steps + CI checkboxes |
| **Out of scope** | Non-goals, follow-up tickets |

### Changes made — line deltas (required)

Summarize **`git diff origin/<base>...HEAD --numstat`** into the table. Group files into
layers (e.g. `tests/`, product code, `config/`, `.hac/`, CI). Per row:

- **Δ lines:** `+adds / −dels` with optional `(net ±N)` — use **bold** when \|net\| > 100 or
  the row is the main story of the PR
- One sentence **Change** column — no file laundry list unless the PR is tiny

Example:

```markdown
## Changes made

| Layer | Change | Δ lines |
| ----- | ------ | ------- |
| Tests | NGIQ e2e: DeepDiff, case1-only; drop contour + separate positioning module | **+223 / −345** (net −122) |
| Fixtures | Positioning helpers; export.json metadata enrichment for smoke scripts | +58 / −144 |
| HAC | Task scratchpad + status row | +35 / −0 |
```

Optional drill-down (large PRs only): second table **File \| + \| −** for top 10 paths by
total churn from `--numstat`.

### Review guide (human-readable)

The **Review guide** is the primary onboarding path for human reviewers. Write for someone
who has **not** read the ticket thread. Pair it with **Changes made** (layer deltas) —
do not duplicate the whole diff.

**Required subsections** (use these headings):

#### Summary for reviewers

2–4 sentences in plain language:

- What problem this PR solves and the **approach** (not a file list)
- What is **risky or subtle** (edge cases, compatibility, performance)
- What reviewers can **skip** (generated files, mechanical renames, HAC-only)

When the PR is open, add a **start here** line linking the full diff, e.g.
[Review all changes on this PR](https://github.com/org/repo/pull/7/changes) — focus
areas below jump into specific hunks.

#### Commits

Table mapping history to intent (newest last if that matches read order, or **oldest first**
when commits tell a story):

| Commit | Message (short) | What changed (human) |
| ------ | --------------- | -------------------- |
| [a1b2c3d](https://github.com/org/repo/commit/a1b2c3d…) | `[MOPS-123](feat) Add gating in postprocess` | View-gating logic + unit tests |
| [d4e5f6a](https://github.com/org/repo/commit/d4e5f6a…) | `[MOPS-123](test) Wire DAG config` | YAML only; no logic |

Use **`git log origin/<base>..HEAD --format='%h %s'`**. The **Commit** column must be a
markdown link to `…/commit/{sha}` (short or full SHA). Never commit-only backticks in the
published PR body.

#### Focus areas (read in this order)

Numbered list — **core logic → wiring → config → tests**. Each item **must** include:

| Field | Rule |
| ----- | ---- |
| **Review (required when PR open)** | `[label (this PR)](…/pull/{n}/changes#diff-{sha256(path)}R{start}-R{end})` |
| **Source (optional)** | Blob at PR tip; **`?plain=1`** before `#L` for `.md` / `.mdx` / `.markdown` |
| **Why read** | One sentence: behavior, contract, or invariant at stake |
| **Commit** | Link: `[shortsha](https://github.com/…/commit/{sha})` when multi-commit |
| **Tests** | PR diff or blob link to test file lines; pytest node id in plain text if no anchor |

Example entry:

```markdown
1. **Review:** [postprocess.py L88–156 (this PR)](https://github.com/org/repo/pull/42/changes#diff-abc…R88-R156) ·
   **Source:** [L88–156](https://github.com/org/repo/blob/a1b2c3d…/insight_engine/…/postprocess.py#L88-L156) —
   MLO vs CC view gating for PEC; main behavioral change. Commit
   [a1b2c3d](https://github.com/org/repo/commit/a1b2c3d…). Test:
   [test_execute_view_gating (this PR)](https://github.com/org/repo/pull/42/changes#diff-def…R120-R145).
2. **Review:** [workflow.md L90–112 (this PR)](https://github.com/org/repo/pull/7/changes#diff-e0a158…R90-R112) ·
   **Source:** [plain L90–112](https://github.com/org/repo/blob/sha…/doc/workflow.md?plain=1#L90-L112) —
   URL rules for reviewers. Commit [3285cf2](https://github.com/org/repo/commit/3285cf2…).
```

**How to pick line ranges:** use `git diff origin/<base>...HEAD -U0 -- <path>` or read
changed hunks in the IDE; cite the span that contains the decision logic, not the whole file.

**Size limits:**

- Small PR (≤ ~5 files): up to **5** focus areas
- Medium: **3–7** focus areas; defer file laundry to optional drill-down under Changes made
- Large: top **5–8** hotspots only + “remaining churn is tests/fixtures”

Refresh focus areas and line ranges after every significant push (CI fix, review round,
conflict merge).

### Verification plan

Three subsections under `## Verification`, all `- [ ]` until executed:

1. **Steps run (author)** — concrete commands from `verify.commands` / changed paths;
   each checked item must include **evidence** (exit code, pass summary, test ids,
   commit SHA, smoke output snippet) per [../verification.md](../verification.md).
   Include **isolation gate** reruns from [../feature-gating.md](../feature-gating.md)
   when the PR adds behavioral code.
2. **Test plan (reviewer / CI)** — each required `verify.ci_workflows` entry
3. **Out of scope** — deferred work (also usable under Verification or standalone section)

The agent must have **already run** author steps during `/handle-task` Phase 8 before
opening or refreshing the PR — do not leave author checkboxes empty with “TBD”.

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

Before re-requesting review, apply [../engineering-rubric.md](../engineering-rubric.md):

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

Author self-review: full pass [../engineering-rubric.md](../engineering-rubric.md) before `gh pr ready`.
Fix blockers; note residual nits in PR comment for human reviewer.

**`/handle-task`:** Phase 9b **requires** **`/code-review`** on the task PR before Phase 7
ready gate — not optional. See [../SKILL.md](../SKILL.md#phase-9-pull-request-draft-deep-code-review).

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
- Author self-review ([../engineering-rubric.md](../engineering-rubric.md)): no blockers (deep `/code-review`
  tracked separately above for `/handle-task` callers)

Then: update body (Review guide with current line ranges, full Verification + **Changes made** with final Δ lines) →
`gh pr ready` → issue transition per [../issue-transitions.md](../issue-transitions.md) →
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
| Author verification without command output | [../verification.md](../verification.md) evidence bundle |
| Behavioral PR with no isolation proof | [../feature-gating.md](../feature-gating.md) |
| Huge conflict merge without re-verify | Re-run tests + CI |
| Ignoring review comments | Phase 5d triage |
| Duplicate skill folders | Edit only `handle-task-skill/pull-request/` |

______________________________________________________________________

## Bundled with handle-task

Ticket flow: `/handle-task` → [../SKILL.md](../SKILL.md). Templates: [../templates.md](../templates.md).
