# Code review — workflow

**Entry:** [SKILL.md](SKILL.md).

**Project config (optional):** when the repo has `.handle-task/project.yaml`, load
[../project-config.md](../handle-task/project-config.md) for `memory.*`, `verify.*`, `ticket.prefix`, and
issue-tracker settings. When absent, use `CONTRIBUTING.md`, `README.md`, and conventional repo
docs paths.

```
ISOLATE → RESOLVE PR → GATHER CONTEXT → DIFF + CODEBASE → RUBRIC PASS
  → DRAFT MARKDOWN → USER APPROVAL → [POST COMMENTS] → [FIX LOOP if author]
```

**Hard rules**

0. **Tone** — kind, respectful, and constructive. Acknowledge what works; explain *why* a
   change matters; suggest paths forward. Never belittle the author or imply incompetence.
1. **PR required** — if the user did not give a PR URL, number, or branch, **stop and ask**.
2. **No prior chat context** — do not rely on earlier sessions, stashed plans, or uncommitted
   local work. Evidence = PR, linked work items, docs, and repository state you fetch in
   **this** run.
3. **Draft before publish** — write the full review to a markdown artifact; **wait for explicit
   user approval** before posting review comments on the forge (PR review API).
4. **No commits / pushes** — do not push branches, open fix commits, or merge until the user
   approves the review outcome (and explicitly asks for fixes).

______________________________________________________________________

## Phase 0: Session isolation

Tell the user (briefly) that this review uses **only** freshly fetched PR and repo data.

Do **not** use:

- Summarized conversation history from other tasks
- Assumed work-item scope from memory without re-fetching the item
- Local uncommitted changes unless the user explicitly ties them to the PR branch

Do use:

- PR host CLI/API (e.g. `gh pr view`, `gh pr diff`, checks, comments when GitHub)
- Issue tracker adapter from project config ([../issue-tracker-adapters.md](../handle-task/issue-tracker-adapters.md))
- Paths from config when set: `memory.agent_guide`, `memory.decisions`, `memory.committed_tasks`,
  `memory.local_specs`; otherwise repo `docs/`, decision/ADR locations, and specs linked from the PR

______________________________________________________________________

## Phase 1: Resolve the pull request

| Input | Action |
| ----- | ------ |
| Full PR URL | Parse forge, owner/repo (or project), and PR id |
| PR number (`#123`) | Resolve against current repo remote unless user named another repo |
| Head branch name | List open PRs for that head (e.g. `gh pr list --head <branch>` on GitHub) |

Record: PR number/id, URL, title, author, base/head, draft state, linked work items (body +
closing keywords, cross-links).

If ambiguous (fork, wrong repo, multiple PRs for branch) → ask once.

### Intent checkpoint (mandatory)

Before Phase 2, write **one sentence** stating what you believe this PR is intended to accomplish
(from PR title/body + linked work items only). Share it with the user briefly; if intent is
unclear, ask once. Do not run the full rubric until intent is plausible or confirmed.

______________________________________________________________________

## Phase 2: Gather context (parallel where possible)

### PR body as review map

When the author used `/pull-request` Phase 2, the description should include **Review guide →
Focus areas** with PR `#diff-…` links. **Start there** before re-deriving hunks from scratch.
If the body is summary-only, note it under **Context used** (documentation gap — not automatic
Blocker unless repo policy requires linked focus areas).

