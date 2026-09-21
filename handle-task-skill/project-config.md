# Project configuration

**`/handle-task`**, **`/make-pull-request`**, **`/create-ticket`**, and **`/review-ticket`**
read **`.handle-task/project.yaml`** at the workspace root.

**Discovery:** if the file is missing, copy
[examples/generic.project.yaml](examples/generic.project.yaml) (or
[examples/jira-project.project.yaml](examples/jira-project.project.yaml) for JIRA) and
ask the user to confirm — do not assume defaults from another repository.

______________________________________________________________________

## Schema

```yaml
name: my-project

ticket:
  prefix: PROJ                      # issue key prefix (PROJ, ENG, ACME, …)
  id_pattern: "{prefix}-{number}"   # branch name pattern

git:
  default_base: main
  pr_target: main

memory:
  committed_tasks: null             # e.g. .hac/tasks/
  local_specs: tasks/               # gitignore; never commit
  status: null
  decisions: null
  agent_guide: AGENTS.md            # CLAUDE.md, etc.

commit:
  message_format: "[{prefix}-{number}]({tag}) {summary}"
  tags: [feat, fix, chore, refactor, docs, test, build, feedback, revert]

verify:
  commands: []                      # ordered local gate
  hooks: null
  by_path: {}
  ci_only_notes: []
  ci_workflows: [{ name: CI, required: true }]

integrations:
  issue_tracker:
    type: none                      # jira | linear | github | none
    url_template: null              # "https://…/browse/{key}"
    status_transitions: null        # see issue-transitions.md

pr:
  title_format: "[{prefix}-{number}]({tag}): {summary}"
  draft_until_ready: true
  required_body_sections:
    - Background
    - Purpose
    - "Review guide"
    - "Changes made"
    - Verification
  labels:
    always: []                        # applied to every PR (must exist on repo)
    by_commit_tag: {}                 # e.g. refactor: refactor, feat: enhancement
    by_path: {}                       # optional glob → extra labels
```

### PR labels

Applied in Phase 3 via `gh pr edit --add-label`. Labels must **exist on the repo**
(`gh label list`) — never invent names.

| Key             | Behavior                                                                  |
| --------------- | ------------------------------------------------------------------------- |
| `always`        | List of labels appended to every PR                                       |
| `by_commit_tag` | Map PR/commit `{tag}` → one label or comma-separated list                 |
| `by_path`       | Glob of changed paths → extra labels (e.g. `src/api/**` → api)          |

Resolve `{tag}` from the PR title (same as `commit.tags` vocabulary).

```

### PR title placeholders

| Placeholder | Source |
|-------------|--------|
| `{prefix}`, `{number}` | Ticket key from branch or issue tracker |
| `{tag}` | Primary semantic type — same vocabulary as `commit.tags` (`feat`, `fix`, `chore`, …) |
| `{summary}` | Short description of what the PR delivers |

**Format:** `[TICKET](type): Description` — e.g. `[PROJ-42](feat): Add user authentication`.

Use a **colon** after `({tag})` in PR titles. Commit messages use a **space** instead:
`[PROJ-42](feat) Add user authentication`.

Pick `{tag}` from the dominant change type (same rule as the first/primary commit on the branch).

---

## Issue tracker types

| `type` | Agent behavior |
|--------|----------------|
| `jira` | Atlassian MCP: `jira_get_issue`, comments, links. Auto-assign unassigned issues to the authenticated JIRA user at intake ([issue-transitions.md](issue-transitions.md#unassigned-tickets-jira)) |
| `linear` | Linear MCP if configured; else user pastes issue |
| `github` | `gh issue view`, `gh pr list` |
| `none` | User describes task; no external fetch |

### Status transitions (JIRA)

Configure `status_transitions.implementation_start` and `status_transitions.pr_ready`
to move tickets at implement start and PR ready. Full algorithm:
[issue-transitions.md](issue-transitions.md).

---

## Examples

- [examples/generic.project.yaml](examples/generic.project.yaml) — minimal starter (any repo)
- [examples/jira-project.project.yaml](examples/jira-project.project.yaml) — JIRA + status transitions

---

## Setup checklist

```

- [ ] .handle-task/project.yaml committed or documented
- [ ] memory.local_specs in .gitignore
- [ ] verify.commands aligned with CI
- [ ] issue_tracker.type matches team's tool
- [ ] status_transitions configured (JIRA transition action names verified)
- [ ] Global skills installed (install-skills.sh)

```
```
