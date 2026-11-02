# Business impact (optimizations)

Delegate for `/handle-task`, `/pull-request`, and [performance-optimization.md](performance-optimization.md)
when a change reduces **disk, network, memory, or runtime** cost in production.

## When to use

- Dependency swaps, image slimming, caching, batching, or infra footprint changes
- Ticket or PR claims “lighter”, “cheaper”, or “faster” for operators or customers

**When NOT to use:** correctness-only fixes with no resource delta; unmeasured hand-wavy “saves money”.

## Workflow

```
CLARIFY (if needed) → MEASURE absolute delta → PROVE (smoke / CI) → LINK cost model → DISCLOSE assumptions
```

Never publish cost dollars without stating the formula and what was **measured** vs **modeled**.

## 0. Clarify with the operator (when the metric is ambiguous)

Stop and ask in chat (do not invent a scenario) when any of these are unclear:

| Gap | Ask for |
| --- | ------- |
| **Unit of savings** | Disk per install, image layer, RSS, egress per pull, or runtime per request? |
| **Production surface** | Linux x86_64 in GKE, developer Mac, CI runner, customer edge? |
| **Event scale** | Per deploy, per 100k docker pulls, monthly pod count, requests/sec? |
| **Billing context** | Same-region GAR only, cross-region, internet egress, or internal PyPI? |
| **Success criterion** | Must show USD, GB transferred, or reliability (fewer smoke failures) enough? |

Use plain words. The operator answers in their own words. After they clarify, re-run measurement
on the path they named.

**After clarification:** if the gap was missing from this delegate, append a short note to
[business-impact.md](business-impact.md) (same PR when possible) or file a follow-up via
[self-improvement.md](self-improvement.md) so the next task does not repeat the ambiguity.

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

### Cost calculation references (verify assumptions)

Link at least one authoritative doc when you publish USD. Pick the doc that matches the scenario
the operator confirmed (or the repo’s default registry if none was stated).

| Scenario | What to cite | Official docs (verify current rates) |
| -------- | ------------ | ------------------------------------ |
| **Artifact Registry / GCR egress** | $/GB internet or cross-region egress | [Google Cloud Artifact Registry pricing](https://cloud.google.com/artifact-registry/pricing) · [Cloud Storage network pricing](https://cloud.google.com/storage/pricing#network-pricing) (when layers live in GCS-backed storage) |
| **Amazon ECR / S3-backed images** | Data transfer out | [Amazon ECR pricing](https://aws.amazon.com/ecr/pricing/) · [Amazon S3 transfer pricing](https://aws.amazon.com/s3/pricing/) |
| **Azure Container Registry** | Geo-replication and bandwidth | [Azure Container Registry pricing](https://azure.microsoft.com/en-us/pricing/details/container-registry/) |
| **PyPI / public package download** | Bytes per `pip install` (not registry pull) | State **no cloud egress line item** unless packages are mirrored in your registry; model bytes × mirror egress rate instead |
| **Compute time saved** | vCPU-seconds or GPU-hours | [Google Cloud compute pricing](https://cloud.google.com/compute/all-pricing) · [AWS EC2 pricing](https://aws.amazon.com/ec2/pricing/on-demand/) — match instance family to production |

In the PR, add a **Cost assumptions** bullet with the doc URL and the rate or tier you used.
Re-check the doc in the same session; list prices change.

**Internal billing:** when the org has a FinOps sheet or dashboard, prefer that over public list
price and link the internal doc if the operator provides it.

## 4. PR body placement

In `/pull-request` Phase 2, add **Business impact** under **Verification** (or its own section):

- **Absolute:** MB / ms saved per unit (measured)
- **Proof:** smoke or CI link
- **Modeled cost:** per 100k events with assumptions
- **Cost assumptions:** linked pricing doc(s) and $/GB or $/hour used
- **Out of scope:** what you did not measure (e.g. apt layer size without image rebuild)

## Anti-patterns

- Quoting “~20% smaller” without MB or bytes
- macOS dev numbers applied to Linux production without label
- Single dollar figure with no formula or assumption range
- Modeling docker-pull cost when the change only affects `pip install` (or the reverse) without operator confirmation
- Public list price with no doc link and no “assumption” label
