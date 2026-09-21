# Review ticket — workflow

**Entry:** [SKILL.md](SKILL.md). Load `.handle-task/project.yaml`
([../project-config.md](../project-config.md)) before starting.

```
Phase 0  Load config
Phase 1  Fetch ticket
Phase 2  Four-point quality review
Phase 3  Split? → propose sub-tasks → approve → create children
Phase 4  Backfill + confirm
```

______________________________________________________________________

## Phase 0: Load config

1. Read `.handle-task/project.yaml`.
2. Note `integrations.issue_tracker.type`, `url_template`, `ticket.prefix`,
   `memory.*`, and `git.*` for placeholder expansion.
3. Identify the tracker adapter row in
   [../issue-tracker-adapters.md](../issue-tracker-adapters.md).

If `type: none` and no ticket is pasted, ask the user for the full ticket content or a
task description to review.

______________________________________________________________________

## Phase 1: Fetch ticket

| Input | Action |
| ----- | ------ |
| Ticket key / number (e.g. `PROJ-2496`, `#42`) | Fetch via adapter; read title + full description + links |
| Pasted description | Use as-is; ask for key if missing |
| URL only | Parse key/number; fetch via adapter |

Also pull context when helpful:

- Related / linked tickets (transitive for blockers and parents)
- Comments with decisions or clarifications
- `memory.decisions`, committed task files, `agent_guide`

Record **assumptions** if the user confirms inferred context.

______________________________________________________________________

## Phase 2: Four-point quality review

Run [quality-gate.md](quality-gate.md) against the fetched ticket.

1. Check required sections exist: Background, Description, Scope, DoD, Verification plan.
2. Score all four checks; produce the reporting table.
3. Route failures:
   - Check 2 fail (too big) → Phase 3
   - Checks 1, 3, 4 fail → Phase 4
   - Missing required sections → Phase 4 (treat as check failure)

If all pass → report ✅ table and suggest `/handle-task {KEY}` if implementation is next.

______________________________________________________________________

## Phase 3: Split into sub-tasks (scope too large)

Follow [../subtask-template.md](../subtask-template.md). **Approval-first.**

1. **Propose** — comment on parent (via adapter) or present in chat: subtask list,
   merge order, first implement key. Each proposed child includes all required sections.
2. **Approve** — wait for explicit user approval.
3. **Create** — one real child ticket per slice via adapter.
4. **Link** — parent hierarchy + merge-order links (tracker-specific — see adapter doc).
5. **Update parent** — subtask table, rollup DoD, rollup verification plan;
   note "implement on child keys only."
6. Re-run Phase 2 on each child.

Never create synthetic branch names. Branch = real child ticket key.

______________________________________________________________________

## Phase 4: Backfill + confirm

When any quality check fails (except unapproved split):

1. **Ask clarifying questions** — numbered, one per gap (see
   [quality-gate.md#backfill-procedure](quality-gate.md#backfill-procedure-checks-1-3-4-failure)).
2. On user reply, **rewrite** the ticket body using
   [../create-ticket/ticket-template.md](../create-ticket/ticket-template.md).
3. **Apply** via tracker adapter (`jira_update_issue`, `gh issue edit`, user paste, etc.).
4. **Confirm** — re-state changes; re-run Phase 2. Do not finish until user confirms or
   explicitly accepts documented gaps.

______________________________________________________________________

## Output to user

- Ticket key + URL (if available).
- Four-row quality table with evidence.
- List of backfills applied or still open.
- Split proposal (if Phase 3 ran).
- Suggested next step: `/handle-task {KEY}` or continue refining.

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Reviewing without fetching latest description | Always fetch via adapter first |
| Shrinking scope in prose instead of splitting | Phase 3 when too big |
| Backfill that drops Verification plan | Preserve all required sections |
| Declaring ready with unchecked gaps | User must confirm or accept assumptions |
