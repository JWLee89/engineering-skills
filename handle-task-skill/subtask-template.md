# Subtask template (split work)

Use when a parent ticket is too large for one reviewable PR. **Always create real tracker
issues** — never synthetic branch names like `PROJ-100-a` or `PARENT-1`.

Portable across trackers — substitute `{prefix}` from `.handle-task/project.yaml`
(e.g. `PROJ`, `ENG`, `ACME`). Create/link children via
[issue-tracker-adapters.md](issue-tracker-adapters.md).

______________________________________________________________________

## Rules (non-negotiable)

| Rule | Detail |
|------|--------|
| **One subtask → one PR** | Each child issue gets exactly one mergeable PR |
| **Branch = ticket key** | Git branch must match `ticket.id_pattern` (e.g. `PROJ-101`, not `PROJ-100-1`) |
| **Implement on child key** | `/handle-task PROJ-101` — not the parent key |
| **Required description sections** | Background, Description, Scope, DoD, Verification plan |
| **Link parent + blockers** | Header lines + tracker-specific links (see [Links](#links)) |
| **Human approval first** | Propose split on parent; wait for approval before creating issues |

______________________________________________________________________

## When to split

Triggered by `/review-ticket` scope check or `/handle-task` intake. Size heuristics:
[pr-splitting.md](pr-splitting.md) (~500 lines, ~15 files, etc.).

______________________________________________________________________

## Workflow

1. **Propose** — comment on parent with proposed subtasks, merge order, first implement key
2. **Approve** — wait for explicit user approval
3. **Create issues** — one per slice using template below (via adapter)
4. **Link** — parent hierarchy + merge-order relations
5. **Update parent** — subtask table, rollup DoD, verification plan
6. **Implement** — `/handle-task <child-key>` on branch `<child-key>`

______________________________________________________________________

## Description template (copy per subtask)

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

<What to build or change, **in layman terms**. Concrete files, workflow steps,
acceptance outcome. State the git branch explicitly: `{CHILD-KEY}`.>

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

---

## Verification plan

<Executable checks for this slice — map each DoD item to a command or manual step.>
```

### Summary line pattern

```
[{area}] {imperative title} ({PARENT-KEY} / {n})
```

Example: `[CI] Parallel unit and integration test jobs (PROJ-100 / 1)`

______________________________________________________________________

## Links

| Tracker | Hierarchy | Split traceability | Merge order |
| ------- | --------- | ------------------ | ----------- |
| **JIRA** | Subtask + `parent` field | `Work item split` link | `Blocks` chain |
| **Linear** | Sub-issue under parent | Parent relation | Dependency / blocked-by |
| **GitHub** | Issue reference in body | Cross-link `#parent` | Note order in parent table |
| **None** | Document in parent body | Task memory table | Numbered implement order |

### JIRA example (merge order A → B → C)

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
| Branch `PROJ-100-a` | Create `PROJ-101` child; branch `PROJ-101` |
| One PR for entire parent | Split until each PR is reviewable |
| Missing Verification plan | All required sections per child |
| Implement on parent branch | `/handle-task` on child key only |
| Subtasks without ordering when merge order matters | Blocks chain or equivalent |

______________________________________________________________________

## See also

- [pr-splitting.md](pr-splitting.md) — heuristics, stacked PRs, recovery
- [review-ticket/quality-gate.md](review-ticket/quality-gate.md) — scope check triggers split
- [create-ticket/ticket-template.md](create-ticket/ticket-template.md) — full ticket sections
- [templates.md](templates.md) — local spec/plan templates
