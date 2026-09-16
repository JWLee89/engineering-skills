# Handle task — Spec definition

Read during **Specify** phases of [SKILL.md](SKILL.md). Base process:
[spec-driven-development.md](spec-driven-development.md). This file adds local path
conventions from `.handle-task/project.yaml` and the **spec approval gate**.

## When to run

- After Phase 1 (Intake) and Phase 3 (Split decision) are complete
- Before any plan, committed memory setup, branch checkout, or code
- When resuming a ticket and scope has shifted — update spec first, re-run this gate

**Skip** for trivial one-file fixes (orchestrator skips the whole spec flow).

______________________________________________________________________

## Phase 2: Scope check

Run [spec-driven-development.md](spec-driven-development.md) **Phase 0** when the ticket
bundles **independently testable capabilities** (distinct consumers, separate
acceptance clusters, or one piece could ship without the others).

### Output paths (local — never commit)

Use `{local_specs}` and lowercase ticket key from config (e.g. `tasks/proj-123/` for `PROJ-123`).

| Situation         | Artifacts                                                          |
| ----------------- | ------------------------------------------------------------------ |
| Single capability | `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md`                  |
| Multi-capability  | `{local_specs}/<ticket_key_lower>/CAPABILITY-MAP.md` + per-module specs |

Templates: [Spec](templates.md#spec-local_specsticket_key_lowerspec-slugmd) and
[Capability map](templates.md#capability-map-local_specsticket_key_lowercapability-mapmd).

### Multi-module order

1. Write capability map only — **stop for map approval** (see gate below)
2. After map approved, write one module spec at a time
3. First module spec must be approved before planning that module

______________________________________________________________________

## Phase 4: Write the spec

Write the spec **before** any plan or code. Use the template in [templates.md](templates.md).

### Naming convention

```
{local_specs}/
  plan-<ticket_key_lower>.md      # written later — after spec approval
  todo-<ticket_key_lower>.md      # written later — after spec approval
  <ticket_key_lower>/
    CAPABILITY-MAP.md             # if multi-module
    SPEC-<module-slug>.md
```

### Required sections

Every spec must include:

- Issue link (`url_template`), branch name, base branch (`git.default_base` from config)
- **Assumptions I'm making** (numbered — ask for correction)
- Objective + success criteria (testable)
- **Commands** — real verify commands from config or discovered from the repo
- Boundaries: Always / Ask first / Never
- Out of scope (explicit)

### Codebase reading

Before writing, read relevant modules and adjacent patterns in the repo. Record
**current state** and **expected file changes** in the spec — do not guess from the tracker alone.

### Wire-format / constants convention

When the task introduces typed records for an external JSON or API shape:

- Align dataclass field names with wire keys when possible; serialize with `asdict()` (not manual key lists)
- Use named mapping dicts only when internal and external names differ
- Legacy ingest aliases get **named attributes** on the relevant business-object grouping
- **Single source of truth for keys:** define each wire/metadata string **once** in the entity module
- Tests: derive expected key sets from `fields(Model)`; assert representative values separately
- Tests: **name shape/dimension constants once**; build fixtures and assertions from them
- Tests: prefer **`@pytest.mark.parametrize`** when behavior varies by inputs

See [documentation-and-adrs.md](documentation-and-adrs.md) → **Schema and wire formats**.
Test patterns: [verification.md](verification.md#test-robustness).

______________________________________________________________________

## Spec approval gate (hard stop)

Run this **after** the spec (or capability map + first module spec) is written.

### 1. Summarize for the user

Provide:

- Paths to spec files under `{local_specs}`
- 3–5 bullet highlights (objective, approach, main risks)
- Numbered assumptions still open
- Out-of-scope items explicitly deferred

### 2. Ask explicitly

Use wording like:

> Spec is at `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md` \[and capability map at `...` if applicable\].
> **Approve to proceed to planning**, or tell me what to change.

For capability maps only:

> Capability map is at `{local_specs}/<ticket_key_lower>/CAPABILITY-MAP.md`.
> **Approve module boundaries and build order** before I write module specs.

### 3. Block until explicit approval

Do **not** proceed until the user gives **explicit confirmation** (e.g. "approve",
"proceed to planning", "looks good — plan it").

| Blocked until spec approved                              |     |
| -------------------------------------------------------- | --- |
| Writing `plan-*` or `todo-*` under `{local_specs}`     | Yes |
| Creating committed task memory or updating `memory.status` | Yes |
| Checking out ticket branch                             | Yes |
| Writing or modifying product code                        | Yes |

**Do not treat as approval:** silence, implied consent, or the agent continuing because
the task "seems obvious". If the user requests changes, revise the spec and re-prompt.

On approval → proceed to [plan-and-tasks.md](plan-and-tasks.md).

______________________________________________________________________

## Anti-patterns

| Mistake                                     | Fix                                         |
| ------------------------------------------- | ------------------------------------------- |
| Implementing before spec approval           | Stop; summarize spec; wait for explicit yes |
| "Explicit or implied" approval              | Require explicit user confirmation only     |
| Skipping spec for "obvious" multi-file work | Short spec still required                   |
| Committing `{local_specs}/*`                | Specs stay local; link from committed memory only |
| Full spec pasted into committed memory      | Bullet summary + pointer to local path      |
| Writing plan during spec phase              | Plan comes after spec approval only         |

______________________________________________________________________

## See also

- [SKILL.md](SKILL.md) — full orchestrator
- [plan-and-tasks.md](plan-and-tasks.md) — next phase after spec approval
- [pr-splitting.md](pr-splitting.md) — when to split before specifying
- [spec-driven-development.md](spec-driven-development.md) — Phase 0 / assumptions / spec structure
