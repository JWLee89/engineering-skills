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
3. **PR body** — [templates.md](templates.md#verification-plan-pr-body) checkboxes checked with evidence inline

### Proof strength (prefer higher when feasible)

```
Strong:  failing RED → GREEN history + isolation gate + integration/smoke + lint
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
- [ ] Lint / typecheck / hooks (verify.hooks)
- [ ] No local spec files staged
- [ ] Task memory updated
- [ ] CI-only scenarios listed for PR skill
- [ ] Handoff ready for Phase 9: branch pushed; evidence copied into draft PR body next
```

After Phase 8, **`/pull-request`** opens a draft PR, then **`/code-review`** on that PR is
**mandatory** before `gh pr ready` ([SKILL.md](SKILL.md) Phase 9b).

______________________________________________________________________

## Test robustness

- **Constants once** — shapes, keys, profiles at module top; fixtures and asserts use same names
- **Parametrize** variant behavior
- **Wire keys** — derive from `fields(Model)` / shared enums, not duplicated literals

Details: [engineering-rubric.md](engineering-rubric.md).

______________________________________________________________________

## CI-only

Never skip failing tests to green a PR without user approval. Document workflow names in PR
verification with run URLs when available.

Examples: [examples/generic.project.yaml](examples/generic.project.yaml), [examples/jira-project.project.yaml](examples/jira-project.project.yaml).
