# Verification commands

Run the **smallest** set covering touched code. Load **`.handle-task/project.yaml`**
first → `verify.commands`, `verify.by_path`, `verify.hooks`.

If config is empty, discover from the repo:

| Signal    | Look in                        |
| --------- | ------------------------------ |
| Make      | `Makefile`, `make help`        |
| Python    | `pyproject.toml`, `pytest.ini` |
| Node      | `package.json` scripts         |
| CI parity | `.github/workflows/`           |

## Pre-PR checklist

```
- [ ] .handle-task/project.yaml loaded
- [ ] Scoped tests pass
- [ ] Lint / typecheck (when project uses them)
- [ ] Hooks pass (prek, pre-commit, etc.)
- [ ] No local spec files staged
- [ ] Committed task memory updated if configured
```

## CI-only tests

Document in PR test plan with workflow names from `verify.ci_workflows`. Never skip
tests to green a PR without approval.

## Test robustness

When writing or reviewing unit tests:

- **Name dimensions and fixtures once** — define shape/size constants (e.g. `DICOM_IMAGE_ROWS`,
  `DEFAULT_SLICE_SHAPE`) at module top; build metadata dicts and assertions from those names.
  Avoid magic numbers duplicated in `shape=(10, 20)` and `assert rows == 10`.
- **Parameterize behavior that varies on inputs** — use `@pytest.mark.parametrize` for multiple
  shapes, key aliases (`columns` vs `cols`), present/absent metadata, or enum variants instead
  of copy-pasted test methods.
- **Single source for wire keys** — derive expected key sets from `fields(Model)` or shared key
  instances; do not re-list the same string literals in fixtures and assertions.
- **Assert through the same constants** — if a fixture embeds a value, the test should reference
  the constant, not a second literal.

See also [code-review.md](code-review.md) (five-axis review + test robustness).

## Project reference

Example verify blocks: [examples/generic.project.yaml](examples/generic.project.yaml),
[examples/jira-project.project.yaml](examples/jira-project.project.yaml)
