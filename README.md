# Engineering skills

Portable [Cursor Agent Skills](https://cursor.com/docs/agent/skills) and
[Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills) for
software engineering workflows.

Each skill is a self-contained folder with a `SKILL.md` entry point, optional delegate
docs, and install scripts. Skills are **repository-agnostic** — per-project settings live
in your target repo under `.handle-task/project.yaml` (or equivalent config documented by
each skill).

## Available skills

| Skill | Invoke | Purpose |
| ----- | ------ | ------- |
| [handle-task-skill](handle-task-skill/) | `/handle-task` | Ticket → spec → plan → implement → verify |
| *(same bundle)* | `/pull-request` | PR lifecycle → CI → review → merge-ready |
| *(same bundle)* | `/create-ticket` | Draft + create well-documented tickets (any tracker) |
| *(same bundle)* | `/review-ticket` | Four-point quality gate, backfill, scope check |

## Quick start

### 1. Clone and install globally

```bash
git clone https://github.com/JWLee89/engineering-skills.git
cd engineering-skills
./handle-task-skill/scripts/install-skills.sh
```

This symlinks `handle-task`, `pull-request`, `create-ticket`, and `review-ticket` into:

- `~/.cursor/skills/` (Cursor)
- `~/.claude/skills/` (Claude Code)

Reload Cursor after install. Restart Claude Code if `/handle-task` does not appear.

### 2. Configure a target repository

In the repo where you work tickets:

```bash
mkdir -p .handle-task
cp /path/to/engineering-skills/handle-task-skill/examples/generic.project.yaml .handle-task/project.yaml
```

Edit `.handle-task/project.yaml`:

| Field | Example | Purpose |
| ----- | ------- | ------- |
| `ticket.prefix` | `PROJ`, `ENG`, `ACME` | Issue key prefix and branch names |
| `git.pr_target` | `main` | PR base branch |
| `verify.commands` | `npm test`, `pytest` | Local verification before PR |
| `integrations.issue_tracker.type` | `jira` | Tracker integration |
| `integrations.issue_tracker.url_template` | `https://org.atlassian.net/browse/{key}` | Issue links |

For a JIRA-backed setup, copy
[handle-task-skill/examples/jira-project.project.yaml](handle-task-skill/examples/jira-project.project.yaml)
instead.

Commit `.handle-task/project.yaml`. Add local spec dir (default `tasks/`) to `.gitignore`.

### 3. Work a ticket

```
/handle-task PROJ-123
```

Then, when implementation is verified locally:

```
/pull-request
```

See [handle-task-skill/QUICKSTART.md](handle-task-skill/QUICKSTART.md) for the full workflow.

### Splitting large tickets

When a ticket exceeds reviewable size, create **real subtasks** (one PR each). Each
subtask description must include **Background**, **Description**, **Scope**, **DoD**, and
**Verification plan**. Git branch must match the subtask key (`PROJ-101`) — never synthetic
suffixes (`PROJ-100-1`).

Template: [handle-task-skill/subtask-template.md](handle-task-skill/subtask-template.md)

## Vendor into a monorepo (optional)

Copy or submodule `handle-task-skill/` into your project and run project-scoped install:

```bash
./handle-task-skill/scripts/install-skills.sh --project
```

Symlinks land in `./.cursor/skills/` and `./.claude/skills/` relative to that repo.

## Contributing

1. Fork and branch from `main`
2. Make changes under the relevant skill folder
3. Open a PR using the repository PR template
4. After merge, re-run `./handle-task-skill/scripts/install-skills.sh --update` if you
   install from a local clone

## License

[MIT](LICENSE)
