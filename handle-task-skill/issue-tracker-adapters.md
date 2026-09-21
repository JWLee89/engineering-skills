# Issue tracker adapters

Portable fetch / create / update operations for ticket skills (`/create-ticket`,
`/review-ticket`, `/handle-task`). Read `.handle-task/project.yaml` first —
schema in [project-config.md](project-config.md).

Skills never assume a specific tracker. Use the adapter for
`integrations.issue_tracker.type`. When no API is available, the agent works from
user-pasted content and instructs the user to apply changes in the tracker UI.

______________________________________________________________________

## Adapter matrix

| Operation | `jira` | `linear` | `github` | `none` |
| --------- | ------ | -------- | -------- | ------ |
| **Fetch ticket** | `jira_get_issue` (MCP) | Linear MCP if configured; else user paste | `gh issue view {n} --json title,body,labels,state` | User describes task in chat |
| **Search related** | `jira_search` (JQL) | Linear search MCP | `gh issue list --search` | Repo memory, user links |
| **Create ticket** | `jira_create_issue` | Linear create MCP | `gh issue create --title … --body-file …` | Present draft; user creates manually |
| **Update description** | `jira_update_issue` | Linear update MCP | `gh issue edit {n} --body-file …` | Present revised body; user applies |
| **Add comment** | `jira_add_comment` | Linear comment MCP | `gh issue comment {n} --body …` | Summarize in chat |
| **Link issues** | `jira_create_issue_link` | Linear relation APIs | Cross-reference in body (`#123`) | Note links in description |
| **Create sub-task** | Subtask issue type + `parent` field | Sub-issue under parent | Linked issue + body reference | Real child tickets only — see [subtask-template.md](subtask-template.md) |

Build ticket URLs from `integrations.issue_tracker.url_template` (`{key}` → issue key).

______________________________________________________________________

## JIRA (`type: jira`)

Requires Atlassian MCP (`jira_get_issue`, `jira_search`, `jira_create_issue`,
`jira_update_issue`, `jira_add_comment`, `jira_create_issue_link`).

- **Project key** — from `ticket.prefix` or user input.
- **Unassigned at intake** — auto-assign authenticated user per
  [issue-transitions.md#unassigned-tickets-jira](issue-transitions.md#unassigned-tickets-jira).
- **Subtasks** — issue type `Subtask`, `additional_fields: {"parent": "<PARENT-KEY>"}`.
- **Split links** — `Work item split` + `Blocks` chain — see
  [subtask-template.md](subtask-template.md#links).

Example: [examples/jira-project.project.yaml](examples/jira-project.project.yaml).

______________________________________________________________________

## Linear (`type: linear`)

Use Linear MCP when configured. Otherwise:

1. Ask the user to paste the issue (title + description).
2. For create/update, present markdown the user can paste into Linear.

Branch = issue identifier from config (`ticket.id_pattern`).

______________________________________________________________________

## GitHub Issues (`type: github`)

Requires `gh` CLI authenticated for the repo.

```bash
# Fetch
gh issue view 42 --json title,body,labels,state,url

# Create
gh issue create --title "[Area] Title" --body-file /tmp/ticket-body.md

# Update
gh issue edit 42 --body-file /tmp/ticket-body-revised.md

# Comment (split proposal)
gh issue comment 42 --body "Proposed split: …"
```

Issue number maps to `{number}` in `ticket.id_pattern` when prefix is empty or
numeric-only; otherwise use project convention from `project.yaml`.

______________________________________________________________________

## None (`type: none`)

No external tracker API. The agent:

1. Uses user-supplied brief + repo memory for context.
2. Drafts ticket content from [create-ticket/ticket-template.md](create-ticket/ticket-template.md).
3. Saves draft to `memory.local_specs/tickets/` (gitignored) if the user wants a record.
4. User creates the tracker item manually or continues with `/handle-task` using a
   synthetic key the team agrees on (document in task memory).

______________________________________________________________________

## Context sources (all types)

| Source | How |
| ------ | --- |
| **Related tickets** | User gives keys/numbers; fetch via adapter |
| **Wiki / docs** | Confluence MCP, user URLs, local markdown |
| **Context banks (pasted)** | Meeting notes, briefs, specs in chat |
| **Context banks (files)** | User-provided repo paths — read on request |
| **Skill / repo memory** | `memory.decisions`, `memory.status`, committed task files, `agent_guide` |

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Hard-coding JIRA APIs in create/review skills | Use this adapter table |
| Inventing ticket keys before creation | Create via adapter; use returned key |
| Skipping update when API unavailable | Present body diff; user applies in UI |
| Synthetic sub-task branch names (`PROJ-100-a`) | Real child tickets only |
