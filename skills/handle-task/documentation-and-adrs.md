# Documentation and ADRs

Standalone delegate for `/handle-task` and `/pull-request`. Records **why**, not
just what.

## When to use

- Architectural or public API / interface choices
- Reuse vs new abstraction decisions ([incremental-implementation.md](incremental-implementation.md))
- Public API or wire-format changes
- PR feedback that changes design direction

**Skip:** obvious one-liners; comments that restate the code.

## Match repo convention first

Read `memory.decisions`, `docs/decisions/`, or any path configured in
`.handle-task/project.yaml` before adding entries. Follow existing table/format — do not
introduce a second ADR scheme.

When `memory.decisions` is set in config, append there (typically newest-first).

## What to document

| Document           | Capture                                              |
| ------------------ | ---------------------------------------------------- |
| ADR / decision row | Context, choice, alternatives rejected, consequences |
| Inline comment     | Non-obvious *why* only                               |
| Spec / task memory | Links to decisions; keep scratchpad concise          |
| PR body            | **Review guide**: PR diff `#diff-…R` links (primary), markdown `?plain=1` source links, commits + verification — [pull-request/workflow.md](../pull-request/workflow.md) |

## Implementation design (document when non-obvious)

Optimize for **clean, maintainable, testable, extensible** code — the same bar as
[incremental-implementation.md](incremental-implementation.md) Phase 7.

### DRY — don't reinvent

Before adding code:

1. **Search** for existing helpers, types, modules, and tests
2. **Reuse as-is** when an existing function already does what you need
3. **Extend or parameterize** when it almost fits and both cases stay readable
4. **Add new code only** when reuse fails — record what you searched and why

### SOLID — practical guardrails

Reference: [SOLID principles (DigitalOcean)](https://www.digitalocean.com/community/conceptual-articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design)

| Capture in ADR when it affects maintenance | Example |
| ------------------------------------------ | ------- |
| Why extend vs fork | Added optional parameter to shared module instead of a feature-specific duplicate |
| Boundary choice | Feature logic stays in its module; shared utilities stay generic |
| Abstraction timing | Shared helper extracted after second identical copy, not speculatively |

When the fork matters for long-term maintenance, record briefly:

- What existing code was considered
- Why reuse / extend / abstract / rewrite
- Trade-off (maintenance, test surface, coupling)

This prevents the next agent from re-debating the same fork. Full principles also live in
the user-level `documentation-and-adrs` skill; this file is the handle-task delegate.

## ADR template (when no repo format exists)

```markdown
## [Date] — [Short title]

**Context:** …
**Decision:** …
**Alternatives:** … (why rejected)
**Consequences:** …
```

## Schema and external formats

- One canonical registry for external field names (and optional metadata: required, deprecated, group)
- Internal names may differ — use explicit mapping tables only when intentional
- **Derive introspection** from the registry (required-field lists, OpenAPI fragments, contract tests) when that stays in sync without hiding behavior
- **Validation logic** may stay explicit per group when rules differ — see [design-tradeoffs.md](design-tradeoffs.md#schema-registry-vs-validation-rules)

Registry field values are usually **external key strings**, not default payload values for missing data.

## Anti-patterns

- Comments that narrate obvious code
- Duplicated field lists in model, serializer, and tests
- Type-tag dispatch that still branches per field — prefer explicit validators or justify the abstraction ([design-tradeoffs.md](design-tradeoffs.md))
- Generic callback readers when a named resolver or inline read is clearer at the call site
- Retroactive task files for completed work
- Committing local `tasks/` specs
- New modules when extending existing code would suffice
- Duplicate logic without documenting why reuse was rejected
