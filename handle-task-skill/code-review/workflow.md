# Code review — workflow

**Entry:** [SKILL.md](SKILL.md). Load `.handle-task/project.yaml`
([../project-config.md](../project-config.md)) when reviewing a repo that uses it.

```
ISOLATE → RESOLVE PR → GATHER CONTEXT → DIFF + CODEBASE → RUBRIC PASS
  → DRAFT MARKDOWN → USER APPROVAL → [POST COMMENTS] → [FIX LOOP if author]
```

**Hard rules**

0. **Tone** — kind, respectful, and constructive. Acknowledge what works; explain *why* a
   change matters; suggest paths forward. Never belittle the author or imply incompetence.
1. **PR required** — if the user did not give a PR URL, number, or branch, **stop and ask**.
2. **No prior chat context** — do not rely on earlier sessions, stashed plans, or uncommitted
   local work. Evidence = PR, tracker, docs, and repository state you fetch in **this** run.
3. **Draft before publish** — write the full review to a markdown artifact; **wait for explicit
   user approval** before posting review comments on GitHub (or JIRA review fields).
4. **No commits / pushes** — do not push branches, open fix commits, or merge until the user
   approves the review outcome (and explicitly asks for fixes).

______________________________________________________________________

## Phase 0: Session isolation

Tell the user (briefly) that this review uses **only** freshly fetched PR and repo data.

Do **not** use:

- Summarized conversation history from other tasks
- Assumed ticket scope from memory without re-fetching the ticket
- Local uncommitted changes unless the user explicitly ties them to the PR branch

Do use:

- `gh pr view`, `gh pr diff`, CI checks, linked issues
- Issue tracker adapters for JIRA/Linear/GitHub ([../issue-tracker-adapters.md](../issue-tracker-adapters.md))
- `memory.agent_guide`, `.hac/decisions.md`, ADRs, protocol docs **read from disk in this workspace**

______________________________________________________________________

## Phase 1: Resolve the pull request

| Input | Action |
| ----- | ------ |
| `https://github.com/org/repo/pull/123` | Parse owner/repo/number; set context |
| `#123` or `123` | Use current repo remote unless user named another repo |
| Branch name | `gh pr list --head <branch> --json number,url` |

Record: PR number, URL, title, author, base/head, draft state, linked issues (body + `Closing` keywords).

If ambiguous (fork, wrong repo, multiple PRs for branch) → ask once.

______________________________________________________________________

## Phase 2: Gather context (parallel where possible)

### From GitHub

```bash
gh pr view <num> --json title,body,author,baseRefName,headRefName,commits,files,additions,deletions,labels,statusCheckRollup
gh pr diff <num>
gh pr checks <num>
gh pr view <num> --comments
```

### Linked work items

- Parse PR body for ticket keys (`PROJECT-123`, `[MOPS-123]`, etc.) using `ticket.prefix` from config when set
- Fetch full ticket via adapter (JIRA MCP, `gh issue view`, or pasted content)
- Pull **Background, Scope, DoD, Verification plan** from ticket; note acceptance criteria

### Codebase (beyond the diff)

- Read files **touched** and their **callers/callees** when behavior changes
- Search for duplicates of new logic (`rg`, semantic search)
- Read relevant tests and configs (YAML DAG, protocols) affected by the change
- Skim CI workflow files if the PR changes build/test behavior

### Documentation

- PR-linked specs, `docs/`, protocol markdown, `.hac/tasks/*` if referenced in PR
- [../documentation-and-adrs.md](../documentation-and-adrs.md) for ADR conventions in repo

______________________________________________________________________

## Phase 3: Apply the rubric

Run every section in [rubric.md](rubric.md). For each finding:

1. Assign **severity** (Blocker / Major / Minor / Question)
2. Assign **rubric axis** (1–8)
3. Include **context links** (at least one):
   - GitHub: PR file line — prefer `/pull/<n>/files#diff-…` or commit permalink with line range
   - Ticket: key + quoted acceptance criterion
   - Doc: path + section or ADR id
