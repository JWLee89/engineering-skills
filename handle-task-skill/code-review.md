# Code review

Standalone delegate for `/handle-task` and `/make-pull-request` Phase 6.

**Approve when** the change improves overall code health and meets the spec — not when
it matches your personal style perfectly.

## Five-axis review

### 1. Correctness

- Matches spec / acceptance criteria
- Behavioral changes have tests that **precede or co-evolve** with production code ([test-driven-development.md](test-driven-development.md))
- Spec success criteria mapped to tests — no silent gaps ([spec-adherence.md](spec-adherence.md))
- Edge cases and error paths covered
- Tests assert the right behavior (not implementation details)

### 2. Readability and simplicity

- Names match project conventions
- No unnecessary cleverness; prefer boring code
- **Reuse:** duplicated logic should call existing helpers
- **Tests:** named constants + `@pytest.mark.parametrize` instead of magic numbers and copy-paste cases
- **Wire keys:** derive from `fields(Model)` / `asdict()`, not hand-maintained lists

### 3. Architecture

- Fits existing patterns and module boundaries
- Feature logic stays in owning package — not shared layers
- New abstraction justified by reduced duplication *and* clarity
- Refactors should reduce concepts the reader must track, not relocate them

### 4. Security

- Input validated at boundaries; secrets not in code/logs
- Parameterized queries; safe defaults

### 5. Performance

- See [performance-optimization.md](performance-optimization.md) when hot paths change
- Flag N+1, unbounded work, missing pagination

## Structural remedies

When flagging structure, propose the fix:

- Replace conditional chains with a dispatcher or typed model
- Move feature logic out of shared modules
- Reuse canonical helper instead of near-duplicate
- Extract helper or split oversized file (~1000+ lines)

## Test robustness (recommended for Python / typed models)

Flag as **Required** when tests use brittle literals or duplicated cases:

| Problem                                                             | Remedy                                                          |
| ------------------------------------------------------------------- | --------------------------------------------------------------- |
| Magic numbers in `shape=(h, w)` **and** separate `assert rows == h` | Named constants at module top; same names in fixture and assert |
| Copy-pasted test methods differing only by input                    | `@pytest.mark.parametrize`                                      |
| Wire keys repeated in fixture + assertion + production              | Import from entity module; derive keys from `fields(Model)`     |

### Example (good)

```python
DERIVED_SLICE_SHAPE_SMALL = (10, 20)

@pytest.mark.parametrize(("slice_height", "slice_width"), [DERIVED_SLICE_SHAPE_SMALL])
def test_derives_image_info_from_array(slice_height, slice_width):
    slice_shape = (slice_height, slice_width)
    record = build(..., shape=slice_shape)
    assert record.image_info.rows == slice_height
```

## Red flags

- Production logic added without corresponding tests for new behavior
- Magic numbers duplicated across setup and assertions
- New code when an existing helper could be extended
- Reinvented functionality that already exists elsewhere in the repo
- Abstraction used once or twice without clear payoff
- Drive-by refactors outside PR scope

## Cross-references

- Implementation reuse: [incremental-implementation.md](incremental-implementation.md)
- Spec / test bullets: [specify.md](specify.md), [templates.md](templates.md)
- Verification: [verification.md](verification.md)
