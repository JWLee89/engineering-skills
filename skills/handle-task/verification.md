# Verification

Delegate for `/handle-task` Phase 8. Run **after** [spec-adherence.md](spec-adherence.md)
matrix is clean or gaps acknowledged.

**Mandatory:** [agentic validation](#agentic-validation-always-required) — the agent runs
commands and attaches **strong evidence**; never “please run tests locally” as the only proof.

______________________________________________________________________

## Commands

Load `.handle-task/project.yaml` → `verify.commands`, `verify.by_path`, `verify.hooks`.
If empty, discover from `Makefile`, `pyproject.toml`, `package.json`, CI workflows.

Run the **smallest** set covering touched code; full suite before `/pull-request`.

Include [feature-gating.md](feature-gating.md) isolation commands for every applicable slice.

______________________________________________________________________

## Agentic validation (always required)

The agent **must** execute verification itself in the environment (Shell tool or equivalent),
not instruct the user to validate in place of running checks.

### Evidence bundle (Phase 8 + PR handoff)

For each proof, capture **at least one** of:

| Evidence type | What to record |
| ------------- | -------------- |
| **Test run** | Exact command, exit code, final summary line (e.g. `N passed`, `OK`, `SUCCESS`) |
| **Coverage** | Command + relevant line/branch % or “covers `path/to/module.py`” from report |
| **Mutation** | Scoped command + mutation score or survivor count; note tests added for survivors ([mutation-testing.md](mutation-testing.md)) |
| **Smoke / script** | Command + stdout snippet showing success or key assertion |
| **Integration** | Parametrized test node ids or case names that passed |
| **CI** | Workflow name + run URL (after push); link in PR body |

Also record when applicable:

- **Commit SHA(s)** — link in PR body: `[short](https://github.com/{owner}/{repo}/commit/{sha})` from `git rev-parse HEAD`
- **Code pointers** — PR diff `…/pull/{n}/changes#diff-{sha256(path)}R{n}-R{m}` when PR open; else `blob/{sha}/{path}?plain=1#L{n}` for `.md`
- **Short excerpt** — 3–10 lines of terminal output proving pass (not full logs)

Store summaries in:

1. **Committed task memory** — session log / Verify section
2. **Chat** — concise proof table for the user
3. **PR body** — [references/templates/verification-pr-body.md](references/templates/verification-pr-body.md) checkboxes checked with evidence inline

### Proof strength (prefer higher when feasible)

```
Strong:  failing RED → GREEN history + isolation gate + mutation (when configured) on changed modules + integration/smoke + lint
Good:    scoped pytest/npm with summary + spec matrix ✅
Weak:    “looks correct” / typecheck only for behavioral change  → do not stop here
```

If only **CI-only** proof is possible, run what you can locally, document the gap, push,
and attach CI run URL when green ([pull-request/workflow.md](../pull-request/workflow.md)).

### Agentic validation process (checklist)

```
- [ ] Listed every command run (isolation + integration + hooks)
- [ ] Ran each command; recorded exit code and summary line
- [ ] Linked evidence to spec traceability rows ([spec-adherence.md](spec-adherence.md))
- [ ] Noted commit SHAs and test paths for reviewer navigation
- [ ] CI-only items listed with workflow names; watch/fetch run after push
- [ ] No local spec files staged
- [ ] Task memory updated with Verify / session log entries
```

______________________________________________________________________

## Phase 8 checklist

```
- [ ] Spec traceability matrix — all in-scope success criteria have evidence ([spec-adherence.md](spec-adherence.md))
- [ ] Feature isolation gates re-run where applicable ([feature-gating.md](feature-gating.md))
- [ ] Agentic validation bundle complete (commands run + evidence recorded)
- [ ] Scoped tests pass
- [ ] Mutation testing on changed production code when `verify.mutation` is configured ([mutation-testing.md](mutation-testing.md))
- [ ] Lint / typecheck / hooks (verify.hooks)
- [ ] No local spec files staged
- [ ] Task memory updated
- [ ] CI-only scenarios listed for PR skill
- [ ] Handoff ready for Phase 9: branch pushed; evidence copied into draft PR body next
```

After Phase 8, **`/pull-request`** opens a draft PR, then **`/code-review`** on that PR is
**mandatory** before `gh pr ready` ([SKILL.md](SKILL.md) Phase 9b).

______________________________________________________________________

## Boundary moves (refactor slices)

When symbols move between modules (layer consolidation, rename, or split):

```
- [ ] Searched repo for old import paths / package references; updated or removed stale callers
- [ ] Scoped tests cover both validation and assembly paths that share extracted logic
- [ ] Evidence notes import-layer check when the slice is refactor-only (no behavior change)
```

## Dead code (refactor / simplify slices)

Before Phase 8 handoff when the PR removed or replaced abstractions:

```
- [ ] Ripgrep touched public symbols — each has ≥1 non-test caller, or was deleted with its test-only harness
- [ ] PR notes net line reduction when simplification was a goal (optional Δ stat)
```

Details: [incremental-implementation.md](incremental-implementation.md#dead-code-sweep-refactor).

______________________________________________________________________

## Test robustness

**Goal:** tests that **detect bugs**, not only execute lines. Line and patch coverage are
**necessary, not sufficient** — use [mutation-testing.md](mutation-testing.md) when the project
configures it.

- **Constants once** — shared literals at module or fixture scope; tests reuse the same names
- **Table-driven cases** — one test, many inputs; each row must target a distinct branch, error, or realistic scenario ([test-driven-development.md](test-driven-development.md))
- **External keys** — import from schema registry or shared constants, not duplicated literals
- **Real-world shape** — fixtures resemble integrator/client payloads; include partial/invalid mixes when validation is in scope

Details: [engineering-rubric.md](engineering-rubric.md) · [design-tradeoffs.md](design-tradeoffs.md).

## Patch coverage (PR diff)

Many repos report **patch coverage** (lines touched in the PR that tests execute). Treat a
**Codecov (or equivalent) patch report with uncovered lines on the PR diff** as a gate before
`gh pr ready` — not only “project coverage” green. Patch % does **not** prove tests would fail on
logic bugs; pair with mutation testing when configured ([mutation-testing.md](mutation-testing.md)).

```
- [ ] Run the same coverage command CI uses (see verify.commands / Makefile / CI workflow)
- [ ] Open the PR patch report; list each file with missing lines and close gaps or justify deferral
- [ ] Every new/changed production module in the PR has tests that run in the default fast CI job
- [ ] Optional dependencies: stub or mock at the test boundary — do not skip entire modules for core PR paths
- [ ] Cover production failure modes: validation errors, skip paths, missing inputs, per-item loops
- [ ] Critical-path gates (validation before inference, auth, billing, safety checks): cover missing + invalid + blank inputs and skip/wiring behavior
- [ ] Shared helpers extracted during refactor: add focused unit tests on the helper (table-driven branches), not only indirect coverage through one caller
- [ ] Avoid duplicate tests for the same behavior; prefer table-driven cases or one end-to-end chain
- [ ] Prefer one strong test over several shallow copies of the same assertion
```

When tests are **skipped** because an optional dependency is absent, patch coverage for that
production code often stays at 0% in the fast job — use shared test doubles, scoped mocks, or
heavier-environment tests in the job that installs the real dependency.

Record in the PR verification section: patch % or “Codecov patch: N missing lines → addressed in
commit `<sha>`”.

______________________________________________________________________

## CI-only

Never skip failing tests to green a PR without user approval. Document workflow names in PR
verification with run URLs when available.

Examples: [examples/generic.project.yaml](examples/generic.project.yaml), [examples/jira-project.project.yaml](examples/jira-project.project.yaml).
