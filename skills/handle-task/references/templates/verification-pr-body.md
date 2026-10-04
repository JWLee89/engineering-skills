## Verification plan (PR body)

Build in Phase 2 of [pull-request.md](../../pull-request.md). Three subsections are
**required** under `## Verification`:

### Steps run (author)

Checkboxes for commands the agent runs locally before/during PR iteration:

```markdown
### Steps run (author)

- [ ] `<verify.hooks or scoped lint>` — exit 0; `<summary line>`
- [ ] `<verify.commands[0]>` — exit 0; `<N passed>`; commit [shortsha](https://github.com/{owner}/{repo}/commit/{fullsha})
- [ ] Isolation — `<command>` — [tests/...::test_...](https://github.com/{owner}/{repo}/blob/{sha}/tests/….py#Lnn)
- [ ] Integration / smoke — `<command>` — `<brief output proof>`
```

When a step passes, check it and add evidence: command, exit code, summary line
(e.g. `42 passed`), linked test lines or node ids, linked commit SHA, and/or CI run URL.
See [verification.md](../../verification.md#agentic-validation-always-required).

### Test plan (reviewer / CI)

Items that need GitHub Actions or branch-level proof:

```markdown
### Test plan (reviewer / CI)

- [ ] **CI** workflow green — <name from verify.ci_workflows>
- [ ] <scenario> — [run ID](https://github.com/org/repo/actions/runs/...) (after verification commit)
```

Use **verification commits** (Phase 5b) when behavior only shows on a follow-up push.

### Test coverage (when behavior changes)

Optional but recommended (aligns with [Jeffallan code-reviewer](https://github.com/Jeffallan/claude-skills/blob/main/skills/code-reviewer/references/report-template.md)):

```markdown
### Test coverage (when code changes)

- [ ] Happy path covered
- [ ] Error / edge paths covered
- [ ] Spec criteria traced (see Background)
```

### Out of scope

```markdown
### Out of scope

- <deferred ticket or workflow>
- <explicit non-goals from spec>
```
