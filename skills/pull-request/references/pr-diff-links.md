# PR diff and source links (GitHub)

Use when building **Focus areas** in [reviewer-friendly-pr-body.md](reviewer-friendly-pr-body.md). Run pre-flight git/gh commands from [workflow.md Phase 1](../workflow.md#phase-1-pre-flight) first.

Adjust host/path for non-GitHub forges when the user specifies them.

## URL patterns

| Target | URL pattern |
| ------ | ----------- |
| **Commit** | `https://github.com/{owner}/{repo}/commit/{sha}` |
| **PR diff (preferred)** | `https://github.com/{owner}/{repo}/pull/{n}/changes#diff-{diff_id}R{start}-R{end}` |
| **File at commit** | `https://github.com/{owner}/{repo}/blob/{sha}/{path}#L{start}-L{end}` |
| **Markdown source (plain)** | Insert **`?plain=1`** before `#L` — e.g. `…/doc.md?plain=1#L90-L112` |

**PR diff `diff_id`:** SHA-256 hex of the **repo-relative file path** (UTF-8):

```bash
python3 -c "import hashlib,sys; print(hashlib.sha256(sys.argv[1].encode()).hexdigest())" "path/to/file.md"
```

Use **`R{line}`** on the diff anchor for the **new** side (right column). Line numbers match the PR tip branch.

Use **PR tip** (`HEAD` after push) for `blob/{sha}/…` links. After `gh pr create`, refresh body with `/pull/{n}/changes#diff-…` anchors.

## Link formatting

**Human-readable link text** — not bare backticks. Prefer **Review** (this PR diff) + optional **Source** (blob):

```markdown
**Review:** [workflow.md L90–112 (this PR)](https://github.com/org/repo/pull/7/changes#diff-e0a158…R90-R112) ·
**Source:** [plain L90–112](https://github.com/org/repo/blob/abc123…/workflow.md?plain=1#L90-L112)
```

Non-markdown (`.py`, `.yaml`, …): Review diff link + optional Source blob without `?plain=1`.

**Gold example:** [PR #8](https://github.com/JWLee89/engineering-skills/pull/8).
