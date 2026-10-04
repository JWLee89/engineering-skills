# Handle task — Planning and tasks

Read during **Plan** phase of [SKILL.md](SKILL.md), **only after spec approval**
([specify.md](specify.md)).

Local path conventions and the **plan approval gate**.

## Prerequisites

- [ ] Spec (or capability map + module spec) **explicitly approved** by the user
- [ ] Split decision recorded if scope is large ([pr-splitting.md](pr-splitting.md)); oversized work → **real tracker subtasks** with [subtask-template.md](subtask-template.md) (never synthetic branches like `PROJ-100-a`)
- [ ] Phase 1 intake complete — issue context and decision-log constraints known

If spec is not approved, go back to [specify.md](specify.md) — do not plan yet.

______________________________________________________________________

## Phase 5: Write plan and todo

### Artifacts (local — never commit)

| File | Purpose |
| ---- | ------- |
| `{local_specs}/plan-<ticket_key_lower>.md` | Architecture choices, file list, risks, verification checkpoints |
| `{local_specs}/todo-<ticket_key_lower>.md` | Phased checklist — executable slices for implementation |

Templates (one file each — index: [templates.md](templates.md)):

- [Plan](references/templates/plan.md) · [index](templates.md#plan-local_specplan-ticket_key_lowermd)
- [Todo](references/templates/todo.md) · [index](templates.md#todo-local_specstodo-ticket_key_lowermd)

### Planning process (read-only)

1. Read approved spec + relevant codebase — **no code yet**
2. **Dependency graph** — foundations before dependents
3. **Vertical slices** — end-to-end paths over horizontal layers (good: schema+API+UI for one flow; bad: all schema then all API)
4. **Slice sizing** — each todo ≤ ~5 files, one focused session

### Reuse discovery (during planning)

Search for similar tasks, types, test helpers, shared utilities. Prefer **extend** over
parallel implementation. Name new abstractions in the plan with rationale
([incremental-implementation.md](incremental-implementation.md)).

### Plan must include

- Link back to approved spec path
- Verified findings from codebase (not assumptions from the tracker alone)
- Architecture decisions table (choices with rationale)
- Implementation order (numbered phases)
- Expected files changed
- Verification checkpoints with real commands ([verification.md](verification.md))
- **Isolation gates** per behavioral slice when applicable ([feature-gating.md](feature-gating.md))
- Out of scope (explicit deferrals to other tickets)

### Todo must include

Per task:

- Acceptance criteria (testable)
- **TDD order** — test file(s) first, then production ([test-driven-development.md](test-driven-development.md))
- **Isolation gate** — scoped command proving slice alone ([feature-gating.md](feature-gating.md)); `—` if N/A with reason
- **Spec link** — which success criterion / spec scenario this slice satisfies ([spec-adherence.md](spec-adherence.md))
- Verify command (after RED→GREEN→feature gate→spec adhere)
- Files expected to touch (tests before implementation for behavioral slices)
- Phase grouping aligned with [incremental-implementation.md](incremental-implementation.md) slices

______________________________________________________________________

## Plan approval gate (hard stop)

Run this **after** both plan and todo files are written.

### 1. Summarize for the user

Provide:

- Paths to plan and todo files
- Implementation order (phases at a glance)
- Estimated slice count and any risks flagged in the plan
- Verification checkpoints per phase

### 2. Ask explicitly

Use wording like:

> Plan and tasks are at `{local_specs}/plan-<ticket_key_lower>.md` and `{local_specs}/todo-<ticket_key_lower>.md`.
> **Approve to proceed to committed memory setup and implementation**, or tell me what to change.

### 3. Block until explicit approval

Do **not** proceed until the user gives **explicit confirmation** (e.g. "approve",
"proceed", "start implementing").

| Blocked until plan approved              |     |
| ---------------------------------------- | --- |
| Creating committed task memory / status  | Yes |
| Checking out ticket branch               | Yes |
| Writing or modifying application code    | Yes |
| Running implementation slices            | Yes |

**Do not treat as approval:** silence, implied consent, or agent inference. If the
user requests changes, revise plan/todo and re-prompt.

On approval → proceed to **Phase 6 (Committed memory)** and **Phase 7 (Implement)** in
[SKILL.md](SKILL.md).

______________________________________________________________________

## After plan approval

1. **Committed memory** (when configured) — concise task file + optional status row;
   mirror todo checklist briefly; link to local spec path; do not paste full spec
2. **Branch** — `git checkout -b <ticket-key>` from `git.default_base`
3. **Implement** — execute todo via [incremental-implementation.md](incremental-implementation.md)
4. **Verify each slice** — run checkpoint commands from the plan

______________________________________________________________________

## Anti-patterns

| Mistake                                   | Fix                                      |
| ----------------------------------------- | ---------------------------------------- |
| Planning before spec approval             | Stop; return to [specify.md](specify.md) |
| Committed memory / code before plan approval | Summarize plan; wait for explicit yes |
| Horizontal mega-tasks ("build all tests") | Vertical slices with verify per slice    |
| Tasks too large (> ~5 files)              | Split into smaller todo items            |
| Plan without real verify commands         | Use [verification.md](verification.md)   |
| No isolation plan for new behavioral code | Add gates in plan/todo ([feature-gating.md](feature-gating.md)) |

______________________________________________________________________

## See also

- [SKILL.md](SKILL.md) — Phases 6–9 (memory, implement, verify, draft PR)
- [specify.md](specify.md) — spec phase and spec approval gate
- [engineering-rubric.md](engineering-rubric.md) — code quality bar during implement
- [incremental-implementation.md](incremental-implementation.md) — execution discipline per todo slice
