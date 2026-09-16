# Handle-task skills (portable)

Agent skills for **issue → implement → pull request**, usable in any repository and any
JIRA (or Linear / GitHub Issues) project.

## How to invoke (read this first)

| What you type            | Skill                                  | Purpose                                 |
| ------------------------ | -------------------------------------- | --------------------------------------- |
| **`/handle-task`**       | `handle-task-skill/`                   | Work a ticket: spec, plan, code, verify |
| **`/make-pull-request`** | `handle-task-skill/make-pull-request/` | Open draft PR, run CI, mark ready       |

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

For JIRA projects, start from [examples/jira-project.project.yaml](examples/jira-project.project.yaml).

Commit `.handle-task/project.yaml` so all agents share the same settings.

Add `memory.local_specs` (default `tasks/`) to `.gitignore`.

## Bundle layout

```
<repo-root>/
├── handle-task-skill/       ← /handle-task
│   ├── SKILL.md
│   ├── QUICKSTART.md        ← agents start here
│   ├── project-config.md
│   ├── make-pull-request/   ← /make-pull-request (same bundle)
│   │   ├── SKILL.md
│   │   └── workflow.md
│   ├── spec-driven-development.md      ┐
│   ├── planning-and-task-breakdown.md  │ standalone delegates
│   ├── incremental-implementation.md   │ (no external agent-skills)
│   ├── documentation-and-adrs.md       │
│   ├── code-review.md                  │
│   ├── performance-optimization.md     ┘
│   └── scripts/install-skills.sh
└── .handle-task/
    └── project.yaml         ← per-project settings
```

Delegates are **in-repo** so PR feedback and project conventions stay with the bundle.
Install symlinks only `handle-task` and `make-pull-request` entry skills; delegates load
via relative paths inside this folder.

## Issue trackers

Not JIRA-specific. Set in `.handle-task/project.yaml`:

```yaml
integrations:
  issue_tracker:
    type: jira    # jira | linear | github | none
    url_template: "https://your-org.atlassian.net/browse/{key}"
```

Agents use the matching tool (Atlassian MCP, `gh issue`, user paste, etc.).

### Status transitions (JIRA)

When configured, agents move tickets automatically at implementation start and when the PR
is marked ready for review. Transition **action names** (e.g. `Assign`, `Review`) vary by
JIRA workflow — configure them in project.yaml. See [issue-transitions.md](issue-transitions.md).

Unassigned tickets are auto-assigned to the authenticated JIRA user at intake.

## Updating

Edit files in `handle-task-skill/`. Symlinks pick up content changes immediately; reload
Cursor to refresh skill metadata.

If you move this repository, run:

```bash
./handle-task-skill/scripts/install-skills.sh --update
```

Manifest (global): `~/.config/handle-task-skills/source`

**Agents:** read [QUICKSTART.md](QUICKSTART.md) at the start of every `/handle-task` session.
