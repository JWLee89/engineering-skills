# Anti-patterns (orchestrator)

**Entry:** [../SKILL.md](../SKILL.md) · Phase-specific tables live in delegate files — do not copy them here.

| Mistake | Fix |
| ------- | --- |
| Code without spec/plan approval | Gates in [specify.md](../specify.md), [plan-and-tasks.md](../plan-and-tasks.md) |
| Tracker ticket “approved” treated as spec approval | Ticket gate then **local spec** gate — [specify.md](../specify.md) |
| Skip `/review-ticket` on tracker issues | Phase 1 |
| Silent deferral of spec items | Report + user ack in PR ([spec-adherence.md](../spec-adherence.md)) |
| Full-stack only, no isolation proof | [feature-gating.md](../feature-gating.md) in plan + slice |
| `gh pr create` with summary-only body | `/pull-request` + [reviewer-friendly PR body](../../pull-request/references/reviewer-friendly-pr-body.md) |
| `gh pr ready` without `/code-review` | [Phase 9b](../SKILL.md#phase-9-pull-request-draft-deep-code-review) |
| User asked to run tests | Agent runs verify ([verification.md](../verification.md)) |
| “Tests pass” with no command output | Evidence in [verification.md](../verification.md) |
| Author self-review only, skip `/code-review` | Phase 9b vs [engineering-rubric.md](../engineering-rubric.md) |
| Read entire skill bundle at intake | [Lazy load](../SKILL.md#lazy-load-do-not-read-the-whole-bundle) |
| Duplicate ticket/review criteria in SKILL | [quality-gate.md](../../review-ticket/quality-gate.md), [code-review/rubric.md](../../code-review/rubric.md) |
