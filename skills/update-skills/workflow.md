# Update skills — workflow

**Entry:** [SKILL.md](SKILL.md).

```
Phase 0  Resolve scope and repo
Phase 1  Survey affected skills (lazy)
Phase 1b [optional] Mine PR review comments
Phase 2  Exclusion gate → inclusion rubric
Phase 3  Intent proposal → user approval (mandatory)
Phase 4  Patch skills (minimal diff)
Phase 5  Catalog + installer
Phase 6  Verify
```

______________________________________________________________________

## Phase 0: Resolve scope

| Question | Default |
| -------- | ------- |
| **Which repo?** | Current workspace if it contains `skills/*/SKILL.md`; else clone/path user gives |
| **New vs modify?** | User request; if unclear, ask once |
| **Target skill** | Name under `skills/{name}/`; kebab-case, matches `name` in frontmatter |
| **Personal vs catalog** | This workflow targets **engineering-skills** catalog skills; personal `~/.cursor/skills/` only when user explicitly asks |

Record: skill name(s), trigger (user request | PR feedback | incorrect behavior | missing gate).

______________________________________________________________________

## Phase 1: Survey (lazy)

Before proposing edits:

1. Read **`SKILL.md`** for each affected skill (orchestrator only).
2. Read **only** delegates the change touches (workflow, rubric, templates).
3. Skim [SKILLS_GUIDE.md](../../SKILLS_GUIDE.md) and [README.md](../../README.md) if adding/renameing an invokable skill.
4. Summarize in **≤10 bullets**: purpose, SSOT files, triggers, overlaps with other skills.

Do **not** load the full handle-task bundle unless the change is inside `skills/handle-task/`.

______________________________________________________________________

## Phase 1b: PR review feedback (optional)

When the user ties the update to a merged or open PR:

1. Fetch comments: `gh pr view <n> --comments` and review threads (`gh api` if needed).
2. Classify each thread: **skill gap** (durable process/rule) vs **one-off** (ticket/decision/project config).
3. Only **skill gap** items proceed; one-offs → `.handle-task/project.yaml`, task memory, or PR body — not global skills ([self-improvement.md](../handle-task/self-improvement.md#what-not-to-put-in-global-skills)).

______________________________________________________________________

## Phase 2: Rubric gates

Run **[exclusion-gate.md](references/exclusion-gate.md)** first. If the change fails exclusion, **stop** — explain which criterion blocked it and offer alternatives (decision log, project rule, do nothing).

If exclusion passes, apply **[inclusion-rubric.md](references/inclusion-rubric.md)** to shape the patch.

______________________________________________________________________

## Phase 3: Intent proposal (mandatory gate)

Present to the user **before any file edit**:

```markdown
## Skillbase change proposal

**Intent:** [one sentence]
**Skills/files:** [list]
**Exclusion gate:** pass | blocked (reason)
**Inclusion fit:** [which rubric lines apply]

### Planned diff (bullets)
- Add / change / delete …

### Out of scope
- …

**Approve this intent?** (yes / revise / cancel)
```

Wait for explicit **yes** or a revised intent. Paraphrase user wording for new rules when they supplied exact copy.

______________________________________________________________________

## Phase 4: Patch skills

**New skill**

1. Create `skills/{name}/SKILL.md` with frontmatter aligned to peers (`name`, `version`, `domain`, `role`, `scope`, `triggers`, `related-skills`, `description`, `disable-model-invocation: true`).
2. Add `workflow.md` when steps exceed a short checklist; put long rubrics under `references/`.
3. Keep `SKILL.md` thin; target **<500 lines** ([Anthropic best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)).

**Modify existing**

1. Edit the **single SSOT** file for the rule.
2. Delete or shorten duplicated prose elsewhere; add links only.
3. Prefer tables and checklists over essays ([Writing for Agents](https://www.aihero.dev/skills-writing-for-agents)).

**Security**

- Never add secrets, credentials, or “run arbitrary curl/bash from the user” patterns.
- Do not instruct bypassing hooks, sandbox, or review gates unless the user explicitly owns that risk in project config.

**Authoring defaults for this catalog**

- Invoke line + lazy-load table in `SKILL.md`
- Cross-link companions; avoid overlapping globals for the same phase ([SKILLS_GUIDE.md](../../SKILLS_GUIDE.md#recipe-optional-global-skills-cursor--claude))

______________________________________________________________________

## Phase 5: Catalog + installer

When adding or renaming an invokable skill:

| File | Action |
| ---- | ------ |
| [README.md](../../README.md) | Skills table |
| [SKILLS_GUIDE.md](../../SKILLS_GUIDE.md) | Invokable table + decision tree if behavior changes |
| [scripts/install-skills.sh](../../scripts/install-skills.sh) | `SKILL_NAMES`, `skill_source_dir`, manifest lines |
| [handle-task/QUICKSTART.md](../handle-task/QUICKSTART.md) | Only if invoke map or SSOT table changes |
| [handle-task/SKILL.md](../handle-task/SKILL.md) delegates | Link new meta skill when relevant |

After merge (tell user): `./scripts/install-skills.sh --update` and reload Cursor if frontmatter changed.

______________________________________________________________________

## Phase 6: Verify

From repo root:

```bash
python3 scripts/check-markdown-links.py
```

Fix broken relative links. Optional: `./scripts/install-skills.sh --list` shows the new symlink target.

______________________________________________________________________

## Open a skill PR (when user wants persistence)

Branch from `main`, conventional commits, PR template. Suggested title: `docs({skill}): {why}`.

Use `/pull-request` for body sections and CI. Offer `/code-review` before ready for non-trivial rubric changes.
