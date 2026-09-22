# Quick start (agents)

## How to invoke

| Skill                 | Command               | When                                              |
| --------------------- | --------------------- | ------------------------------------------------- |
| **Handle task**       | `/handle-task`        | Ticket assigned → spec → implement → verify       |
| **Pull request** | `/pull-request`  | Create/update PR → CI → review → conflicts → ready |
| **Create ticket**     | `/create-ticket`      | Brief/context → draft + create well-documented ticket |
| **Review ticket**     | `/review-ticket`      | Quality gate, backfill, scope check on existing ticket |

**One name, one folder:** the skill directory is `handle-task-skill/`. Cursor invokes it as
**`/handle-task`** (from `SKILL.md` → `name: handle-task`).

## First step (every session)

1. Read **`.handle-task/project.yaml`** in the workspace root.
2. If missing, copy `handle-task-skill/examples/generic.project.yaml` → `.handle-task/project.yaml`
   and ask the user to confirm settings.

## Two-skill split

```
/handle-task          Phases 1–8: intake → spec → plan → implement → local verify
/pull-request         Phases 0–7: create/update PR → CI → review → merge-ready
/create-ticket        Intake context → draft → create → /review-ticket → split/backfill
/review-ticket        Fetch → four-point quality review → backfill / split proposal
```

Install all entry skills once (global):

```bash
./handle-task-skill/scripts/install-skills.sh
# optional: ./handle-task-skill/scripts/install-skills.sh --install-hook
```

Global install symlinks into `~/.cursor/skills/` (Cursor) and `~/.claude/skills/`
(Claude Code). Skill edits apply in all projects. Reload Cursor or restart Claude Code
after `SKILL.md` frontmatter changes.

## Issue status transitions

When `status_transitions` is set in config (JIRA):

| When                                     | Transition (example) | Target status (example) |
| ---------------------------------------- | -------------------- | ----------------------- |
| Start implement (`/handle-task` Phase 7) | `Assign`             | In Progress             |
| PR ready (`/pull-request` Phase 7)  | `Review`             | Ready for Review        |

**Unassigned tickets:** at intake (Phase 1), if the issue has no assignee, assign it to
the authenticated JIRA user running the skill before continuing.

Details: [issue-transitions.md](issue-transitions.md)

## Issue trackers (not JIRA-only)

Use whatever the project configures in `integrations.issue_tracker.type`:

| Type     | How agents fetch tickets               |
| -------- | -------------------------------------- |
| `jira`   | Atlassian MCP (`jira_get_issue`, etc.) |
| `linear` | Linear MCP or user-pasted ticket       |
| `github` | `gh issue view`                        |
| `none`   | User describes the task in chat        |

Branch names and commits use `ticket.prefix` from config (e.g. `PROJ-123`, `ENG-456`).

## File map

| File                                                           | Purpose                       |
| -------------------------------------------------------------- | ----------------------------- |
| [SKILL.md](SKILL.md)                                           | Full handle-task orchestrator |
| [specify.md](specify.md)                                       | Spec + approval gate          |
| [plan-and-tasks.md](plan-and-tasks.md)                         | Plan + approval gate          |
| [verification.md](verification.md)                             | Local test/lint commands      |
| [pull-request/workflow.md](pull-request/workflow.md) | PR workflow                   |
| [create-ticket/workflow.md](create-ticket/workflow.md) | Create well-documented tickets |
| [review-ticket/workflow.md](review-ticket/workflow.md) | Review and backfill tickets |
| [review-ticket/quality-gate.md](review-ticket/quality-gate.md) | Four-point ticket review |
| [issue-tracker-adapters.md](issue-tracker-adapters.md) | Fetch/create/update by tracker type |
| [project-config.md](project-config.md)                         | Config schema                 |
| [subtask-template.md](subtask-template.md)                       | Split work → subtasks         |
| [pr-splitting.md](pr-splitting.md)                             | When/how to split + stacked PRs |

### Standalone delegates (self-contained — no external agent-skills bundle)

| Delegate                                                         | Purpose                                     |
| ---------------------------------------------------------------- | ------------------------------------------- |
| [spec-driven-development.md](spec-driven-development.md)         | Spec process, assumptions, capability maps  |
| [planning-and-task-breakdown.md](planning-and-task-breakdown.md) | Vertical slices, reuse discovery            |
| [incremental-implementation.md](incremental-implementation.md)   | Slice cycle, REUSE, SOLID                     |
| [test-driven-development.md](test-driven-development.md)         | RED → GREEN → REFACTOR                        |
| [spec-adherence.md](spec-adherence.md)                           | Spec ↔ test traceability; gap reports         |
| [self-improvement.md](self-improvement.md)                       | Patch skill on mistakes / user feedback       |
| [documentation-and-adrs.md](documentation-and-adrs.md)           | ADRs, wire formats                            |
| [code-review.md](code-review.md)                                 | Five-axis review + test robustness          |
| [performance-optimization.md](performance-optimization.md)       | Measure-first perf workflow                 |
