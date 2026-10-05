# Engineering skills

Portable [Cursor Agent Skills](https://cursor.com/docs/agent/skills) and
[Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills) for
software engineering workflows.

**Catalog:** [SKILLS_GUIDE.md](SKILLS_GUIDE.md) · **Quick start (agents):** [skills/handle-task/QUICKSTART.md](skills/handle-task/QUICKSTART.md)

Skills live under **`skills/{name}/`** with `SKILL.md` entry points and delegate docs.
Per-project settings go in your target repo as **`.handle-task/project.yaml`**.

## Available skills

Invokable skills, decision tree, and SSOT map: **[SKILLS_GUIDE.md](SKILLS_GUIDE.md)**.

## Quick start

### 1. Clone and install globally

```bash
git clone https://github.com/JWLee89/engineering-skills.git
cd engineering-skills
./scripts/install-skills.sh
```

Symlinks into:

- `~/.cursor/skills/` (Cursor)
- `~/.claude/skills/` (Claude Code)

Reload Cursor after install. Restart Claude Code if `/handle-task` does not appear.

### 2. Configure a target repository

```bash
mkdir -p .handle-task
cp /path/to/engineering-skills/skills/handle-task/examples/generic.project.yaml .handle-task/project.yaml
```

Edit `.handle-task/project.yaml` (prefix, verify commands, issue tracker). Commit the config;
add local spec dir (default `tasks/`) to `.gitignore`.

### 3. Work a ticket

```
/handle-task PROJ-123
```

Then, when implementation is verified locally:

```
/pull-request
```

## Layout

Catalog layout follows common `skills/{name}/SKILL.md` + `references/` patterns (see
[Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) — MIT; we cite patterns, not vendored prose).

**Migrating from pre–PR #10 clones:** run `./scripts/install-skills.sh --update` so symlinks
point at `skills/*` (the old `handle-task-skill/` path was removed).

## Contributing

1. Fork and branch from `main`
2. Edit under `skills/`
3. Run `python3 scripts/check-markdown-links.py` (CI runs the same on PRs)
4. Open a PR using the repository template
5. After merge: `./scripts/install-skills.sh --update`

## License

[MIT](LICENSE)
