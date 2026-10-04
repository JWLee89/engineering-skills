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
| Review axes | [../code-review.md](../code-review.md) |
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
- [ ] Review guide: human summary + commit map + focus areas with `path:Lstart-Lend`
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
| **Review guide** | Human summary, commit map, **line-range focus areas** for reviewers ([below](#review-guide-human-readable)) |
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

#### Commits

Table mapping history to intent (newest last if that matches read order, or **oldest first**
when commits tell a story):

| Commit | Message (short) | What changed (human) |
| ------ | --------------- | -------------------- |
| `a1b2c3d` | `[MOPS-123](feat) Add gating in postprocess` | View-gating logic + unit tests |
| `d4e5f6a` | `[MOPS-123](test) Wire DAG config` | YAML only; no logic |

Use **`git log origin/<base>..HEAD --format='%h %s'`**. Link SHAs when the PR is on GitHub
(`https://github.com/org/repo/commit/<sha>`) if helpful.

#### Focus areas (read in this order)

Numbered list — **core logic → wiring → config → tests**. Each item **must** include:

| Field | Rule |
| ----- | ---- |
| **Location** | `` `path/to/file.py` `` with **line range** `` `Lstart–Lend` `` (from diff hunks on the PR branch; approximate is OK) |
| **Why read** | One sentence: behavior, contract, or invariant at stake |
| **Commit** | Short SHA that introduced or last touched this hunk (when multi-commit) |
| **Tests** | Optional: `` `tests/...::test_name` `` that proves this block |

Example entry:

```markdown
1. **`insight_engine/breast/ngiq/tasks/postprocess.py` (L88–L156)** — MLO vs CC view gating
   for PEC; this is the main behavioral change. Commit `a1b2c3d`. See
   `tests/unit/breast/ngiq/tasks/test_postprocess.py::test_execute_view_gating_for_pec_mlo`.
2. **`insight_engine/configs/breast/ngiq/NGIQ_100.yaml` (L12–L18)** — DAG wiring only; confirm
   task order matches spec. Commit `d4e5f6a`.
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

Before re-requesting review, apply [../code-review.md](../code-review.md):

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

Full pass [../code-review.md](../code-review.md) before `gh pr ready`. Fix blockers; note
residual nits in PR comment for human reviewer.

______________________________________________________________________

## Phase 7: Ready gate + finalize

**All required before `gh pr ready`:**

- Author verification checkboxes done with strong evidence (not placeholders); CI-only
  items have run URLs when available
- Required CI workflows green (URLs in body)
- No unresolved merge conflicts
- Blocking review feedback addressed (or explicitly deferred with user ack)
- Pre-merge review: no blockers

Then: update body (Review guide with current line ranges, full Verification + **Changes made** with final Δ lines) →
`gh pr ready` → issue transition per [../issue-transitions.md](../issue-transitions.md) →
comment with PR URL + CI links.

Do **not** merge unless user asks.

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| PR body without line deltas | Run `--numstat`; fill **Changes made** table |
| Review guide is only a file list | Add Summary + Commits + `path:Lstart–Lend` focus areas |
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
