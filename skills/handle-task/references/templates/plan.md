```markdown
# Implementation Plan: {TICKET-KEY}

**Spec:** `{local_specs}/<ticket_key_lower>/SPEC-<slug>.md`
**Tasks:** `{local_specs}/todo-<ticket_key_lower>.md`

## Overview

<One paragraph approach.>

## Verified findings

1. ...

## Architecture decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| ... | ... | ... |

## Implementation order

1. ...
2. ...

## Files changed (expected)

| File | Action |
|------|--------|

## Verification checkpoints

| After | Isolation gate | Integration / full verify |
|-------|----------------|---------------------------|
| Slice 1 | `pytest tests/unit/...::test_...` | — |
| Before PR | Re-run slice isolation gates | `<from verify.commands>` |

## Out of scope

- ...
```
