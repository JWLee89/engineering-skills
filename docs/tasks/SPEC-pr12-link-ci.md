# SPEC — PR #12: Markdown link hygiene CI

**Base:** `main` @ post–PR #11 · **Branch:** `feat/markdown-link-ci`  
**Parent:** [plan-post-catalog.md](plan-post-catalog.md)

## Objective

Catch broken **relative** markdown links under `skills/` before merge, so lazy-load splits
(like PR #11) cannot regress navigation between SKILL delegates, `references/`, and templates.

## Success criteria

1. `scripts/check-markdown-links.py` walks `skills/**/*.md` (configurable root).
2. Validates `[text](path)` and `![alt](path)` where `path` is relative (not `http(s):`, `mailto:`, or `#`-only).
3. Resolves paths from the source file directory; ignores URL fragments for existence checks.
4. Skips template placeholders (`{…}`, `<…>`) and obvious forge placeholders in draft templates.
5. `.github/workflows/markdown-links.yml` runs the script on `pull_request` and `push` to `main`.
6. `./scripts/check-markdown-links.py` exits 0 on current `main` tree.
7. [plan-post-catalog.md](plan-post-catalog.md) marks PR #11 complete and documents PR #12 verify.

## Boundaries

| Always | Never |
| ------ | ----- |
| Relative links under `skills/` only (v1) | Network HEAD requests to external URLs |
| Stdlib Python 3 | New npm/ruby link-checker deps |
| Fail CI on broken relative targets | Rewrite skill prose in this PR |

## Out of scope

- `docs/`, root README, or GitHub-rendered anchor validation
- Anti-pattern dedupe (PR #13)
- BENCHMARK “initiative closed” footer until PR #12 merges

## Verify

```bash
python3 scripts/check-markdown-links.py
./scripts/install-skills.sh --list
```
