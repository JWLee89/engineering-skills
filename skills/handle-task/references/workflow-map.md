# Nine-step workflow map

See [QUICKSTART.md](../QUICKSTART.md) and [SKILLS_GUIDE.md](../../../SKILLS_GUIDE.md) for recipes.

```
1 (opt) /create-ticket → /review-ticket
2       /review-ticket  (ticket ready)
3       specify.md      (local spec approved)
4       plan-and-tasks.md (plan approved)
5       pr-splitting.md (if oversized)
6       implement + engineering-rubric.md
7       author rubric checklist
8       /pull-request draft (Phases 1–4)
9       /code-review → /pull-request ready
```

**Gates:** ticket → spec → plan → agentic verify → draft PR → `/code-review` → CI ready.
