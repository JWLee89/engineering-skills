#!/usr/bin/env python3
"""Verify relative markdown links under a directory tree.

Scans ``*.md`` under ``--root`` (default: ``skills/``) for inline links
``[text](url)`` and images ``![alt](url)``.

**Skipped URLs (not validated):**

- Empty, ``#``-only fragment anchors
- ``http://``, ``https://``, ``mailto:``, ``ftp://``
- Template placeholders containing ``{``, ``<``, or ``…`` (ellipsis)
- Commit/PR title examples: single tag tokens like ``feat`` or ``test``
- Non-path tokens without ``.`` or ``/`` (not file-like)

**Not scanned:** Markdown inside fenced code blocks (``` … ```) — examples may
show fake paths without failing CI.

**Targets:** Relative paths are resolved from the source file's directory; URL
fragments are ignored for existence checks. Missing files anywhere on disk are
reported; paths outside ``--repo-root`` print as absolute paths in errors.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
FENCE_RE = re.compile(r"^```[^\n]*\n.*?^```\s*$", re.MULTILINE | re.DOTALL)

SKIP_PREFIXES = ("http://", "https://", "mailto:", "ftp://")
SKIP_SUBSTRINGS = ("{", "<", "example.com", "github.com/{owner}", "…")

# Commit/PR title examples embed markdown like `[TICKET](feat)` inside prose.
EXAMPLE_TAG_ONLY = re.compile(r"^[a-z][a-z0-9_-]*$")


def strip_fenced_code_blocks(text: str) -> str:
    return FENCE_RE.sub("", text)


def is_skippable(url: str) -> bool:
    url = url.strip()
    if not url or url.startswith("#"):
        return True
    if url.startswith(SKIP_PREFIXES):
        return True
    if any(part in url for part in SKIP_SUBSTRINGS):
        return True
    # Relative file links should look like paths (../foo.md, references/bar.md).
    if EXAMPLE_TAG_ONLY.match(url):
        return True
    if "." not in url and "/" not in url:
        return True
    return False


def target_path(source: Path, url: str) -> Path:
    path_part = url.split("#", 1)[0].strip()
    if not path_part:
        return source
    return (source.parent / path_part).resolve()


def format_target(repo_root: Path, resolved: Path) -> str:
    try:
        return str(resolved.relative_to(repo_root))
    except ValueError:
        return str(resolved)


def collect_markdown_files(root: Path) -> list[Path]:
    return sorted(root.rglob("*.md"))


def check_file(md: Path, repo_root: Path) -> list[str]:
    errors: list[str] = []
    try:
        text = strip_fenced_code_blocks(md.read_text(encoding="utf-8"))
    except OSError as exc:
        return [f"{md.relative_to(repo_root)}: read failed: {exc}"]

    for match in LINK_RE.finditer(text):
        url = match.group(1).strip()
        if is_skippable(url):
            continue
        resolved = target_path(md, url)
        if not resolved.exists():
            rel_src = md.relative_to(repo_root)
            target_label = format_target(repo_root, resolved)
            errors.append(f"{rel_src}: broken link {url!r} -> {target_label}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Verify relative markdown links under a directory tree."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path("skills"),
        help="Directory to scan (default: skills)",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path.cwd(),
        help="Repository root for relative error paths",
    )
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    scan_root = (repo_root / args.root).resolve()
    if not scan_root.is_dir():
        print(f"error: not a directory: {scan_root}", file=sys.stderr)
        return 2

    markdown_files = collect_markdown_files(scan_root)
    all_errors: list[str] = []
    for md in markdown_files:
        all_errors.extend(check_file(md, repo_root))

    if all_errors:
        print(f"Found {len(all_errors)} broken relative link(s):\n", file=sys.stderr)
        for line in all_errors:
            print(f"  {line}", file=sys.stderr)
        return 1

    print(
        f"OK: {len(markdown_files)} markdown file(s) under {args.root}/ "
        "— relative links resolve."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
