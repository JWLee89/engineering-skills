# Inclusion rubric (add or change)

Apply **after** [exclusion-gate.md](exclusion-gate.md) passes. Every patch should satisfy **at least one** row; state which in the intent proposal.

| # | Criterion | Patch pattern |
| - | --------- | ------------- |
| 1 | **Improves task performance** | New gate, checklist, lazy-load map, or delegate that prevents a repeated failure mode |
| 2 | **PR review feedback** | Thread → root cause → minimal SSOT edit; cite PR link in commit/PR body, not in skill prose |
| 3 | **Fix incorrect or sub-optimal guidance** | Replace wrong steps; add “supersedes” note in PR; remove obsolete sections |
| 4 | **[Anthropic skill best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)** | Concise `SKILL.md`, strong third-person `description`, progressive disclosure, tested triggers |
| 5 | **[Writing for Agents](https://www.aihero.dev/skills-writing-for-agents)** | Delete filler; imperative steps; scannable headings; one level of reference depth |

## Quality bar (all patches)

- **Actionable** — agent can follow without guessing
- **SSOT** — one canonical file per rule
- **Shorter ≥ longer** — default edit is deletion or link replacement
- **Professional defaults** — align with [engineering-rubric.md](../../handle-task/engineering-rubric.md) spirit, not duplicate its checklists

## Description field (discovery)

Third person; include **what** + **when** + invoke terms (`/update-skills`, “add skill”, “skillbase”). Max 1024 chars.
