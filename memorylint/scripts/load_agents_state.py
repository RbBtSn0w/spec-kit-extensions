#!/usr/bin/env python3
"""Emit structured proof that AGENTS.md was loaded before planning."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from memorylint_core import extract_rules, relative_path, sha256


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Summarize the root AGENTS.md file.")
    parser.add_argument("workspace", nargs="?", default=".", help="Workspace root.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    workspace_root = Path(args.workspace).resolve()
    agents_path = workspace_root / "AGENTS.md"
    if not agents_path.exists():
        raise SystemExit("AGENTS.md not found at workspace root")

    rules = [rule for rule in extract_rules(workspace_root, [agents_path]) if rule.source == "AGENTS.md"]
    payload = {
        "workspace_root": str(workspace_root),
        "agents_path": relative_path(agents_path, workspace_root),
        "agents_sha256": sha256(agents_path),
        "rule_count": len(rules),
        "sections": sorted({rule.heading for rule in rules if rule.heading}),
        "rule_summaries": [
            {
                "rule_id": rule.rule_id,
                "line_range": rule.line_range,
                "category": rule.category,
                "summary": rule.summary,
            }
            for rule in rules
        ],
    }
    print(json.dumps(payload, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
