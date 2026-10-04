# Plan — Post catalog (after PR #10)

**Updated:** 2026-10-04 · **Base:** `main` @ post–PR #12 (`6ae0e2b`)  
**Supersedes:** `tasks/skills-benchmark/plan-skills-benchmark.md` (local) three-PR schedule — **P1–P3 shipped in PR #10.**

## What PR #10 completed vs original plan

| Original | Outcome |
| -------- | ------- |
| PR 1 — benchmark + rubric, no moves | Done (plus moves) |
| PR 2 — `skills/` migration + install | Done |
| PR 3 — frontmatter + README polish | Done |
| Extra | PR body references, Jeffallan template alignment, task docs |

## Remaining (from spec success criteria & benchmark)

| Gap | Spec ref | Priority |
| --- | -------- | -------- |
| ~~`templates.md` split into `handle-task/references/`~~ | Lazy-load / jeffallan `references/` | Done (PR #11) |
| Sub-skills lack `references/` (only handle-task + pull-request partial) | Each skill folder + `references/` | P1 (optional) |
| `code-review` / `review-ticket` / `create-ticket` SKILL.md still long; no “Load when” table | Frontmatter + lazy load | P1 (optional) |
| ~~Anti-patterns duplicated in handle-task SKILL~~ | Consolidate to `references/` | Done (PR #13) |
| ~~Markdown link check in CI~~ | Verification / BENCHMARK follow-up | Done (PR #12) |
| ~~`handle-task-skill/` stubs~~ | **Removed** — README migration note + `./scripts/install-skills.sh --update` | Done |

## PR #11 — Lazy-load references (merged)

**Branch:** `feat/skills-references-lazy-load` · **PR:** [#11](https://github.com/JWLee89/engineering-skills/pull/11)  
**Scope:** One reviewable PR; no gate changes.

### Todo

- [x] R1–R6 (templates split, Load-when, review-guide, stub removal, PR)

## PR #12 — Link hygiene CI (merged)

**Branch:** `feat/markdown-link-ci` · **PR:** [#12](https://github.com/JWLee89/engineering-skills/pull/12) · **Spec:** [SPEC-pr12-link-ci.md](SPEC-pr12-link-ci.md)

- [x] L1–L3 script, workflow, merge

### Verify

```bash
python3 scripts/check-markdown-links.py
./scripts/install-skills.sh --list
```

## PR #13 — Anti-pattern dedupe (in progress)

**Branch:** `feat/anti-patterns-ssot` · **Spec:** [SPEC-pr13-anti-patterns.md](SPEC-pr13-anti-patterns.md)

- [x] A1 `references/anti-patterns.md` — orchestrator table from SKILL.md
- [x] A2 SKILL.md link-only anti-patterns section
- [x] A3 BENCHMARK initiative closed footer
- [ ] A4 Draft PR + `/code-review` + merge

### Verify

```bash
python3 scripts/check-markdown-links.py
./scripts/install-skills.sh --list
wc -l skills/handle-task/SKILL.md
```

## Initiative closure

When PR #13 merges: benchmark initiative **closed** in [BENCHMARK-CLAUDE-SKILLS.md](../BENCHMARK-CLAUDE-SKILLS.md) (footer added in PR #13 branch).
