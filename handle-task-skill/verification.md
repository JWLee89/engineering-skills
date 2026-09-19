# Verification

Delegate for `/handle-task` Phase 8. Run **after** [spec-adherence.md](spec-adherence.md) matrix is clean or gaps acknowledged.

## Commands

Load `.handle-task/project.yaml` → `verify.commands`, `verify.by_path`, `verify.hooks`.
If empty, discover from `Makefile`, `pyproject.toml`, `package.json`, CI workflows.

Run the **smallest** set covering touched code; full suite before `/make-pull-request`.

## Phase 8 checklist

```
- [ ] Spec traceability matrix — all in-scope success criteria have evidence ([spec-adherence.md](spec-adherence.md))
- [ ] Scoped tests pass
- [ ] Lint / typecheck / hooks (verify.hooks)
- [ ] No local spec files staged
- [ ] Task memory updated
- [ ] CI-only scenarios listed for PR skill
```

## Test robustness

- **Constants once** — shapes, keys, profiles at module top; fixtures and asserts use same names
- **Parametrize** variant behavior
- **Wire keys** — derive from `fields(Model)` / shared enums, not duplicated literals

Details: [code-review.md](code-review.md).

## CI-only

Never skip failing tests to green a PR without user approval. Document workflow names in PR verification.

Examples: [examples/generic.project.yaml](examples/generic.project.yaml), [examples/jira-project.project.yaml](examples/jira-project.project.yaml).
