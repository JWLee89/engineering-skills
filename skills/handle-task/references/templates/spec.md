```markdown
# Spec: <title> ({TICKET-KEY})

**Issue:** [{TICKET-KEY}](<url from url_template>)
**Parent / epic:** <link or —>
**Branch:** `{TICKET-KEY}` (base: `<git.default_base>`)
**Capability map:** `{local_specs}/<ticket_key_lower>/CAPABILITY-MAP.md` (if applicable)

---

## Assumptions I'm Making

1. ...
2. ...

→ Correct me now or implementation proceeds with these.

---

## Objective

<What and why. User stories or acceptance criteria from the tracker, refined.>

### Success criteria

- [ ] <testable condition>
- [ ] <testable condition>

---

## Current state

<Relevant files, data flow, existing behavior — from codebase reading.>

---

## Tech stack / scope boundary

| In scope | Out of scope |
|----------|--------------|
| ... | ... |

---

## Commands

```bash
# From repo root — use real commands from verify.commands in config
npm test
npm run lint
# or: make test-unit, pytest, etc.
````

______________________________________________________________________

## Project structure (expected changes)

| File            | Action          |
| --------------- | --------------- |
| `src/...`       | Create / modify |

______________________________________________________________________

## Testing strategy

- Unit / isolation: `tests/unit/...` — **feature gate** per slice ([feature-gating.md](../../feature-gating.md))
- Integration: note CI-only deps if any
- Manual / smoke: ...
- Phase 8: agent runs verify commands; evidence in task memory + PR ([verification.md](../../verification.md))

______________________________________________________________________

## Boundaries

- **Always:** Run scoped tests before PR; match existing patterns in adjacent modules
- **Ask first:** New deps, CI changes, schema/API contract edits
- **Never:** Commit local specs; commit secrets; remove failing tests without approval

______________________________________________________________________

## Open questions

| Question | Owner | Status |
| -------- | ----- | ------ |
| ...      | ...   | open   |

______________________________________________________________________

## Risks

| Risk | Mitigation |
| ---- | ---------- |
| ...  | ...        |

```
