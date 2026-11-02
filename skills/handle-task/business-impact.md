# Business impact (optimizations)

Delegate for `/handle-task`, `/pull-request`, and [performance-optimization.md](performance-optimization.md)
when a change reduces **disk, network, memory, or runtime** cost in production.

## When to use

- Dependency swaps, image slimming, caching, batching, or infra footprint changes
- Ticket or PR claims “lighter”, “cheaper”, or “faster” for operators or customers

**When NOT to use:** correctness-only fixes with no resource delta; unmeasured hand-wavy “saves money”.

## Workflow

```
MEASURE absolute delta → PROVE (smoke / CI) → LINK cost model → DISCLOSE assumptions
```

Never publish cost dollars without stating the formula and what was **measured** vs **modeled**.

## 1. Measure absolute deltas (required)

Report at least one **absolute** figure in PR and ticket verification:

| Metric | Examples |
| ------ | -------- |
| Disk | Installed package dir (`du`), wheel bytes from lockfile/PyPI, image layer diff |
| Network | Compressed wheel or layer bytes transferred per deploy |
| Memory | RSS after import or steady-state (platform-specific — label OS/arch) |
| Time | p50/p95 latency or job duration (baseline vs after) |

Use the same version pins and platform as production when possible. If you only have lockfile
wheel sizes, say **network/disk (wheel)** not “memory saved”.

## 2. Prove behavior unchanged

Optimizations must not regress behavior. Tie proof to [verification.md](verification.md):

- Smoke command (e.g. `import cv2`, one inference path)
- CI green on the PR
- Optional before/after fixture diff for outputs

## 3. Link to cost (when plausible)

After absolute deltas are measured, add a **cost model** table. Always include:

- **Scenario** (what event repeats: docker pull, pip install, pod start, request)
- **Scale** (e.g. per 100,000 pulls, per month at N deploys)
- **Bytes or seconds saved per event**
- **Price assumption** (egress $/GB, vCPU $/hour) marked **assumption** with source or range
- **Result** in USD or GB-month (derived, not measured)

Example (registry egress — illustrative rates):

```text
saved_per_event_mb = 12.69  # manylinux x86_64 wheel delta, measured from lockfile
events = 100_000
transfer_gb = saved_per_event_mb * events / 1024
cost_low  = transfer_gb * 0.09   # assumption: $/GB egress lower bound
cost_high = transfer_gb * 0.23   # assumption: $/GB egress upper bound
```

Same-region pulls, layer deduplication, and CDN cache **reduce** real spend. State that real cost
is at most the upper-bound model unless you have billing data.

## 4. PR body placement

In `/pull-request` Phase 2, add **Business impact** under **Verification** (or its own section):

- **Absolute:** MB / ms saved per unit (measured)
- **Proof:** smoke or CI link
- **Modeled cost:** per 100k events with assumptions
- **Out of scope:** what you did not measure (e.g. apt layer size without image rebuild)

## Anti-patterns

- Quoting “~20% smaller” without MB or bytes
- macOS dev numbers applied to Linux production without label
- Single dollar figure with no formula or assumption range
