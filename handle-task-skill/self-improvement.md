# Self-improvement loop

Standalone delegate for `/handle-task` and `/make-pull-request`. Keeps the skill bundle
**accurate, concise, and effective** over time.

## When to run

| Trigger | Example |
| ------- | ------- |
| **Spec adherence gap** caused by missing skill guidance | Forgot to audit mixed-push scenario |
| **User points out a flaw** | "You skipped TDD" / "Tests don't match spec" |
| **User requests improvement** | "Add spec verification to implement phase" |
| **Repeated mistake** across sessions | Same anti-pattern in task logs |
| **Post-mortem after bad PR** | CI scenario never tested though spec required it |

**Do not** expand skills for one-off project quirks — those belong in `memory.decisions` or
project rules, not the global bundle.

## Loop

```
DETECT → DIAGNOSE → PATCH SKILL → NOTIFY USER → (optional) PR to engineering-skills
```

### 1. Detect

- Spec adherence audit found a **process** gap (not just a code bug)
- User explicitly criticizes workflow or asks for skill change
- Agent violated a documented rule in [SKILL.md](SKILL.md) or delegates

### 2. Diagnose

Answer briefly:

- **What failed?** (observable behavior)
- **Which skill file should have prevented it?**
- **Root cause:** missing rule | ambiguous rule | redundant/conflicting rule | rule ignored

### 3. Patch skill (same session when possible)

Edit the **minimal** file in `handle-task-skill/`:

| Change type | Target |
| ----------- | ------ |
| New gate or checklist item | [SKILL.md](SKILL.md) Phase 7/8 or relevant delegate |
| Detailed how-to | New or existing delegate (keep [SKILL.md](SKILL.md) thin) |
| Remove duplication | Consolidate into one delegate; replace duplicates with links |
| PR/make-pull-request gap | [make-pull-request/workflow.md](make-pull-request/workflow.md) |

**Principles when editing:**

- **One source of truth** — one place for each rule; elsewhere link only
- **Shorter beats longer** — cut prose that repeats another file
- **Actionable** — checklists and tables over essays
- **Professional defaults** — TDD, spec traceability, reuse, SOLID as guardrails not ceremony

### 4. Notify user

Tell the user what was wrong and what changed in the skill:

> **Skill updated:** Added spec adherence audit to Phase 8 ([spec-adherence.md](spec-adherence.md)).
> Reason: tests passed but mixed-push scenario from spec was untested.

If the user owns `engineering-skills`, offer to open a PR (see below).

### 5. PR to engineering-skills (when user wants it persisted)

Repo: `engineering-skills` / `handle-task-skill/`

```bash
cd /path/to/engineering-skills
git checkout -b fix/skill-<short-slug>
# edit handle-task-skill/
git commit -m "docs(handle-task): <what and why>"
git push -u origin HEAD
gh pr create --title "docs(handle-task): ..." --body "..."
```

After merge: `./handle-task-skill/scripts/install-skills.sh --update`

Local-only patch (no PR): symlinks pick up edits immediately if working in the clone.

## What not to put in global skills

- Project-specific paths, ticket prefixes, verify commands → `.handle-task/project.yaml`
- One ticket's deferrals → task memory / PR body
- Entire spec text → local specs only

## Maintenance cadence

When touching the bundle for any reason:

1. Scan for **duplicate paragraphs** across delegates — merge or link
2. Ensure [SKILL.md](SKILL.md) orchestrates; delegates hold detail
3. Update [QUICKSTART.md](QUICKSTART.md) delegate table if files added/renamed

## Cross-references

- [spec-adherence.md](spec-adherence.md) — triggers improvement when process gaps found
- [SKILL.md](SKILL.md) — orchestrator; keep checklist current
