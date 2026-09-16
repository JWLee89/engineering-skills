# Spec-driven development

Standalone delegate for `/handle-task`. Repo-specific paths and gates live in
[specify.md](specify.md).

## When to use

- New feature or non-trivial change with unclear requirements
- Multi-file or architectural work
- More than ~30 minutes of implementation expected

**Skip:** one-file fixes with obvious requirements.

## Gated workflow

```
SPECIFY → PLAN → TASKS → IMPLEMENT
   ↓         ↓       ↓         ↓
 human    human   human    verify
```

Do not advance without explicit user approval at spec and plan gates
([specify.md](specify.md), [plan-and-tasks.md](plan-and-tasks.md)).

## Phase 0: Scope check (multi-capability only)

Decompose when the ticket bundles **independently testable capabilities**:

- Distinct consumers or acceptance clusters
- One piece could ship without the others

Output: capability map (module ids, dependencies, build order) → **stop for approval**
before module specs. Single-capability tickets skip this phase.

## Phase 1: Specify

1. List assumptions explicitly; ask the user to confirm or correct.
2. Write spec under `memory.local_specs` (never commit) — see [templates.md](templates.md).
3. Include: objective, in/out of scope, acceptance criteria, testing strategy, risks.
4. Record significant choices in `memory.decisions` after approval (see
   [documentation-and-adrs.md](documentation-and-adrs.md)).

## Spec quality bar

| Good                                 | Bad                                           |
| ------------------------------------ | --------------------------------------------- |
| Testable acceptance criteria         | Vague "make it work"                          |
| Explicit out of scope                | Scope creep by omission                       |
| Links to existing code patterns      | Greenfield assumptions without reading repo   |
| Wire-format keys derived from models | Duplicated field-name lists in spec and tests |

## Anti-patterns

- Code before spec approval
- Committing local spec files
- Specs that restate JIRA without codebase verification
