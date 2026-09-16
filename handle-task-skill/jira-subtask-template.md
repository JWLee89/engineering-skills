# JIRA subtask template (split work)

Use when a parent ticket is too large for one reviewable PR. **Always create real tracker
issues** — never synthetic branch names like `PROJ-100-a` or `PARENT-1`.

Portable across JIRA projects: substitute `{prefix}` from `.handle-task/project.yaml`
(e.g. `PROJ`, `ENG`, `ACME`).

______________________________________________________________________

## Rules (non-negotiable)

| Rule | Detail |
|------|--------|
| **One subtask → one PR** | Each child issue gets exactly one mergeable PR |
| **Branch = ticket key** | Git branch must match `ticket.id_pattern` (e.g. `PROJ-101`, not `PROJ-100-1`) |
| **Implement on child key** | `/handle-task PROJ-101` — not the parent key |
| **Required description sections** | Background, Description, Scope, DoD (see below) |
| **Link parent + blockers** | Header lines + JIRA link types (see [Links](#links)) |
| **Human approval first** | Propose split on parent; wait for approval before creating issues |

______________________________________________________________________

## When to split

See [pr-splitting.md](pr-splitting.md) for size heuristics (~500 lines, ~15 files, etc.).

______________________________________________________________________

## Workflow

1. **Propose** — comment on parent with proposed subtasks, merge order, first implement key
2. **Approve** — wait for explicit user approval (unless split authority delegated)
3. **Create issues** — one per slice using template below
4. **Link** — parent hierarchy + Work item split + Blocks chain
5. **Update parent** — subtask table, rollup DoD, verification plan
6. **Implement** — `/handle-task <child-key>` on branch `<child-key>`

______________________________________________________________________

## Description template (copy per subtask)

Use `jira_create_issue` (or your tracker UI). For JIRA **Subtask** under a Task:

```markdown
**Parent:** [{PARENT-KEY}]({url_template})
**Epic:** [{EPIC-KEY}]({url_template})   ← omit if none
**Depends on:** [{BLOCKER-KEY}]({url_template})   ← omit if none
**Blocks:** [{BLOCKED-KEY}]({url_template})   ← omit if none

---

## Background

<Why this slice exists. Link parent, prior merged subtasks, constraints from spec.
Include baseline metrics or repo state the implementer needs.>

Local spec: `{local_specs}/<parent_key_lower>/SPEC-<slug>.md` (if applicable)

---

## Description

<What to build or change. Concrete files, workflow steps, acceptance outcome.
State the git branch explicitly: `{CHILD-KEY}`.>

---

## Scope

| In scope | Out of scope |
|----------|--------------|
| ... | ... |

---

## DoD (Definition of Done)

- [ ] <testable checklist item>
- [ ] PR merged to `{git.pr_target}` on branch `{CHILD-KEY}`
- [ ] Parent rollup updated if needed
```

### Summary line pattern

```
[{area}] {imperative title} ({PARENT-KEY} / {n})
```

Example: `[Engine] Parallel unit and integration CI jobs (PROJ-100 / 1)`

The `/ {n}` ordinal is optional but helps ordering in the parent table.

______________________________________________________________________

## Links

| Link | JIRA API | Purpose |
|------|----------|---------|
| **Subtask parent field** | `additional_fields: {"parent": "PROJ-100"}` | Hierarchy (required for Subtask) |
| **Work item split** | `link_type: Work item split`, outward parent, inward child | Traceability |
| **Blocks** | `link_type: Blocks`, outward predecessor, inward successor | Merge / implement order |

Example merge order **A → B → C**:

```text
Blocks: PROJ-101 blocks PROJ-102
Blocks: PROJ-102 blocks PROJ-103
```

Under an **Epic**, siblings may be full **Tasks** (not Subtasks) — same template sections apply.

______________________________________________________________________

## Parent ticket update

After creating children, rewrite the parent description to include:

1. **Background** — coordination role, end-state summary
2. **Subtask table** — order, key, scope, branch, depends-on column
3. **DoD (parent)** — all children merged + aggregate acceptance
4. **Verification plan** — rollup from children
5. Explicit note: **implement on child keys only**

Add a parent comment with merge order and local plan path.

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
|---------|-----|
| Branch `PROJ-100-a` | Create `PROJ-101` subtask; branch `PROJ-101` |
| One PR for entire parent | Split until each PR is reviewable |
| Missing Scope / DoD | Use all four required sections |
| Implement on parent branch | `/handle-task` on child key only |
| Subtasks without Blocks when order matters | Add Blocks chain + document in parent |

______________________________________________________________________

## See also

- [pr-splitting.md](pr-splitting.md) — heuristics, stacked PRs, recovery
- [SKILL.md](SKILL.md) — Phase 3 split decision
- [templates.md](templates.md) — local spec/plan templates
