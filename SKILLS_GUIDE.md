# Skills guide — engineering-skills catalog

Quick reference for agents and humans. **Install:** [README.md](README.md) · **Agent entry:** [skills/handle-task/QUICKSTART.md](skills/handle-task/QUICKSTART.md)

---

## Invokable skills (this repo)

| Skill | Invoke | Folder | Purpose |
| ----- | ------ | ------ | ------- |
| Handle task | `/handle-task` | [skills/handle-task/](skills/handle-task/) | Ticket → spec → plan → implement → verify → PR |
| Pull request | `/pull-request` | [skills/pull-request/](skills/pull-request/) | Draft PR, CI, conflicts, ready gate |
| Review ticket | `/review-ticket` | [skills/review-ticket/](skills/review-ticket/) | Four-point ticket quality gate |
| Create ticket | `/create-ticket` | [skills/create-ticket/](skills/create-ticket/) | Draft + create tracker issues |
| Code review | `/code-review` | [skills/code-review/](skills/code-review/) | Deep PR rubric; draft before post |

**Config (every target repo):** `.handle-task/project.yaml` — see [project-config.md](skills/handle-task/project-config.md).

---

## Decision tree

```
Need to ship a tracker issue?
  └─ Yes → /handle-task (full gates)
       └─ No ticket yet? → /create-ticket → /review-ticket → /handle-task

Only opening or fixing a PR?
  └─ /pull-request

Ticket text weak or oversized?
  └─ /review-ticket (backfill, split)

PR exists and needs deep review?
  └─ /code-review (mandatory handle-task Phase 9b before gh pr ready)

Trivial one-file fix, no tracker?
  └─ Skip full handle-task; optional light self-review
```

---

## Recipe: Nine-step ship (default)

Quality first — read only docs for the **current phase** ([lazy load](skills/handle-task/SKILL.md#lazy-load-do-not-read-the-whole-bundle)).

| Step | Action | Skill / doc |
| ---- | ------ | ----------- |
| 1 (opt) | Create ticket | `/create-ticket` → `/review-ticket` |
| 2 | Analyze ticket | `/review-ticket` or `/handle-task` Phase 1 |
| 3 | Spec | [specify.md](skills/handle-task/specify.md) — **user approves local spec** |
| 4 | Plan | [plan-and-tasks.md](skills/handle-task/plan-and-tasks.md) — **user approves plan** |
| 5 | Split if too large | [pr-splitting.md](skills/handle-task/pr-splitting.md) |
| 6 | Implement | [engineering-rubric.md](skills/handle-task/engineering-rubric.md) |
| 7 | Verify | [verification.md](skills/handle-task/verification.md) — agent runs commands |
| 8 | Draft PR | `/pull-request` Phases 1–4 |
| 9 | Review loop | `/code-review` → fix blockers → `/pull-request` ready |

---

## Recipe: PR-only follow-up

1. `/pull-request` — refresh body, Δ, verification checkboxes  
2. If review comments exist — triage; push back when wrong  
3. `/code-review` again after substantive fixes (fresh session)  
4. CI green → author rubric pass → `gh pr ready`

---

## Recipe: Formal requirements (optional)

When the user asks for **EARS** or strict FR numbering:

1. Still run spec approval gate ([specify.md](skills/handle-task/specify.md))  
2. Use [references/ears-syntax.md](skills/handle-task/references/ears-syntax.md) for requirement lines  
3. Map each EARS line to tests in [spec-adherence.md](skills/handle-task/spec-adherence.md)

Default spec templates remain in [templates.md](skills/handle-task/templates.md) — EARS is not a mandatory gate.

---

## Recipe: Optional global skills (Cursor / Claude)

Use **either** this bundle **or** overlapping globals for the same phase — not both.

| Phase | Global alternative (examples) |
| ----- | ------------------------------ |
| Spec | `spec-driven-development` |
| Plan | `planning-and-task-breakdown` |
| Implement quality | `code-review-and-quality` (author axis only) |
| Security depth | `security-and-hardening` |
| Debug CI | `debugging-and-error-recovery` |

Domain framework skills (React, Django, etc.) — install separately; see [BENCHMARK](docs/BENCHMARK-CLAUDE-SKILLS.md).

---

## Single sources of truth

| Topic | File |
| ----- | ---- |
| Ticket quality | [quality-gate.md](skills/review-ticket/quality-gate.md) |
| Author implement + self-review | [engineering-rubric.md](skills/handle-task/engineering-rubric.md) |
| Reviewer deep review | [code-review/rubric.md](skills/code-review/rubric.md) |
| PR template sections | [templates.md](skills/handle-task/templates.md) |
| Reviewer-friendly PR body | [reviewer-friendly-pr-body.md](skills/pull-request/references/reviewer-friendly-pr-body.md) · [PR #8 example](https://github.com/JWLee89/engineering-skills/pull/8) |

---

**Install:** `./scripts/install-skills.sh` → `skills/*` only. Re-run `--update` after pulling if skills fail to load.
