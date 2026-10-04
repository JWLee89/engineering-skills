# Code review: PR #10 — feat(skills): catalog layout, benchmark rubric, skills/ migration

**PR:** https://github.com/JWLee89/engineering-skills/pull/10  
**Branch:** `feat/skills-catalog-layout` → `main`  
**Work items:** N/A (local spec; not in tracker)  
**Reviewer persona:** Senior engineer — rigorous, kind (/code-review)  
**Verdict (draft):** Approve with nits (fix Major M1 before or immediately after merge)

## PR intent (checkpoint)

Restructure the repo into a `skills/` catalog (jeffallan-style), strengthen rubrics/workflow docs, and move install to `./scripts/install-skills.sh` without dropping handle-task gates.

## Summary

This PR delivers what the approved benchmark spec aimed for: clear catalog entry points (`SKILLS_GUIDE`, `BENCHMARK`), sensible physical layout, cross-skill links that work when all five skills are symlinked as siblings, and meaningful quality improvements (OWASP baseline, review intent checkpoint, positive feedback). The migration is large but mostly renames plus targeted edits; the PR body is reviewable.

The main gap versus the spec’s “stub release” is that **`handle-task-skill/` no longer contains `SKILL.md` or sub-skill folders**, so anyone with **existing global symlinks** to the old paths gets a broken `/handle-task` until they run `./scripts/install-skills.sh --update`. That should be called out louder or mitigated with stub `SKILL.md` files (see M1).

## Positive feedback

- **Sibling symlink model** (`../review-ticket/`, `../handle-task/` from sub-skills) is the right design for split install targets under `~/.cursor/skills/`.
- **Thin wrappers** for install (`scripts/` + legacy paths) reduce duplicate logic while preserving backward-compatible entrypoints.
- **Benchmark doc** gives traceable adopt/reject decisions — good for future contributors and agents.
- **Orchestrator stays lean** (~118 lines) while depth moves to delegates and `references/`.

## Context used

- PR description + file list (48 files, +878 / −665)
- Local branch read of `skills/*`, `scripts/install-skills.sh`, `handle-task-skill/` stub
- CI: no required checks reported on PR

## Findings

### Blockers

*(none)*

### Major

#### M1. Legacy symlink breakage without stub `SKILL.md` (Axis: Documentation — onboarder test)

**Context:** [Spec success criterion #6](https://github.com/JWLee89/engineering-skills/pull/10) · [handle-task-skill/](https://github.com/JWLee89/engineering-skills/tree/feat/skills-catalog-layout/handle-task-skill) (README + wrapper script only)

**Issue:** After merge, `handle-task-skill/` has no `SKILL.md` and no `pull-request/` etc. Install targets that still point at the old tree (common until `--update`) will not load the orchestrator or sub-skills.

**Evidence:**

```
handle-task-skill/
  README.md
  scripts/install-skills.sh
```

**Suggestion:** Either (a) add minimal stub `SKILL.md` (and optional stub subdirs) that tell agents to load `../skills/handle-task/SKILL.md`, or (b) merge only after a **Migration** section in root README is impossible to miss (banner + breakages list). (a) matches the written spec stub release.

#### M2. Committed task scratchpad missing (Axis: Documentation)

**Context:** PR body · local `docs/tasks/skills-catalog-layout.md` exists on disk but is **not** in the PR file list

**Issue:** Task memory for this initiative was drafted but not committed; reviewers cannot see status from the repo alone.

**Suggestion:** Add `docs/tasks/skills-catalog-layout.md` in a follow-up commit on the PR branch (or accept as optional).

### Minor

#### N1. Misleading markdown link labels (Axis: Code smells)

**Context:** e.g. `skills/review-ticket/SKILL.md`, `skills/pull-request/workflow.md`

**Issue:** Links like `[../project-config.md](../handle-task/project-config.md)` work but display text suggests a non-existent relative path.

**Suggestion:** Use consistent display text: `[project-config.md](../handle-task/project-config.md)`.

#### N2. Benchmark doc date (Axis: Documentation)

**Context:** [docs/BENCHMARK-CLAUDE-SKILLS.md](docs/BENCHMARK-CLAUDE-SKILLS.md) line 4

**Issue:** `Date: 2026-04-10` may be a typo if work was done 2026-10-04.

**Suggestion:** Align date with actual merge window.

#### N3. `related-skills: engineering-rubric` (Axis: Documentation)

**Context:** [skills/code-review/SKILL.md](skills/code-review/SKILL.md) frontmatter

**Issue:** `engineering-rubric` is a delegate doc, not an invokable skill folder; may confuse catalog consumers.

**Suggestion:** Use `handle-task` only or note “delegate: engineering-rubric” in prose.

### Questions

#### Q1. Single PR vs three PR plan

**Context:** PR body “Spec adherence” — all three planned slices in one PR

**Question:** Intentional consolidation for review speed? If yes, consider noting in `docs/tasks/` or BENCHMARK that the phased plan was collapsed.

## Rubric checklist

| # | Axis           | Status | Notes |
|---|----------------|--------|-------|
| 1 | Question       | OK     | Matches benchmark initiative |
| 2 | Bugs           | OK     | No runtime code |
| 3 | Software design| OK     | Catalog + install split is coherent |
| 4 | Tests          | N/A    | Docs/skills repo; manual verify only |
| 5 | Duplicates     | OK     | Install script single SSOT + wrappers |
| 6 | Code smells    | Nit    | Link label consistency |
| 7 | Optimizations  | OK     | — |
| 8 | Documentation  | Major  | Stub SKILL + migration visibility |

## Test traceability

| Requirement (spec) | Evidence in PR | Gap? |
|--------------------|----------------|------|
| `skills/` tree | Yes | No |
| SKILLS_GUIDE + BENCHMARK | Yes | No |
| OWASP + positive feedback | Yes | No |
| Install + stubs | Partial | M1 — stub SKILL missing |
| Frontmatter on five skills | Yes | No |
| ≥10 adopt / ≥5 reject | Yes (BENCHMARK) | No |

## Verification notes

Not re-run in this review session. Author claimed:

- `./scripts/install-skills.sh --list` → sources under `skills/*`
- `wc -l skills/*/SKILL.md`

Recommend reviewer after checkout:

```bash
./scripts/install-skills.sh --update
./scripts/install-skills.sh --list   # link targets should be skills/*, not handle-task-skill
```

## Pre-existing issues noticed

- No automated link-check CI for markdown cross-links (follow-up from prior initiatives).
