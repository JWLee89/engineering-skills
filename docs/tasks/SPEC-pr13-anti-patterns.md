# SPEC — PR #13: Orchestrator anti-patterns SSOT

**Base:** `main` @ post–PR #12 (`6ae0e2b`) · **Branch:** `feat/anti-patterns-ssot`  
**Parent:** [plan-post-catalog.md](plan-post-catalog.md)

## Objective

Move **handle-task orchestrator** anti-patterns out of `SKILL.md` into
`references/anti-patterns.md` so the entry skill stays thin; phase-specific anti-pattern
tables remain in delegate files (`specify.md`, `plan-and-tasks.md`, etc.).

## Success criteria

1. `skills/handle-task/references/anti-patterns.md` contains the former `SKILL.md` table (links intact).
2. `skills/handle-task/SKILL.md` **links only** to that file (no duplicate table).
3. Optional: delegate table or lazy-load row points agents to anti-patterns when needed.
4. [plan-post-catalog.md](plan-post-catalog.md) marks PR #12 merged and PR #13 progress.
5. [BENCHMARK-CLAUDE-SKILLS.md](../BENCHMARK-CLAUDE-SKILLS.md) footer marks catalog initiative **closed**.
6. `python3 scripts/check-markdown-links.py` exit 0.

## Boundaries

| Always | Never |
| ------ | ----- |
| Orchestrator table only in PR #13 | Dedupe every delegate anti-pattern section |
| Preserve gate semantics and link targets | Change mandatory gates or slash commands |

## Out of scope

- pull-request / code-review / create-ticket anti-pattern tables
- Sub-skill `references/` expansion (remaining P1 gap in plan)

## Verify

```bash
python3 scripts/check-markdown-links.py
./scripts/install-skills.sh --list
wc -l skills/handle-task/SKILL.md
```
