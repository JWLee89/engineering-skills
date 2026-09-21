# Make Pull Request — workflow

Run **after all ticket features are implemented** on the feature branch. Turns a
finished branch into a **merge-ready, easy-to-review PR** with executed verification
evidence.

**Portable:** works in any repo. Load **`.handle-task/project.yaml`** first (see
[../project-config.md](../project-config.md)). If missing, infer from
`CONTRIBUTING.md`, `Makefile`, `package.json`, and ask the user.

**Single source of truth:** `handle-task-skill/make-pull-request/` (symlinked as
`/make-pull-request`). Do not maintain a separate top-level skill folder.

**Delegates to (in `handle-task-skill/`):**

| Need                  | File                                                             |
| --------------------- | ---------------------------------------------------------------- |
| Local verify commands | [../verification.md](../verification.md) or project config       |
| Pre-merge review      | [../code-review.md](../code-review.md)                           |
| Performance in PR     | [../performance-optimization.md](../performance-optimization.md) |
| Design / ADR notes    | [../documentation-and-adrs.md](../documentation-and-adrs.md)     |

Also: user `creating-pull-requests` rule; `ci-investigator` subagent for single failing checks.

______________________________________________________________________

## When to use

- User says "open PR", "make pull request", `/make-pull-request`, or "finalize the PR"
- Implementation on the ticket branch is complete
- Resuming a draft PR that needs CI green + verification evidence

**When NOT to use:** spec/plan not approved; implementation incomplete; trivial fix
with no PR expected.

______________________________________________________________________

## Phase 0: Load project config

1. Read `.handle-task/project.yaml` if present
2. Note: `ticket.prefix`, `git.pr_target`, `verify.*`, `memory.*`, `pr.*`,
   `integrations.issue_tracker`
3. If required fields missing, ask once — do not hardcode repo paths

______________________________________________________________________

## Workflow overview

```
CONFIG → PRE-FLIGHT → REVIEW-FRIENDLY PLAN → DRAFT PR + LABELS → EXECUTE PLAN → CI FIX → REVIEW → READY GATE
```

Checklist:

```
- [ ] Project config loaded (or defaults confirmed with user)
- [ ] Branch clean; commits match project commit format
- [ ] PR body: Background, Purpose, Review guide, Changes made, Verification, Out of scope
- [ ] Verification plan: concrete commands + CI workflows (all unchecked initially)
- [ ] Draft PR opened (--draft unless config says otherwise)
- [ ] Labels applied from pr.labels
- [ ] Every author verification step executed and checked off with evidence
- [ ] Required CI workflows green; links recorded; checkboxes checked
- [ ] Pre-merge code review complete
- [ ] gh pr ready ONLY after ready gate passes
- [ ] Issue tracker updated (transition + comment when configured)
```

______________________________________________________________________

## Phase 1: Pre-flight

1. **Git state** (parallel):

   ```bash
   git status
   git log origin/<base>..HEAD --oneline
   git diff origin/<base>...HEAD --stat
   ```

   `<base>` = `git.pr_target` or `git.default_base` from config.

2. **Context** (when configured):

   - Committed task memory (`memory.committed_tasks`)
   - Local todo/spec (`memory.local_specs`) — unchecked items zero or explained
   - Agent guide (`memory.agent_guide`) — architecture, commands
   - Issue tracker: fetch latest ticket comments if MCP available

3. **Existing PR:**

   ```bash
   gh pr list --head "$(git branch --show-current)" --json number,state,isDraft
   ```

4. **Blockers:** no staged local-only spec files; no secrets in diff.

______________________________________________________________________

## Phase 2: Review-friendly PR plan + verification plan

Build **before** opening the PR. The description should help a reviewer skim in
**5–10 minutes** without reading the full spec.

### Required body sections

Include all keys from `pr.required_body_sections` (default below). Adapt from
committed task memory — **do not paste the full local spec**.

| Section          | Purpose                                                              |
| ---------------- | -------------------------------------------------------------------- |
| **Background**   | 2–4 sentences: problem, ticket link, stack context if applicable     |
| **Purpose**      | One paragraph: what this PR achieves                                 |
| **Review guide** | **Suggested read order** — numbered file paths, one line each on why |
| **Changes made** | Table or bullets by layer (model / service / config / tests)         |
| **Verification** | Executable plan (see below)                                          |
| **Out of scope** | Explicit non-goals, follow-up tickets                                |

