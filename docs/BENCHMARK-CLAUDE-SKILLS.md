# Benchmark: Jeffallan claude-skills vs engineering-skills

**Source:** [Jeffallan/claude-skills `skills/`](https://github.com/Jeffallan/claude-skills/tree/main/skills) (MIT)  
**Date:** 2026-04-10 · **Initiative:** skills catalog restructure

This document records what we adopted, rejected, and kept when aligning our bundle with a
industry-familiar skills catalog layout.

## Summary

| Dimension | Jeffallan | engineering-skills (after restructure) |
| --------- | --------- | -------------------------------------- |
| Layout | `skills/{name}/SKILL.md` + `references/` | Same at repo root |
| Install | Plugin marketplace | Symlink script → `~/.cursor/skills/` + `~/.claude/skills/` |
| Orchestration | Multi-skill recipes in SKILLS_GUIDE | Nine-step handle-task + mandatory gates |
| Review | code-reviewer skill (OWASP, praise) | engineering-rubric + `/code-review` rubric |
| Specs | feature-forge (EARS) | Default templates + optional EARS reference |

## Adopted patterns (≥10)

| # | Pattern | Where applied |
| - | ------- | ------------- |
| 1 | `skills/{name}/SKILL.md` + `references/` | Repo root `skills/` tree |
| 2 | Catalog doc with categories and recipes | [SKILLS_GUIDE.md](../SKILLS_GUIDE.md) |
| 3 | Rich skill frontmatter (`domain`, triggers, `related-skills`) | All five invokable skills |
| 4 | “Load when” / lazy-load table in orchestrator | `skills/handle-task/SKILL.md` |
| 5 | Multi-skill workflow recipes | SKILLS_GUIDE “Recipes” section |
| 6 | PR intent checkpoint before rubric | [code-review/workflow.md](../skills/code-review/workflow.md) |
| 7 | OWASP Top 10 baseline checklist (link depth, not duplicate skill) | [engineering-rubric.md](../skills/handle-task/engineering-rubric.md) |
| 8 | Required positive feedback in review + author self-review | engineering-rubric, code-review draft template |
| 9 | Report sections: Summary, Critical/Major/Minor, Positive, Questions, Verdict | code-review workflow template |
| 10 | EARS syntax as optional spec track | `skills/handle-task/references/ears-syntax.md` |
| 11 | MUST DO / MUST NOT consolidated in skill bodies | handle-task anti-patterns + gate table |
| 12 | Version metadata in frontmatter | `version: "1.0.0"` on invokable skills |
| 13 | `references/` templates (report, checklist) split from SKILL | `pull-request/references/reviewer-friendly-pr-body.md`, `pr-body-template.md` (author); `/code-review` draft (reviewer) |
| 14 | Review workflow: Context → intent checkpoint → structured output | PR body Background/Purpose/Focus areas; code-review intent + report sections |

## Rejected or deferred (≥5)

| # | Pattern | Rationale |
| - | ------- | --------- |
| 1 | 67 framework-specific skills (React, Django, …) | Out of scope; install domain skills separately |
| 2 | Plugin marketplace as only install path | We keep symlink install + `.handle-task/project.yaml` |
| 3 | Jira/Confluence slash workflows as defaults | Tracker-agnostic adapters; optional MCP only |
| 4 | `AskUserQuestions` tool naming | Cursor uses explicit user approval gates in prose |
| 5 | Monolithic “full stack plugin” bundle | Modular `/handle-task`, `/pull-request`, etc. |
| 6 | Vendoring jeffallan repo as submodule | Cite patterns; no wholesale copy |
| 7 | Astro docs site for skills | README + SKILLS_GUIDE sufficient for now |

## Kept differentiators

- **`.handle-task/project.yaml`** per application repo (memory paths, verify commands, tracker type)
- **Mandatory gates:** review-ticket → spec → plan → agentic verify → draft PR → `/code-review` → ready
- **Spec adherence matrix** and local specs never committed
- **Issue tracker adapter matrix** (generic prose; `jira` \| `linear` \| `github` \| `none`)
- **Deep eight-axis reviewer rubric** separate from author engineering rubric

## Reference skills (jeffallan)

| Skill | Relevance |
| ----- | --------- |
| [code-reviewer](https://github.com/Jeffallan/claude-skills/tree/main/skills/code-reviewer) | Intent recap, OWASP, structured severity + praise |
| [feature-forge](https://github.com/Jeffallan/claude-skills/tree/main/skills/feature-forge) | EARS requirements, acceptance criteria |
| [SKILLS_GUIDE](https://github.com/Jeffallan/claude-skills/blob/main/SKILLS_GUIDE.md) | Catalog + recipe structure |

## Verification

After migration:

```bash
./scripts/install-skills.sh --list
wc -l skills/*/SKILL.md
```

## Initiative status

**Closed** (2026-10-04): Catalog layout and rubric ([PR #10](https://github.com/JWLee89/engineering-skills/pull/10)),
lazy-load `references/` ([PR #11](https://github.com/JWLee89/engineering-skills/pull/11)),
markdown link CI ([PR #12](https://github.com/JWLee89/engineering-skills/pull/12)),
orchestrator anti-patterns SSOT ([PR #13](https://github.com/JWLee89/engineering-skills/pull/13)).
Follow-ups (sub-skill `references/`, delegate dedupe) remain optional in [plan-post-catalog.md](tasks/plan-post-catalog.md).

## License note

Jeffallan/claude-skills is MIT. We document influenced patterns here; we do not copy proprietary
or third-party prose verbatim into our skills.
