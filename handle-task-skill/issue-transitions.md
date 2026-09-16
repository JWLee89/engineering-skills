# Issue status transitions

Move tickets on the issue tracker at defined workflow points. Configured in
`.handle-task/project.yaml` under `integrations.issue_tracker.status_transitions`.

**Currently supported:** JIRA via Atlassian MCP (`jira_get_transitions`,
`jira_transition_issue`). Other trackers: update status manually or extend config later.

______________________________________________________________________

## When transitions fire

| Workflow point                                                | Config key             | Common JIRA pattern (varies)    |
| ------------------------------------------------------------- | ---------------------- | ------------------------------- |
| Start of **implement** (Phase 7, branch checked out)          | `implementation_start` | e.g. `Assign` → **In Progress** |
| **PR merge-ready** (`gh pr ready`, make-pull-request Phase 7) | `pr_ready`             | e.g. `Review` → **In Review**   |

Do **not** transition on spec/plan approval — only when coding starts and when PR is ready.

______________________________________________________________________

## Unassigned tickets (JIRA)

When fetching a JIRA issue during **intake** (`/handle-task` Phase 1) or before
**implementation_start**, if the issue has **no assignee**, assign it to the **authenticated
JIRA user** — the person whose credentials the Atlassian MCP session is using (the person
running the skill). They picked up the ticket; they should own it on the board.

**Why:** Unassigned tickets often block or complicate the `Assign` → In Progress transition,
and the board stays accurate without manual cleanup.

**Algorithm:**

1. **Fetch issue:** `jira_get_issue` → read `assignee`.
2. **Skip** if assignee is already set (do not reassign someone else's ticket).
3. **Resolve current user** (Cloud account ID preferred):
   - `jira_search` with JQL `assignee = currentUser() ORDER BY updated DESC`, `limit=1`,
     `fields=assignee` → use `accountId` from the result; or
   - `jira_search_assignable_users` scoped to the issue's project when the agent already
     knows the user's display name or email from context.
4. **Apply:** `jira_assign_issue` with the resolved identifier.
5. **Log** in committed task memory session log (e.g. "Auto-assigned to current user").

On failure (permission, ambiguous user match), report to the user and continue — do not
block spec/plan/implement. Ask the user to assign manually if identity cannot be resolved.

______________________________________________________________________

## Algorithm (agents)

For each configured transition at its trigger point:

1. **Skip** if `issue_tracker.type` is not `jira` or the config block is missing/disabled.
2. **Fetch issue:** `jira_get_issue` → read current `status.name`.
3. **Ensure assignee** — if unassigned, run [Unassigned tickets](#unassigned-tickets-jira)
   before transitioning (required for `implementation_start` when transition is `Assign`).
4. **Skip** if status is in `skip_if_status_in` (already at or past the target stage).
5. **List transitions:** `jira_get_transitions` for the issue key.
6. **Resolve transition ID:**
   - Prefer exact match on `transition` (JIRA transition **action** name, e.g. `Assign`, `Review`).
   - If no match, try case-insensitive match.
   - If multiple matches or none, **stop and ask the user** — do not guess.
7. **Apply:** `jira_transition_issue` with `transition_id`.
8. **Optional comment:** short note (branch name, PR link) when `comment: true` in config.
9. **Log** in committed task memory session log.

On failure (permission, workflow guard), report to user and continue the workflow — do not block implementation or PR.

______________________________________________________________________

## Config schema

```yaml
integrations:
  issue_tracker:
    type: jira
    url_template: "https://your-org.atlassian.net/browse/{key}"
    status_transitions:
      implementation_start:
        enabled: true
        transition: Assign              # JIRA transition action name
        skip_if_status_in:
          - In Progress
          - READY FOR REVIEW
          - Done
        comment: false
      pr_ready:
        enabled: true
        transition: Review
        skip_if_status_in:
          - READY FOR REVIEW
          - Done
        comment: true                   # post PR URL in transition comment
```

| Field               | Meaning                                                                            |
| ------------------- | ---------------------------------------------------------------------------------- |
| `enabled`           | `false` to skip this transition                                                    |
| `transition`        | JIRA transition **name** from `jira_get_transitions` (not the target status label) |
| `skip_if_status_in` | Skip when current status is any of these                                           |
| `comment`           | For `pr_ready`: add markdown comment with PR link during transition                |

**Finding transition names:** run `jira_get_transitions` on a ticket in the source status,
or inspect workflow in JIRA admin. Target status labels (e.g. "In Progress") differ from
transition action names (e.g. "Assign").

______________________________________________________________________

## Example workflow mapping

Your JIRA board may use different status labels and transition action names. Discover them
with `jira_get_transitions` on a ticket in the source status, then set `transition` in
config to the **action name** (not the target status label).

| From (example) | Action (`transition`) | To status (example) |
| -------------- | --------------------- | ------------------- |
| To Do          | Assign                | In Progress         |
| In Progress    | Review                | Ready for Review    |

See [examples/jira-project.project.yaml](examples/jira-project.project.yaml).

______________________________________________________________________

## Anti-patterns

| Mistake                                | Fix                                                           |
| -------------------------------------- | ------------------------------------------------------------- |
| Using target status as transition name | Use `Assign` / `Review`, not `In Progress`                    |
| Transition before plan approval        | Only at implementation start                                  |
| Transition on draft PR open            | Only at `gh pr ready`                                         |
| Silent failure                         | Log + tell user if transition fails                           |
| Transition when already Done           | Honor `skip_if_status_in`                                     |
| Leaving ticket unassigned              | Auto-assign to authenticated JIRA user when assignee is empty |
| Reassigning an owned ticket            | Only assign when assignee is missing                          |
