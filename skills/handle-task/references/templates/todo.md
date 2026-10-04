```markdown
# Tasks: {TICKET-KEY} — <short title>

**Spec:** `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md`
**Plan:** `{local_specs}/plan-<ticket_key_lower>.md`

---

## Phase 0: ...

- [ ] **Task N: <name>**
  - Acceptance: ...
  - Spec: satisfies `<success criterion # or scenario>`
  - TDD: RED in `<test file>` → GREEN in `<production file(s)>`
  - Isolation gate: `<scoped command>` ([feature-gating.md](feature-gating.md))
  - Spec adhere: matrix row ✅ for this slice
  - Verify: `<scoped test command>` (agent runs; record summary + commit SHA)

---

## Plan approval gate

Do not start committed memory setup or implementation until the user explicitly approves this
plan and todo. See [plan-and-tasks.md](plan-and-tasks.md#plan-approval-gate-hard-stop).
```
