---
name: update-skills
version: "1.0.0"
domain: meta
role: maintainer
scope: engineering-skills
triggers:
  - /update-skills
  - update skill
  - add skill
  - improve skill
  - skillbase
related-skills:
  - handle-task
  - pull-request
  - code-review
description: >-
  Add or modify skills in the engineering-skills catalog (or a linked clone) using
  exclusion and inclusion rubrics, Anthropic skill best practices, and agent-first
  writing. Analyzes PR review comments for skill gaps, requires user approval of
  intent before editing, and keeps SSOT delegates thin. Use when the user asks to
  create, update, trim, or fix agent skills, skillbase maintenance, or turn PR
  feedback into durable skill guidance.
disable-model-invocation: true
---

# Update skills

**Invoke:** `/update-skills` · **Entry:** [workflow.md](workflow.md) · **Rubrics:** [references/exclusion-gate.md](references/exclusion-gate.md) · [references/inclusion-rubric.md](references/inclusion-rubric.md)

Canonical tree: `skills/{name}/` in the **engineering-skills** repo. Global install:
`./scripts/install-skills.sh` (symlinks `~/.cursor/skills/` and `~/.claude/skills/`).

```
SCOPE → SURVEY → EXCLUSION GATE → INTENT (user approves) → PATCH → CATALOG → VERIFY
```

**Hard rules**

1. **No edit until intent approved** — after exclusion/inclusion analysis, present a short change proposal; wait for explicit user approval (or corrected intent) before modifying files.
2. **One SSOT per rule** — patch the smallest delegate; replace duplication elsewhere with links ([handle-task self-improvement](../handle-task/self-improvement.md) for reactive mid-task patches only).
3. **Lazy read** — load only the skill folder(s) you will touch plus catalog entry points ([SKILLS_GUIDE.md](../../SKILLS_GUIDE.md), [README.md](../../README.md)).

## Load when

| Phase | Read | Defer |
| ----- | ---- | ----- |
| Start | This file, [workflow.md](workflow.md) Phase 0–2 | Rubrics until gate |
| Gate | [exclusion-gate.md](references/exclusion-gate.md), [inclusion-rubric.md](references/inclusion-rubric.md) | Full bundle |
| New skill layout | Repo peer `skills/*/SKILL.md` frontmatter; optional Cursor [create-skill](https://cursor.com/docs/agent/skills) for personal-only skills | Entire create-skill doc |
| PR feedback | [workflow.md](workflow.md) Phase 1b, `/pull-request` comment triage | Full code-review rubric |
| Persist | [workflow.md](workflow.md) Phase 5–6 | handle-task ticket flow unless user asks |

## Companions

| Skill / doc | When |
| ----------- | ---- |
| [self-improvement.md](../handle-task/self-improvement.md) | Same-session fix after a process failure — not a substitute for this workflow |
| `/pull-request` | Open skill PR, link check CI, ready gate |
| `/code-review` | Review skill changes before merge when user wants deep review |

## External references (do not paste wholesale)

- [Anthropic — Skill best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Writing for Agents](https://www.aihero.dev/skills-writing-for-agents) — delete padding; imperative, scannable instructions