Optional when helpful: ASCII/mermaid diagram for pipeline or data-flow changes.

### Review guide (required for non-trivial PRs)

List files in the order a reviewer should read them — typically:

1. Core logic / model change (smallest surface that defines behavior)
2. Service or module wiring
3. Config / schema
4. Tests (what changed in assertions)

Example:

```markdown
## Review guide

1. **`src/models/user.py`** — type shape + validation (main logic)
2. **`src/services/user_service.py`** — wire model into handler
3. **`config/settings.yaml`** — new feature flag
4. **`tests/unit/test_user.py`** — assertion updates for new fields
```

### Verification plan (generate before opening PR)

Sources: `verify.commands`, `verify.by_path` (match changed paths),
`verify.hooks`, touched test files, `verify.ci_workflows`, spec testing strategy,
and the spec traceability matrix from [../spec-adherence.md](../spec-adherence.md).

Structure **three subsections** — every item starts unchecked `- [ ]`:

#### Steps run (author)

One checkbox per **concrete command**. Derive from config + changed paths:

| Signal | Look in                                    |
| ------ | ------------------------------------------ |
| Python | `Makefile`, `pyproject.toml`, `pytest.ini` |
| Node   | `package.json` scripts                     |
| Go     | `Makefile`, `go test ./...`                |
| Hooks  | `.pre-commit-config.yaml`, `prek`          |

Rules:

- Prefer **scoped** pytest when only one module changed (faster feedback)
- If a command cannot run locally, checkbox text must say **CI only** and why
- Include `verify.hooks` when set (e.g. `prek run --all-files`)
- Never leave author section empty when `verify.commands` is configured

#### Test plan (reviewer / CI)

One checkbox per `verify.ci_workflows` entry (`required: true` first).
Add specific test file paths when they encode the acceptance criteria.

#### Out of scope

Deferred tickets, unwired config, explicit non-goals from spec.

______________________________________________________________________

## Phase 3: Draft PR + labels

**User approval:** unless the user already asked to open a PR, summarize commits +
verification plan and ask once.

1. **Push:** `git push -u origin HEAD` (if needed)

2. **Create draft PR** — default `--draft` when `pr.draft_until_ready: true`.

   **Title:** expand `pr.title_format` from config.
   Example: `[PROJ-42](feat): Add user authentication endpoint`

   ```bash
   gh pr create --draft \
     --title "[PROJ-42](feat): Add user authentication endpoint" \
     --base <git.pr_target> \
     --body "$(cat <<'EOF'
   ## Background
   ...
   ## Purpose
   ...
   ## Review guide
   1. ...
   ## Changes made
   | Layer | Change |
   ...
   ## Verification
   ### Steps run (author)
   - [ ] make test-unit
   - [ ] make lint
   ### Test plan (reviewer / CI)
   - [ ] CI workflow — <name from verify.ci_workflows> — ...
   ### Out of scope
   - ...
   EOF
   )"
   ```

3. **Apply labels** immediately after create (or on existing PR):

   ```bash
   gh pr edit <num> --add-label "refactor,tests"
   ```

   Resolve labels from `pr.labels` in project config:

   | Key             | When                                                            |
   | --------------- | --------------------------------------------------------------- |
   | `always`        | Applied to every PR from this workflow                          |
   | `by_commit_tag` | Map commit/PR `{tag}` → label name(s)                           |
   | `by_path`       | Optional glob → extra labels (e.g. `src/api/**` → api)          |

   If `pr.labels` is unset, infer: `{tag}` from title → matching repo label when it
   exists (`gh label list`). Never invent labels — use only labels that exist on the repo.

4. **Issue tracker:** comment with PR link when integration configured.

______________________________________________________________________

## Phase 4: Execute verification plan (mandatory before ready)

**Do not mark the PR ready until this phase completes.**

### 4a. Local (author steps)

For **each** checkbox under "Steps run (author)":

1. Run the command
2. On failure → Phase 5 fix loop → re-run
3. On success → check the box in the PR body with brief evidence:
   `- [x] make lint — passed locally`