See [../pull-request/references/reviewer-friendly-pr-body.md](../pull-request/references/reviewer-friendly-pr-body.md).
When **Background** links a spec or ticket, run [spec compliance (Stage 1)](https://github.com/Jeffallan/claude-skills/blob/main/skills/code-reviewer/references/spec-compliance-review.md) before code-quality axes.

### From the PR host

Example (GitHub):

```bash
gh pr view <num> --json title,body,author,baseRefName,headRefName,commits,files,additions,deletions,labels,statusCheckRollup
gh pr diff <num>
gh pr checks <num>
gh pr view <num> --comments
```

Use the equivalent commands or UI for other forges when the user specifies them.

### Linked work items

- Parse PR body for issue keys using `ticket.prefix` from config when set; otherwise common
  `KEY-123` / `#123` patterns and URLs in the description
- Fetch each linked item via the configured tracker adapter (or user-pasted content)
- Pull **background, scope, definition of done, verification plan** (or the tracker’s equivalent
  sections); note acceptance criteria

### Codebase (beyond the diff)

- Read files **touched** and their **callers/callees** when behavior changes
- Search for duplicates of new logic (`rg`, semantic search)
- Read relevant tests and configuration affected by the change
- Skim CI/build definitions if the PR changes how tests or deploys run

### Documentation

- PR-linked specs, `docs/`, ADRs/decision logs (including `memory.decisions` when configured),
  committed task scratchpads (`memory.committed_tasks` when configured)
- [../documentation-and-adrs.md](../handle-task/documentation-and-adrs.md) for ADR and wire-format conventions

______________________________________________________________________

## Phase 3: Apply the rubric

Run every section in [rubric.md](rubric.md). For each finding:

1. Assign **severity** (Blocker / Major / Minor / Question)
2. Assign **rubric axis** (1–8)
3. Include **context links** (at least one):
   - PR: diff hunk or commit permalink with line range
   - Work item: key + quoted acceptance criterion or DoD line
   - Doc: path + section or ADR id
4. Include a **short code excerpt** (from diff or repo) when it clarifies the issue
5. State **PR-introduced vs pre-existing** for bugs
6. Phrase findings so the author can act on them — e.g. "Consider … because …" or
   "What do you think about …?" for **Question** severity; reserve firm language for
   **Blocker** items only

Optional: run targeted tests locally when `verify.commands` exist in project config — record
commands and outcome in the draft under **Verification notes**. Do not mark PR approved on green
tests alone; rubric still applies.

Cross-check [../engineering-rubric.md](../handle-task/engineering-rubric.md) but **do not** skip rubric sections here.

______________________________________________________________________

## Phase 4: Draft markdown review (mandatory)

Write the review using [references/report-template.md](references/report-template.md) (repo root `code-review-PR-<num>.md`, `/tmp/`, or chat if user asked).

Apply Phase 3 rules (severity, axis, links, snippets) inside the template sections.

**Stop.** Ask the user to review the draft: edit severity, drop false positives, add context.

Questions to ask:

- Publish comments on the forge as a formal review (approve / comment / request changes)?
- Split into inline review vs single summary comment?
- Should the author run a fix loop before re-review?

______________________________________________________________________

## Phase 5: Publish (only after user approval)

Default: **do not publish** until the user says to post (e.g. "LGTM, post review").

### Formal PR review (example: GitHub)

Map draft verdict → review event:

| Draft verdict | GitHub `gh pr review` |
| ------------- | --------------------- |
| Approve | `--approve` |
| Request changes | `--request-changes` |
| Approve with nits / questions only | `--comment` |

Post body from approved draft (trim checklist if user wants a shorter public review).

For **inline** comments on GitHub, use `gh api` with `path`, `line`, `body` — each body must
still include context links per Phase 3. Adapt for other forges per their API.

**Never** push commits or `--force` in this skill unless the user opens a separate fix task.

### After publish

- Offer `/pull-request` for the author to address findings
- Offer a **fresh** `/code-review` on the same PR after fixes (new session isolation applies)

______________________________________________________________________

## Invoked from `/handle-task`

When **`/handle-task`** reaches Phase 9b, run this skill on **the task’s open draft PR** (same
branch). The gate is **mandatory** before `gh pr ready`:

1. Full rubric → draft markdown → user approves draft
2. **Blockers** fixed (push + optional re-review) unless user explicitly defers with a follow-up
3. Then continue **`/pull-request`** Phase 10 (CI, author self-review, ready)

Do not skip because Phase 8 tests passed — `/code-review` catches design, test-gap, and spec issues.

______________________________________________________________________

## Phase 6: Author fix loop (optional)

If the user is the **author** and wants to address findings:

1. Triage Blockers → Majors → Minors
2. Implement fixes on the PR branch — **only when user explicitly asks** to implement
3. Re-run verification from [../verification.md](../handle-task/verification.md) when the project defines it
4. Re-run `/code-review` (new draft) before merge

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Review without PR link | Phase 1 — ask |
| Use last week's spec from chat | Phase 0 — re-fetch work items |
| Post review before user reads draft | Phase 4 gate |
| Push fix commits during review | Phase 5 — review only |
| Findings without links/snippets | [report-template.md](references/report-template.md) + Phase 3 rules |
| Skip axes 4–8 on "small" PRs | Full [rubric.md](rubric.md) |
| Duplicate rubric in PR comment | Link to draft file or summarize findings only |
| Harsh or personal tone | [rubric.md](rubric.md) persona — critique code, encourage the author |
| Hard-code tracker or memory paths | Read from project config or discover repo conventions |

______________________________________________________________________

## See also

- [rubric.md](rubric.md) — eight-axis criteria
- [../engineering-rubric.md](../handle-task/engineering-rubric.md) — author implement/self-review (`/pull-request` Phase 6)
- [../pull-request/workflow.md](../pull-request/workflow.md) — CI, ready gate
- [../spec-adherence.md](../handle-task/spec-adherence.md) — requirement ↔ test mapping
- [../issue-tracker-adapters.md](../handle-task/issue-tracker-adapters.md) — fetch linked work items by tracker type
