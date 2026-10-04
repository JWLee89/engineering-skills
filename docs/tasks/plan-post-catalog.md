# Plan — Post catalog (after PR #10)

**Updated:** 2026-10-04 · **Base:** `main` @ `216ecb1`  
**Supersedes:** `tasks/skills-benchmark/plan-skills-benchmark.md` (local) three-PR schedule — **P1–P3 shipped in one PR.**

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
| `templates.md` (~450 lines) not split into `handle-task/references/` | Lazy-load / jeffallan `references/` | **P0** |
| Sub-skills lack `references/` (only handle-task + pull-request partial) | Each skill folder + `references/` | P1 |
| `code-review` / `review-ticket` / `create-ticket` SKILL.md still long; no “Load when” table | Frontmatter + lazy load | P1 |
| Anti-patterns duplicated across SKILL + workflow | Consolidate to `references/` | P2 |
| Markdown link check in CI | Verification / BENCHMARK follow-up | P2 |
| Remove `handle-task-skill/` stubs after one release | Spec §6 — **decision: keep stubs** (document in README) | P3 doc-only |

## PR #11 — Lazy-load references (recommended next)

**Branch:** `feat/skills-references-lazy-load`  
**Scope:** One reviewable PR; no gate changes.

### Objectives

1. Split [templates.md](../../skills/handle-task/templates.md) into anchored files under `skills/handle-task/references/templates/` (or `references/template-*.md`) — keep stub anchors at old paths or redirect headers in a thin `templates.md`.
2. Add **Load when** tables to `skills/code-review/SKILL.md`, `skills/pull-request/SKILL.md` (pull-request: partial — extend).
3. Add `skills/code-review/references/` with pointers to rubric + link to Jeffallan report shape (no duplicate prose).
4. Document **stub retention policy** in root README (one paragraph).

### Out of scope PR #11

- CI link checker (PR #12)
- Vendoring jeffallan skills
- Changing slash commands or mandatory gates

### Verification

```bash
./scripts/install-skills.sh --list
# Spot-check: specify.md links still resolve to template anchors
wc -l skills/handle-task/templates.md skills/*/SKILL.md
rg 'templates\.md#' skills/handle-task --count
```

### Todo

- [ ] R1 Split spec/plan/PR template sections from `templates.md` → `references/`
- [ ] R2 Thin `templates.md` to index + links only
- [ ] R3 Load-when tables on code-review + review-ticket SKILL.md
- [ ] R4 code-review/references/README or report-pointer.md
- [ ] R5 README stub policy
- [ ] R6 Agentic verify + draft PR (reviewer-friendly body)

## PR #12 — Link hygiene CI (optional)

- Script: verify internal markdown links under `skills/` (relative links only)
- `.github/workflows/` or document manual run if no CI budget

## PR #13 — Anti-pattern dedupe (optional)

- `handle-task/references/anti-patterns.md` SSOT; SKILL links only

## Initiative closure

When PR #11 (+ optional 12–13) merge: mark benchmark initiative **closed** in BENCHMARK doc footer.
