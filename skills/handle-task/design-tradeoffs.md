# Design tradeoffs

Delegate for `/handle-task` Phase 7 (implement / refactor) and **`/code-review`**. Use when
choosing abstractions, schema layout, or test shape. SSOT for **when to add a concept** and
**common tensions** — keep [engineering-rubric.md](engineering-rubric.md) as the quality bar;
this file is the decision guide.

## When to introduce a new concept

No fixed field counts or mandatory patterns. Judge by **maintainability, readability, and
reasoning cost** for the next reader.

| Introduce (name it, document why) | Skip (inline or simplify) |
| --------------------------------- | ------------------------- |
| Same rule applied in many places with **identical** semantics and errors | One or few call sites; rules differ by field (nested data, aliases, custom messages) |
| Abstraction **removes** duplicated branches readers must keep in sync | Abstraction **adds** indirection (callbacks, type tags) but still branches per item |
| Shared type/registry is the **only** place a constant or key list should live | Second registry mirroring the first without a clear consumer |
| Benefits clearly outweigh extra names/files — record in ADR, PR, or `memory.decisions` | “Framework” for a single validation path or one-off adapter |

When you add a non-obvious concept, state **benefits** briefly (what got easier: tests, docs,
onboarding, fewer drift points) and **cost** (what readers must learn). If cost wins, do not
ship the abstraction.

## Schema registry vs validation rules

Applies to external payloads (JSON, config, messages, forms) — any **named field contract**.

| Layer | Purpose |
| ----- | ------- |
| **Field registry** | Canonical external names; optional metadata (required, deprecated, group) |
| **Introspection** | Docs, codegen, contract tests — derive lists from the registry |
| **Validation / parse** | Business rules, coercion, errors — often **explicit steps** per group |

Loop the registry for **introspection and contract tests**, not for all validation, when rules
are not uniform (nesting, legacy aliases, enums, different error text).

Details: [documentation-and-adrs.md](documentation-and-adrs.md#schema-and-external-formats).

## Legacy and compatibility

Keep **legacy read paths** (alias keys, old formats) when production ingest or clients still
send them. Implement via **one named resolver** shared by validation and mapping. Remove only
after an explicit contract or migration — note in tracker + ADR.

Cross-package or cross-service fields: search upstream consumers before deleting optional
fields; coordinate releases when the contract is shared.

## Production vs milestone wording

| Surface | Guidance |
| ------- | -------- |
| **Tracker description** | May reference milestones, RC, or phased rollout for **planning** |
| **Code, config, public APIs, stable errors** | Implement the **shipping** shape — no temporary `RC1` flags, env toggles, or placeholder types whose only job is to satisfy a milestone gate |
| **PR titles / user docs** | Prefer production naming; do not encode internal milestone labels unless the product is explicitly pre-release |

**Rule:** Do not code to “pass RC”; code to **ship**. Defer scope via ticket split, not
dual implementations in production.

## Test design vs production design

| Tests | Production |
| ----- | ---------- |
| Table-driven / parameterized suites encouraged | Explicit control flow often clearer when rules diverge |
| Must include **realistic** and **stress/edge** inputs (see [test-driven-development.md](test-driven-development.md)) | Minimal indirection; named helpers at boundaries |
| Same SSOT constants as production for wire/schema keys | One resolver for alias + canonical reads |

Parameterized cases that only vary `1` vs `2` or `"a"` vs `"b"` without domain meaning are
**insufficient** for non-trivial logic.

## Common tensions (quick reference)

| Tension | Prefer |
| ------- | ------ |
| DRY vs readable `parse()` / handler | DRY shared **value** helpers; explicit **record** steps when branches differ |
| “Generate all consumers from one list” | Generate **lists and contract tests**; hand-write behavior where rules differ |
| Clever dispatch vs boring code | Boring code until dispatch is clearly simpler for readers **and** tests |
| Small PR vs correct boundary | Correct module boundary; split PRs by behavior if size hurts review |
| Delete legacy vs break clients | Keep legacy reads until migration ticket; delete dead code in the same change when safe |
| Spec mentions phased delivery | Local spec lists in-scope vs deferred; production code matches in-scope **shipping** behavior |
| User design review asks to simplify | Simplify first; update skills only if the mistake is recurring ([self-improvement.md](self-improvement.md)) |
| “Might need later” vs delete now | Delete when no production caller; defer re-add via ticket if product asks |
| More lines vs fewer lines (same spec) | Fewer — explicit code paths over unused introspection helpers |
| Integrator pins vs component-owned deps | **Component owns** versions and membership; integrator references a **stable contract** (profile, bundle ID, manifest name) |
| Broad install profile vs minimal production | Coarse profile acceptable **interim** with a tracked TODO; prefer component-defined **production** profile when available |
| New optional slice on integrator side | Avoid integrator-only dependency lists that assume **latest** component shape — verify **oldest supported** release still works |

## Integrator vs component dependencies

Your code is an **integrator** when it deploys, installs, or wires **another component** that other teams also use and that will **change its own dependencies over time** (new libraries, split modules, env-specific add-ons).

| Approach | When to use | Cost |
| -------- | ----------- | ---- |
| **Component-defined production profile** (named bundle, preset, optional feature set the component publishes) | Default for integrators in production | One stable reference; component owns pins and churn |
| **Coarse “install everything” profile** on the component | Interim until a lean production profile exists | Extra weight (dev/test deps in prod paths) — document TODO |
| **Integrator-maintained list** mirroring component deps | Component has no profiles yet | Drifts when component adds or renames dependency groups |
| **Duplicated version pins in integrator production code** | **Never** when deps are owned by the component | Brittle; breaks when component bumps; multiple integrators diverge |

**Rule:** In production integrator paths, **do not copy** another component’s dependency versions or lockfile fragments. Reference what the **component publishes** (profile name, manifest, installer flag, extension point). If you must take a temporary shortcut, leave a **TODO** tied to adopting the component’s production profile — do not treat the duplicate pins as the long-term design.

**Why:** Other integrators will rely on different slices of the same component tomorrow. Hard-coding dependencies in your repo fights that shared evolution; component-owned contracts stay robust when dependency graphs change.

## Anti-patterns

- Type-tag or callback-driven validation that obscures which field is read
- Registry metadata duplicated on unrelated domain types
- Milestone-only branches in production (`if rc1: …`) instead of feature flags with clear lifecycle or ticket deferral
- Parameterized tests that restate the happy path with cosmetic input changes
- Removing legacy aliases without ingest/client evidence
- Shipping production helpers consumed **only** by unit tests (registry introspection with no integrator/runtime use)
- Leaving superseded abstractions in place after switching to explicit logic “for documentation”
- Copying another component’s dependency pins into integrator production code (install scripts, Dockerfiles, Helm values, bootstrap jobs)
- Adding integrator-side dependency lists that only match the **latest** component release without checking **oldest supported** in your environment
