# Feature gating (isolation proof)

Delegate for `/handle-task` **Plan**, **Phase 7 (Implement)**, and **Phase 8 (Verify)**.

**Purpose:** before wiring a change into the full stack (DAG, service, UI, CI matrix),
prove the **new behavior works in isolation** — so failures localize to the slice, not
the whole system.

**When applicable:** behavioral slices (new logic, tasks, protocols, scripts, CI behavior).
**Skip** when the slice is docs-only, comment-only, or a one-line config tweak with no
new behavior to isolate.

**When NOT applicable:** the change is inherently integration-only (e.g. wiring two
already-proven modules). Still run scoped integration tests; document why isolation gate
was skipped.

______________________________________________________________________

## What “isolation” means

| Layer | Isolation proof (examples) |
| ----- | -------------------------- |
| **Unit** | Module/task tested with mocks or minimal fixtures — no full engine run |
| **Component** | Single task or lib entrypoint with real inputs, rest stubbed |
| **Smoke / script** | Repo smoke script or one-case CLI with fixture inputs |
| **Feature flag / config gate** | Behavior behind flag or YAML slice; validate flag-on path before default-on |
| **CI slice** | Targeted workflow or job that exercises only the changed path |

Pick the **smallest** proof that still exercises the spec acceptance criteria for the
slice. Escalate to integration only after isolation gate passes.

______________________________________________________________________

## Plan phase (required when applicable)

In [plan-and-tasks.md](plan-and-tasks.md) artifacts, each behavioral todo item must include:

- **Isolation gate:** command or test target that proves the slice alone
- **Integration gate:** broader command (optional for that slice; required before PR)

Template row in plan **Verification checkpoints**:

| After | Isolation (gate) | Integration (if any) |
| ----- | ---------------- | -------------------- |
| Slice N | `pytest tests/unit/...::test_foo` | — |
| Before PR | — | `pytest tests/integration/...` |

______________________________________________________________________

## Implement phase (per slice)

Insert **FEATURE GATE** after GREEN and before or alongside full scoped verify:

```
REUSE CHECK → RED → GREEN → REFACTOR → FEATURE GATE → SPEC ADHERE → Verify → (commit)
```

### FEATURE GATE checklist

```
- [ ] Isolation command from todo/plan executed by the agent (not delegated to user)
- [ ] Exit code 0; summary captured (see [verification.md](verification.md#agentic-validation))
- [ ] Failure would implicate this slice’s files/tests, not unrelated subsystems
- [ ] If gate skipped: reason recorded (inherent integration-only) + integration proof planned
```

Do **not** merge slice wiring into production paths until the isolation gate passes,
unless the spec explicitly orders integration-first (record that in task memory).

______________________________________________________________________

## Phase 8

Re-run isolation proofs for **every in-scope behavioral slice** that had a gate, plus full
[verification.md](verification.md) agentic evidence bundle before `/pull-request`.

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Only full e2e, no unit/smoke for new logic | Add isolation gate in plan + todo |
| “Works when I read the code” | Run gate; capture output |
| Wire entire DAG before task tests exist | Vertical slice: task tests → DAG wiring |
| Skip gate because CI will catch it | Author isolation proof + CI (Phase 8) |

## See also

- [incremental-implementation.md](incremental-implementation.md) — slice cycle
- [verification.md](verification.md) — agentic validation and evidence
- [spec-adherence.md](spec-adherence.md) — map gates to spec success criteria
