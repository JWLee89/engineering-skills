# Create ticket — workflow

**Entry:** [SKILL.md](SKILL.md). Load `.handle-task/project.yaml`
([../project-config.md](../project-config.md)) before starting.

```
Phase 0  Load config
Phase 1  Intake context (gather until enough)
Phase 2  Draft ticket description
Phase 3  Create ticket
Phase 4  Quality review (/review-ticket)
Phase 5  Split? → propose sub-tasks → approve → create children
Phase 6  Backfill + confirm
```

______________________________________________________________________

## Phase 0: Load config

1. Read `.handle-task/project.yaml`.
2. Note `integrations.issue_tracker.type`, `ticket.prefix`, `git.pr_target`,
   `url_template`, `memory.*`, and `verify.*` for the Verification plan.
3. Open the matching adapter in [../issue-tracker-adapters.md](../issue-tracker-adapters.md).

If `type: none`, tell the user the draft will be presented for manual creation unless they
configure a tracker.

______________________________________________________________________

## Phase 1: Intake context

**Goal:** gather enough context to write a complete, onboarder-readable ticket.

| Source | How to gather |
| ------ | ------------- |
| **Related tickets** | User gives keys/numbers. Fetch via adapter; read description, links, comments. Pull parent/epic/blocker context when relevant. |
| **Wiki / internal docs** | Confluence MCP, user URLs, repo docs. |
| **Context banks (pasted)** | Briefs, design notes, meeting notes, spec excerpts. |
| **Context banks (files)** | User points at local paths — read them; never assume paths. |
| **Skill / repo memory** | `memory.decisions`, `memory.status`, committed task files, `agent_guide`. |

### Context sufficiency check

Before drafting, confirm you can answer:

- What is the task, in one sentence a non-engineer could repeat?
- Which repo / module / files are involved?
- What does "done" look like (observable)?
- What is explicitly **not** in scope?
- Which prior tickets or decisions constrain this one?

If any answer is missing, **ask clarifying questions** now — do not draft on assumptions.
Record confirmed assumptions for the draft.

Reference ticket shapes (for inspiration):

- **Background-heavy** — explains *why* the task exists; links blockers, prior work, and constraints
- **Step-by-step** — numbered commands, settings, paths, and dependencies
- **Ops-style** — background, execution steps, and observable DoD (uploads, reports, release notes)

______________________________________________________________________

## Phase 2: Draft ticket description

Build from [ticket-template.md](ticket-template.md). Required sections:

1. **Background** — why; linked tickets; baseline state.
2. **Description** — **layman terms**, for agents and humans. State git branch `{TICKET-KEY}`.
3. **Scope** — in / out of scope table.
4. **DoD** — testable checklist; PR merged to `git.pr_target`.
5. **Verification plan** — executable steps; each DoD item → command, CI workflow, or manual check.

### Drafting rules

- Write **Description** so a new onboarder understands the task without prior context.
- **Verification plan** must be executable (mirror PR verification style in
  [../templates.md](../templates.md#verification-plan-pr-body)).
- Cite source tickets by link — do not copy entire bodies.
- Do **not** invent ticket keys, branch names, or assignees.

Present the draft to the user for review before creating.

______________________________________________________________________

## Phase 3: Create ticket

Use the adapter for `integrations.issue_tracker.type`
([../issue-tracker-adapters.md](../issue-tracker-adapters.md)).

1. Resolve fields:
   - **Project / repo** — from `ticket.prefix` or user input.
   - **Issue type** — ask if not obvious (Task, Story, Bug, …).
   - **Summary** — `[{area}] {imperative title}` (see template).
   - **Assignee** — only if user specifies; otherwise leave unassigned.
   - **Epic / parent** — only if user provides and confirms.
2. Create via adapter (`jira_create_issue`, `gh issue create`, Linear MCP, etc.).
3. Capture the new key from the response.
4. Set parent/epic links if confirmed (adapter-specific).
5. Build URL from `url_template` and report to user.

If no API (`type: none`), save draft to `memory.local_specs/tickets/` and instruct user
to create manually.

______________________________________________________________________

## Phase 4: Quality review

Run **`/review-ticket`** on the new key — or execute
[../review-ticket/workflow.md](../review-ticket/workflow.md) Phases 2–4 inline.

Mandatory four-point gate: [../review-ticket/quality-gate.md](../review-ticket/quality-gate.md).

- All pass → Phase 6 output.
- Scope too big → Phase 5.
- Other failures → Phase 6 backfill.

______________________________________________________________________

## Phase 5: Split into sub-tasks (only if too big)

Follow [../subtask-template.md](../subtask-template.md). **Approval-first.**

1. Propose subtasks on parent (comment or chat).
2. Wait for approval.
3. Create real child tickets via adapter — each with all required sections.
4. Link + update parent rollup.
5. Re-run Phase 4 on each child.

______________________________________________________________________

## Phase 6: Backfill + confirm

When quality checks fail — here or at `/handle-task` intake — follow
[../review-ticket/workflow.md#phase-4-backfill--confirm](../review-ticket/workflow.md).

Do not declare done until the user confirms the ticket is complete.

______________________________________________________________________

## Output to user

- New ticket key + URL.
- Quality review table (4 rows).
- Open clarifying questions (if any).
- Suggested next step: `/handle-task {NEW-KEY}`.

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Drafting on thin context | Phase 1 sufficiency check |
| Missing Description or Verification plan | Required sections in Phase 2 |
| Skipping review after create | Phase 4 mandatory |
| JIRA-only APIs in this workflow | Use [../issue-tracker-adapters.md](../issue-tracker-adapters.md) |
| Synthetic sub-task branch names | Real ticket keys only |