4. If CI-only → leave unchecked until CI proves it, note `(CI only — <reason>)`

Update PR body as you go:

```bash
gh pr edit <num> --body-file /tmp/pr-body.md
```

### 4b. CI (test plan)

```bash
gh run list --branch "$(git branch --show-current)" --limit 5
gh run watch <run-id> --exit-status
```

For each required workflow:

1. Wait for completion (or use `ci-investigator` on failure)
2. Check the box with the run URL:
   `- [x] CI — https://github.com/org/repo/actions/runs/123`
3. On failure → Phase 5

______________________________________________________________________

## Phase 5: CI/CD fix loop

```
FAIL → logs → root cause → minimal fix → commit → push → watch CI → PASS?
```

- One logical fix per commit; use project `commit.message_format`
- Never `--no-verify`, disable tests, or force-push without explicit user request
- Hook auto-fixes → new commit (not amend unless user rules allow)
- After each fix push, re-run failed verification steps and update checkboxes

| Symptom           | Action                                 |
| ----------------- | -------------------------------------- |
| Unit test fail    | Fix + run scoped test locally          |
| Lint / format     | Run project lint/format command        |
| Integration / env | Check secrets, runner labels, fixtures |
| Shallow git in CI | `fetch-depth: 0` in checkout action    |
| Lockfile drift    | Regenerate lockfile per project docs   |

______________________________________________________________________

## Phase 5b: Scenario verification commits

When test plan needs **branch-level proof** (e.g. CI skip on docs-only push), push small
focused commits and watch CI.

| Pattern            | Commit               | Expected                |
| ------------------ | -------------------- | ----------------------- |
| Docs-only behavior | doc/memory path only | expensive jobs skip     |
| Isolated module    | single package dir   | only that workflow runs |

Tag commits `(docs)` or `(test)`. Link run IDs in PR. Squash only if user asks.

______________________________________________________________________

## Phase 6: Pre-merge code review

Before marking ready, run [../code-review.md](../code-review.md):

| Axis        | Look for                       |
| ----------- | ------------------------------ |
| Correctness | Edge cases, error paths        |
| Design      | Wrong abstraction, spec drift  |
| Duplication | Copy-paste vs existing helpers |
| Verbosity   | Unnecessary indirection        |
| Maintenance | Missing tests, unclear names   |
| Scope       | Unrelated drive-by changes     |

Fix blockers; note nits for reviewer.

______________________________________________________________________

## Phase 7: Ready gate + finalize

### Ready gate (ALL must pass)

```
- [ ] Every "Steps run (author)" item checked OR marked CI-only with CI evidence
- [ ] Every required ci_workflows item checked with green run URL
- [ ] Pre-merge code review: no blockers
- [ ] Committed task memory updated (if project uses it)
```

**If any gate fails:** stay draft; fix and re-run Phase 4–6.

### Finalize

1. **Update PR body** — full Verification section with all checkboxes and run links
2. **Mark ready:** `gh pr ready <num>` (only after gate passes)
3. **Issue transition:** apply `status_transitions.pr_ready` when configured
   ([../issue-transitions.md](../issue-transitions.md))
4. **Issue tracker comment** with evidence summary + PR URL
5. **Prompt user** for squash, reviewers, merge — do not merge unless asked

**After merge:** update `memory.status` and task files when configured.

______________________________________________________________________

## Anti-patterns

| Mistake                               | Fix                                              |
| ------------------------------------- | ------------------------------------------------ |
| Wall of text / pasted spec            | Review guide + changes table                     |
| Empty or vague Verification           | Generate concrete commands in Phase 2            |
| `gh pr ready` before running plan     | Execute Phase 4 first                            |
| Unchecked boxes with "CI should pass" | Watch CI; add run URLs                           |
| Hardcoding repo paths                 | Read `.handle-task/project.yaml`                 |
| Duplicate skill folders               | Edit only `handle-task-skill/make-pull-request/` |
| Wrong or missing labels               | Use `pr.labels`; `gh label list` to verify       |
| Ready with red required CI            | Fix or document + user ack                       |

______________________________________________________________________

## Bundled with handle-task

Full ticket lifecycle: `/handle-task` → [../SKILL.md](../SKILL.md) Phases 1–8 before this workflow.
Templates: [../templates.md](../templates.md).
