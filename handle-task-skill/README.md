# Handle-task skills (portable)

Agent skills for **issue → implement → pull request**, usable in any repository and any
any issue-tracker-backed project.

## How to invoke (read this first)

| What you type            | Skill                                  | Purpose                                 |
| ------------------------ | -------------------------------------- | --------------------------------------- |
| **`/handle-task`**       | `handle-task-skill/`                   | Work a ticket: spec, plan, code, verify |
| **`/pull-request`** | `handle-task-skill/pull-request/` | PR lifecycle: create, CI, review, conflicts, ready |
| **`/create-ticket`**     | `handle-task-skill/create-ticket/`     | Draft + create well-documented tickets      |
| **`/review-ticket`**     | `handle-task-skill/review-ticket/`     | Review, backfill, and scope-check tickets   |
| **`/code-review`**       | `handle-task-skill/code-review/`       | Deep PR review (draft → approve → post)     |

Large tickets: split into **real subtasks** (branch = ticket key) — see
[subtask-template.md](subtask-template.md).

There is **only one** task-handling skill name: **`handle-task`**.

## Install (once per machine)

Clone this repository (or vendor the folder into your project), then:

```bash
./handle-task-skill/scripts/install-skills.sh              # ~/.cursor/skills/ + ~/.claude/skills/
./handle-task-skill/scripts/install-skills.sh --project    # ./.cursor/skills/ only
```

Global install creates **symlinks** into both agent runtimes:

| Agent           | Personal skills path |
| --------------- | -------------------- |
| **Cursor**      | `~/.cursor/skills/`  |
| **Claude Code** | `~/.claude/skills/`  |

Edits under `handle-task-skill/` are visible in **every project** without copying files.
Reload Cursor (or restart Claude Code) after changing `SKILL.md` frontmatter.

Remove: `./handle-task-skill/scripts/install-skills.sh --remove`

Check current install: `./handle-task-skill/scripts/install-skills.sh --list`

### Auto-sync when you edit skills

Optional git hook — refreshes global symlinks after each commit that touches skill files:

```bash
./handle-task-skill/scripts/install-skills.sh --install-hook
```

## Per-project setup (once per repo)

```bash
mkdir -p .handle-task
cp handle-task-skill/examples/generic.project.yaml .handle-task/project.yaml
# edit: ticket.prefix, git.pr_target, verify.commands, issue_tracker
```

For issue trackers with automated status transitions, start from [examples/jira-project.project.yaml](examples/jira-project.project.yaml) (`type: jira`).

Commit `.handle-task/project.yaml` so all agents share the same settings.

Add `memory.local_specs` (default `tasks/`) to `.gitignore`.

## Bundle layout

```
<repo-root>/
├── handle-task-skill/       ← /handle-task
│   ├── SKILL.md
│   ├── QUICKSTART.md        ← agents start here
│   ├── project-config.md
│   ├── pull-request/        ← /pull-request
│   │   ├── SKILL.md
│   │   └── workflow.md
│   ├── create-ticket/       ← /create-ticket (same bundle)
│   │   ├── SKILL.md
│   │   ├── workflow.md
│   │   └── ticket-template.md
│   ├── review-ticket/       ← /review-ticket (same bundle)
│   │   ├── SKILL.md
│   │   ├── workflow.md
│   │   └── quality-gate.md
│   ├── code-review/         ← /code-review (same bundle)
│   │   ├── SKILL.md
│   │   ├── workflow.md
│   │   └── rubric.md
│   ├── issue-tracker-adapters.md
│   ├── subtask-template.md
│   ├── engineering-rubric.md           ┐ implement + author SSOT
│   ├── incremental-implementation.md   │
│   ├── test-driven-development.md      │ delegates (lazy-load per phase)
│   ├── spec-adherence.md               │
│   ├── self-improvement.md             │
│   ├── documentation-and-adrs.md       │
│   ├── code-review.md                  │ author pointer
│   ├── performance-optimization.md     ┘
│   ├── spec-driven-development.md      ← stub → specify.md
│   ├── planning-and-task-breakdown.md  ← stub → plan-and-tasks.md
│   └── scripts/install-skills.sh
└── .handle-task/
    └── project.yaml         ← per-project settings
```

Delegates are **in-repo** so PR feedback and project conventions stay with the bundle.
Install symlinks `handle-task`, `pull-request`, `create-ticket`, `review-ticket`, and
`code-review` entry skills; delegates load via relative paths inside this folder.

## Issue trackers

Tracker-agnostic. Set in `.handle-task/project.yaml`:

```yaml
integrations:
  issue_tracker:
    type: jira    # jira | linear | github | none
    url_template: "https://your-org.atlassian.net/browse/{key}"
```

Agents use the matching adapter ([issue-tracker-adapters.md](issue-tracker-adapters.md)).

### Status transitions

When configured, agents move work items automatically at implementation start and when the PR
is marked ready for review. Transition **action names** (e.g. `Assign`, `Review`) vary by
workflow — configure them in project.yaml. See [issue-transitions.md](issue-transitions.md).

Unassigned items may be auto-assigned to the authenticated tracker user at intake when the adapter supports it.

## Updating

Edit files in `handle-task-skill/`. Symlinks pick up content changes immediately; reload
Cursor to refresh skill metadata.

If you move this repository, run:

```bash
./handle-task-skill/scripts/install-skills.sh --update
```

Manifest (global): `~/.config/handle-task-skills/source`

**Agents:** [QUICKSTART.md](QUICKSTART.md) (nine-step workflow). **Humans:** install above; do not duplicate QUICKSTART prose here.

**Related global skills:** prefer bundle SSOT ([engineering-rubric.md](engineering-rubric.md), [code-review/rubric.md](code-review/rubric.md)) over parallel globals for the same phase.