4. Include a **short code excerpt** (from diff or repo) when it clarifies the issue
5. State **PR-introduced vs pre-existing** for bugs
6. Phrase findings so the author can act on them — e.g. "Consider … because …" or
   "What do you think about …?" for **Question** severity; reserve firm language for
   **Blocker** items only

Optional: run targeted tests locally if the user expects it and `verify.commands` exist — record commands and outcome in the draft under **Verification notes**. Do not mark PR approved on green tests alone; rubric still applies.

Cross-check lightweight axes in [../code-review.md](../code-review.md) but **do not** skip rubric sections.

______________________________________________________________________

## Phase 4: Draft markdown review (mandatory)

Write the review to a file the user can edit:

- Default path: `code-review-PR-<num>.md` in repo root or `/tmp/` if repo policy prefers
- Or paste in chat if the user asked for chat-only draft

Use this structure:

```markdown
# Code review: PR #<num> — <title>

**PR:** <url>
**Branch:** `<head>` → `<base>`
**Ticket(s):** <keys + links>
**Reviewer persona:** Senior engineer — rigorous, kind, respectful (handle-task /code-review)
**Verdict (draft):** Request changes | Approve with nits | Approve

## Summary
<2–4 sentences: what the PR does well, overall quality, merge recommendation — lead with strengths where genuine>

## Context used
- PR description (+ gaps)
- Tickets: …
- Docs: …
- CI: <pass/fail summary + check names>

## Findings

### Blockers
#### B1. <title> (Axis: Bugs — …)
**Context:** [PR diff](…) · [MOPS-123 DoD: "…"]
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
| # | Axis        | Status | Notes |
|---|-------------|--------|-------|
| 1 | Question    | OK/…   | …     |
…

## Test traceability
| Requirement | Test(s) | Gap? |
|-------------|---------|------|

## Verification notes
<commands run, or "not run — reason">

## Pre-existing issues noticed (not blocking unless PR regresses)
…
```

**Stop.** Ask the user to review the draft: edit severity, drop false positives, add context.

Questions to ask:

- Publish comments to GitHub as review (approve / comment / request changes)?
- Split into inline review vs single summary comment?
- Should the author run a fix loop before re-review?

______________________________________________________________________

## Phase 5: Publish (only after user approval)

Default: **do not publish** until the user says to post (e.g. "LGTM, post review").

### GitHub review comment

Map draft severity → GitHub event:

| Draft verdict | `gh pr review` |
| ------------- | -------------- |
| Approve | `--approve` |
| Request changes | `--request-changes` |
| Approve with nits / questions only | `--comment` |

Post body from approved draft (trim checklist if user wants a shorter public review).

For **inline** comments, use `gh api` to create review comments with `path`, `line`, `body` —
each body must still include context links per Phase 3.

**Never** push commits or `--force` in this skill unless the user opens a separate fix task.

### After publish

- Offer `/pull-request` for the author to address findings
- Offer a **fresh** `/code-review` on the same PR after fixes (new session isolation applies)

______________________________________________________________________

## Phase 6: Author fix loop (optional)

If the user is the **author** and wants to address findings:

1. Triage Blockers → Majors → Minors
2. Implement fixes on the PR branch — **only when user explicitly asks** to implement
3. Re-run verification from [../verification.md](../verification.md)
4. Re-run `/code-review` (new draft) before merge

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Review without PR link | Phase 1 — ask |
| Use last week's spec from chat | Phase 0 — re-fetch ticket |
| Post GitHub review before user reads draft | Phase 4 gate |
| Push fix commits during review | Phase 5 — review only |
| Findings without links/snippets | Phase 3 template |
| Skip axes 4–8 on "small" PRs | Full [rubric.md](rubric.md) |
| Duplicate rubric in PR comment | Link to draft file or summarize findings only |
| Harsh or personal tone | [rubric.md](rubric.md) persona — critique code, encourage the author |

______________________________________________________________________

## See also

- [rubric.md](rubric.md) — eight-axis criteria
- [../code-review.md](../code-review.md) — author pre-merge checklist (`/pull-request`)
- [../pull-request/workflow.md](../pull-request/workflow.md) — CI, ready gate
- [../spec-adherence.md](../spec-adherence.md) — requirement ↔ test mapping
