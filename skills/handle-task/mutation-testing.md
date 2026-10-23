# Mutation testing

Delegate for `/handle-task` **Phase 8 Verify** and before **`gh pr ready`** on behavioral
changes. **SSOT** for test *effectiveness* — whether tests would fail when behavior breaks.

**Priority (this workflow):**

1. **Bug detection** — tests catch realistic faults in changed code.
2. **Mutation testing** — when configured, survivors drive test improvements.
3. **Coverage metrics** — line/patch coverage supports (1) but does not replace it.

Further reading:

- [What is mutation testing?](https://circleci.com/blog/what-is-mutation-testing/) (concepts)
- [Stryker Mutator docs](https://stryker-mutator.io/docs/) (tooling patterns; language-agnostic ideas)
- [Mutation testing guide](https://testrigor.com/blog/understanding-mutation-testing-a-comprehensive-guide/)

______________________________________________________________________

## Concepts

| Term | Meaning |
| ---- | ------- |
| **Mutant** | A small, automatic change to production code (e.g. `>` → `>=`, delete a branch, flip a constant). |
| **Killed** | At least one test fails when the mutant is applied — good. |
| **Survived** | All tests still pass — often a **test gap** (or an equivalent mutant). |
| **Mutation score** | Killed ÷ (killed + survived); higher is better within the scoped run. |
| **Equivalent mutant** | Behavior unchanged; document and exclude rather than writing pointless tests. |

Coverage answers “did we **execute** this line?” Mutation answers “would tests **notice** if this line were wrong?”

______________________________________________________________________

## When to run

| Situation | Action |
| --------- | ------ |
| `verify.mutation` configured in `.handle-task/project.yaml` | Run scoped mutation on **changed production modules** in Phase 8; re-run after strengthening tests. |
| User asks for “strong tests” / mutation quality | Read this file; run or propose mutation scoped to the PR diff. |
| Docs / format-only slice | Skip mutation. |
| Full-repo mutation | Only when project config or CI defines it (cost). |

Run **after** scoped unit tests are green ([verification.md](verification.md)). Pair with patch
coverage — a PR can satisfy patch % and still leave **survived mutants** on critical paths.

______________________________________________________________________

## Tooling (discover — do not assume)

Load `verify.mutation.commands` and `verify.mutation.scope` from
[project-config.md](project-config.md). If unset, search the repo (`pyproject.toml`, `Makefile`,
CI) for mutmut, cosmic-ray, mutatest, Stryker, PIT, etc.

| Stack | Common tools |
| ----- | ------------ |
| Python | mutmut, cosmic-ray, mutatest |
| JavaScript / TypeScript | [Stryker](https://stryker-mutator.io/docs/) |
| JVM | PIT |

Use the project’s chosen tool; report results in its native format (survivor list, mutation score).

______________________________________________________________________

## Agent workflow

```
1. Scope  → paths from PR diff or verify.mutation.scope globs
2. Run    → verify.mutation.commands (or discovered equivalent)
3. Triage → list survived mutants; map each to spec / user-visible behavior
4. Fix    → add or strengthen tests (outcomes from acceptance criteria, not internals)
5. Re-run → mutation on same scope until survivors are killed or documented equivalent
6. Record → command, score/summary, commits that addressed survivors (PR Verification section)
```

### Strengthening tests after survivors

- Assert **observable outcomes** (return values, raised errors, wire shapes, side effects at boundaries).
- Prefer **table-driven** rows for the branch the mutant altered ([test-driven-development.md](test-driven-development.md)).
- Do **not** assert private helpers or mirror production line-for-line.
- Do **not** delete production code to “green” mutation without user approval.

### Equivalent mutants

When a survivor is truly equivalent, note **mutant id + one-line rationale** in PR verification or
`memory.decisions` — do not add brittle tests solely to kill it.

______________________________________________________________________

## Evidence (Phase 8 + PR)

| Record | Example |
| ------ | ------- |
| Command | `mutmut run --paths-to-mutate src/foo.py` |
| Summary | “42 killed, 3 survived → 93%” |
| Follow-up | “Survivors at `bar.py:88` — added `test_bar_rejects_empty_batch` in `<sha>`” |
| Gap | “Mutation CI-only; local run skipped — see workflow URL” |

Add **Mutation** row to the evidence bundle in [verification.md](verification.md#agentic-validation-always-required).

______________________________________________________________________

## Anti-patterns

| Mistake | Fix |
| ------- | --- |
| Treating green coverage as “tests are good” | Run mutation on changed modules when configured |
| Killing mutants by weakening assertions | Strengthen outcome checks |
| Full-repo mutation every slice | Scope to diff + config |
| Ignoring survived mutants on critical paths | Add tests or document equivalent |
| Mandating one global tool in skills | Project config + discovery |

After mutation-driven test work → [spec-adherence.md](spec-adherence.md) for the slice.
