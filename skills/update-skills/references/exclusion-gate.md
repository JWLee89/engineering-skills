# Exclusion gate (do not add)

Run **before** drafting patches. If **any** row applies, do **not** add the proposed content to global skills unless the user explicitly overrides after you explain the risk.

Answer each question **yes/no** with one line of evidence.

| # | Question | If **yes** → action |
| - | -------- | ------------------- |
| 1 | **Does the agent already do this?** (default behavior, system rules, or existing skill phase) | Do not duplicate; link SSOT or skip |
| 2 | **Does the agent already know this?** (common engineering knowledge, obvious tool use) | Omit prose; at most a one-line pointer |
| 3 | **Is it duplicated or verbose?** (same rule in another delegate, padding, restated checklist) | Consolidate: edit SSOT, delete elsewhere |
| 4 | **Will it harm performance?** (bloat, conflicting rules, always-on context, over-constraining heuristics) | Reject or shrink; prefer delegate lazy-load |
| 5 | **Is the request ambiguous or vague?** (missing trigger, skill name, file, or acceptance) | Stop Phase 3 until user clarifies |
| 6 | **Can it introduce security issues?** (secrets in skills, disabling guards, trusting untrusted input in scripts, prompt injection patterns) | Reject or redesign; use project config / secure defaults |

**Output:** `EXCLUSION: pass` or `EXCLUSION: blocked — [criterion # + reason]`.

When blocked, suggest the right home:

- Project-only → `.handle-task/project.yaml`, `.cursor/rules`, `AGENTS.md`
- Single ticket → task memory / PR body
- Reactive fix mid-task → [self-improvement.md](../../handle-task/self-improvement.md)
