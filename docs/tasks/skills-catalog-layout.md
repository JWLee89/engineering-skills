# Task: skills catalog restructure

**Status:** **Complete** — merged [PR #10](https://github.com/JWLee89/engineering-skills/pull/10) (`216ecb1`).

**Local spec:** `tasks/skills-benchmark/SPEC-skills-benchmark-restructure.md` (gitignored)

## Delivered in PR #10 (原 P1–P3 合併)

- [x] `skills/*` catalog, `SKILLS_GUIDE`, `docs/BENCHMARK-CLAUDE-SKILLS.md`
- [x] OWASP + positive feedback; code-review intent + PR-body map
- [x] `scripts/install-skills.sh`; `handle-task-skill/**` stubs
- [x] Frontmatter on five invokable skills; catalog-first README
- [x] PR author UX: `pull-request/references/*`, Jeffallan-aligned `.github` template
- [x] `docs/tasks/skills-catalog-layout.md`; legacy stub SKILL.md (M1)

## Spec gaps deferred to follow-up

See **[plan-post-catalog.md](plan-post-catalog.md)** (PR #11+).

## Post-merge (operators)

```bash
git checkout main && git pull
./scripts/install-skills.sh --update
```

Reload Cursor after `SKILL.md` changes.
