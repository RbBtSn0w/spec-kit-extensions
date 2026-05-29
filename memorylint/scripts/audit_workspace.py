#!/usr/bin/env python3
"""Run MemoryLint against a real workspace."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from memorylint_core import generate_report, markdown_report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit a workspace for MemoryLint drift.")
    parser.add_argument("workspace", nargs="?", default=".", help="Workspace root to audit.")
    parser.add_argument(
        "--format",
        choices=("markdown", "json"),
        default="markdown",
        help="Output format written to stdout.",
    )
    parser.add_argument(
        "--json-out",
        type=Path,
        help="Optional path to also write the machine-readable JSON report.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    workspace_root = Path(args.workspace).resolve()
    report = generate_report(workspace_root)
    payload = report.to_dict()

    if args.json_out:
        args.json_out.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if args.format == "json":
        print(json.dumps(payload, indent=2, ensure_ascii=False))
    else:
        print(markdown_report(report), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
