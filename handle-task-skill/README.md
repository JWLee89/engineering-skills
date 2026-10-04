# Moved — use `skills/`

> **If `/handle-task` still loads this folder:** run `./scripts/install-skills.sh --update` from the
> repo root, then reload Cursor. Until then, agents should follow
> [`SKILL.md`](SKILL.md) → [`skills/handle-task/`](../skills/handle-task/).

Canonical skill content lives under **[`../skills/`](../skills/)**.

| Legacy path | New path |
| ----------- | -------- |
| `handle-task-skill/` (bundle) | [`skills/handle-task/`](../skills/handle-task/) |
| `handle-task-skill/pull-request/` | [`skills/pull-request/`](../skills/pull-request/) |
| `handle-task-skill/code-review/` | [`skills/code-review/`](../skills/code-review/) |
| `handle-task-skill/create-ticket/` | [`skills/create-ticket/`](../skills/create-ticket/) |
| `handle-task-skill/review-ticket/` | [`skills/review-ticket/`](../skills/review-ticket/) |

**Install:**

```bash
./scripts/install-skills.sh
```

Catalog: [SKILLS_GUIDE.md](../SKILLS_GUIDE.md) · Benchmark: [docs/BENCHMARK-CLAUDE-SKILLS.md](../docs/BENCHMARK-CLAUDE-SKILLS.md)

This stub folder remains so old docs and symlinks can be updated gradually.
