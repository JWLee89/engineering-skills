# Issue splitting and stacked PRs

Use when an issue/ticket, spec, or in-progress branch exceeds reviewable size.
Works with JIRA, Linear, GitHub Issues, or any tracker — create sub-issues in the
tool your project uses (`integrations.issue_tracker.type` in config).

## Size heuristics

Split or create subtasks when **any** threshold is likely exceeded:

| Signal           | Threshold                                                                                    |
| ---------------- | -------------------------------------------------------------------------------------------- |
| Diff size        | ~500+ lines changed                                                                          |
| File count       | ~15+ files                                                                                   |
| Task granularity | Any step touches >5 files ([planning-and-task-breakdown.md](planning-and-task-breakdown.md)) |
| Review domains   | Different reviewers for infra vs product code                                                |
| Capabilities     | Capability map has >1 module with independent acceptance                                     |

Re-check after each implementation phase — scope creep is the usual trigger.

## Pattern: parent task → JIRA subtasks (preferred over branch suffixes)

When a ticket is too large for one reviewable PR, **create real JIRA subtasks** — not
synthetic branch names like `PROJ-100-a`. Each subtask gets its own key, branch, and PR.

Example split (illustrative):

```
PROJ-100  Task — parent (coordination; closes when last subtask merges)
├── PROJ-101  Subtask — foundation (entities + helpers)
├── PROJ-102  Subtask — core logic        (blocked by 101)
└── PROJ-103  Subtask — integration       (blocked by 102)
```

Epic-level splits use sibling **Tasks** under an Epic instead:

```
PROJ-50  Epic
├── PROJ-51  Task — scaffolding
├── PROJ-52  Task — shared layer
└── …
```

Each child should:

- Have **one primary acceptance outcome**
- Map to **exactly one PR** on branch matching `ticket.id_pattern` (e.g. `PROJ-101`)
- Use the **four required sections** in the JIRA description — see
  [jira-subtask-template.md](jira-subtask-template.md): **Background**, **Description**,
  **Scope**, **DoD (Definition of Done)**
- Header links: **Parent**, **Epic** (if any), **Depends on**, **Blocks** (when ordered)
- Leave the repo **green** when merged

**Canonical template:** [jira-subtask-template.md](jira-subtask-template.md)

## Tracker operations (JIRA via Atlassian MCP)

### 1. Propose split (before creating issues)

Post a comment on the parent summarizing:

- Proposed subtasks (title + one-line scope)
- Merge order + **Blocks** chain
- Which subtask to implement first

Wait for human approval unless the user delegated split authority.

### 2. Create subtasks

Use `jira_create_issue` per slice. Copy the full template from
[jira-subtask-template.md](jira-subtask-template.md) — all four sections are **required**.

Minimal API sketch (fill from template):

```text
project_key: <ticket.prefix from config>
issue_type: Subtask          # when parent is a Task; use Task under Epic otherwise
summary: [{area}] {title} ({PARENT-KEY} / {n})
assignee: <current user>
description: |
  <paste Background, Description, Scope, DoD from jira-subtask-template.md>
additional_fields: {"parent": "<PARENT-KEY>", "labels": ["<team-label>"]}
```

**Branch after create:** `git checkout -b <CHILD-KEY>` — e.g. `PROJ-101`, never `PROJ-100-1`.

**Link subtasks to parent:**

| Link type                  | Use                                         |
| -------------------------- | ------------------------------------------- |
| **Subtask** `parent` field | JIRA hierarchy (required)                   |
| **Work item split**        | Parent *split to* each child (traceability) |
| **Blocks**                 | 101 blocks 102 blocks 103 (merge order)     |

```text
jira_create_issue_link: Work item split — outward PROJ-100, inward PROJ-101
jira_create_issue_link: Blocks — outward PROJ-101, inward PROJ-102
```

Do **not** use branch suffixes (`PROJ-100-a`) when real subtask keys exist.

### 3. Update parent ticket

Rewrite parent description to:

- State it is a **coordination / parent** ticket
- Table of subtasks with links, scope, branch names
- Parent **DoD** = all subtasks merged + aggregate acceptance
- Parent **Verification plan** = rollup from subtasks
- Design decisions that apply to all slices

Also `jira_add_comment` with merge order and local spec path.

### 4. Local artifacts

Use `{ticket_key_lower}` = lowercase ticket key for filesystem paths (e.g. `proj-100`).

| Artifact           | Path                                                                 |
| ------------------ | -------------------------------------------------------------------- |
| Shared spec        | `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md`                    |
| Parent plan        | `{local_specs}/plan-<ticket_key_lower>.md`                           |
| Parent todo        | `{local_specs}/todo-<ticket_key_lower>.md` (checklist per subtask)   |
| Optional per-child | `{local_specs}/plan-<child_key_lower>.md` when slice needs extra detail |
| Committed memory   | `{memory.committed_tasks}/<ticket_key_lower>-<slug>.md` when configured |

**Implement with `/handle-task PROJ-101`** (subtask key), not the parent.

Branch: **subtask key only** (e.g. `PROJ-101`) — never `PROJ-100-a`.

## Stacked PRs (ordered merge by subtask key)

When subtask B depends on A but both are ready for review:

1. Merge PR for **PROJ-101** first (or get it approved)
2. Branch **PROJ-102** from merged base; if 101 not merged yet, open PR stacked on 101's branch
3. PR title/body reference **subtask key** and parent: `[PROJ-102](feat): … — part of PROJ-100`
4. PR description: **Stacked on #NNN** · merge order **101 → 102 → 103**
5. After A merges, rebase B onto `git.pr_target` from config

Avoid stacking more than **2–3** PRs deep — merge frequently. Close **parent** when the last subtask merges.

## PR-too-big recovery (branch already bloated)

1. Identify the **smallest shippable prefix** of commits (git log / diff stat)
2. Create JIRA subtask for "Part 1" if not already split
3. Interactive recovery options (pick one with user):
   - **Soft split:** new branch from base, cherry-pick prefix commits → PR-A; remainder → PR-B
   - **Reset scope:** revert out-of-scope files from branch; track reverted work in new subtask
4. Never force-push shared branches without explicit user request

## Naming conventions

All patterns derive from `.handle-task/project.yaml` — do not hardcode a project prefix.

| Item              | Pattern                                                                 |
| ----------------- | ----------------------------------------------------------------------- |
| Git branch        | `ticket.id_pattern` expanded (e.g. `PROJ-123`)                        |
| PR title          | `pr.title_format` (e.g. `[PROJ-123](feat): Add user authentication`)    |
| Spec folder       | `{local_specs}/<ticket_key_lower>/` (e.g. `tasks/proj-123/`)            |
| Committed memory  | `{memory.committed_tasks}/<ticket_key_lower>-<kebab-slug>.md`           |

## When **not** to split

- Tightly coupled change that fails tests if split (document why in spec)
- User explicitly wants one PR for audit/traceability
- Subtasks would each be \<50 lines — combine instead
