# Performance optimization

Standalone delegate for `/handle-task` and `/make-pull-request` when performance is in
scope or flagged in review.

## When to use

- Spec or PR calls out latency, throughput, or resource budgets
- Profiling or CI shows regression
- N+1 queries, unbounded loops, or hot-path allocations suspected

**When NOT to use:** no evidence of a problem — measure first.

## Workflow

```
MEASURE → IDENTIFY bottleneck → FIX → VERIFY → GUARD (test or metric)
```

Never optimize from assumptions alone.

## Measure

| Layer            | Examples                                     |
| ---------------- | -------------------------------------------- |
| Python / backend | `pytest` timing, APM, query logs, `cProfile` |
| CI / batch       | wall time on integration jobs, fixture I/O   |
| Frontend         | Lighthouse, DevTools Performance, Web Vitals |

Establish baseline before changing code.

## Fix principles

- Target the **proven** bottleneck only
- Prefer algorithmic fixes (fewer round trips, better data structure) over micro-opts
- Keep readability — document non-obvious perf trade-offs inline or in decisions log
- Reuse existing caching/batching patterns in the repo before inventing new ones

## Review checklist (with [code-review.md](code-review.md))

- N+1 or repeated work in loops
- Unbounded fetch / missing pagination
- Sync I/O on hot paths
- Large allocations in tight loops
- Missing concurrency where the codebase already uses a pattern

## Guard

- Add or extend a test when behavior must stay bounded (timeout, max size)
- Note remaining risk in PR if full perf validation is CI-only or manual

## Anti-patterns

- Premature caching without hit-rate evidence
- Optimizing cold paths while hot path unchanged
- New performance framework for a one-off script
