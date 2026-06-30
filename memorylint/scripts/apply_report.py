#!/usr/bin/env python3
"""Apply MemoryLint findings from a machine-readable report."""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import defaultdict
from pathlib import Path

from memorylint_core import (
    approved_findings,
    deep_copy_report,
    extract_report_payload,
    format_apply_failure,
    format_apply_summary,
    read_text,
    resolve_workspace_path,
    validate_agents_integrity,
    validate_constitution_integrity,
    validate_hook_consistency,
    validate_repository_diff,
    apply_edits_to_lines,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Apply MemoryLint report findings.")
    parser.add_argument("report", type=Path, help="Path to the Markdown or JSON audit report.")
    parser.add_argument(
        "--mode",
        choices=("report-only", "apply-safe-fixes", "apply-all-approved"),
        default="report-only",
        help="Apply strategy.",
    )
    parser.add_argument(
        "--approve",
        action="append",
        default=[],
        help="Finding id to approve when using apply-all-approved. Repeatable.",
    )
    parser.add_argument(
        "--handoff-out",
        type=Path,
        help="Optional path to write manual handoff findings as JSON.",
    )
    parser.add_argument(
        "--workspace",
        type=Path,
        help="Optional workspace root override. Defaults to the path stored in the report.",
    )
    return parser.parse_args()


def grouped_edits(findings: list[dict[str, object]]) -> dict[str, list[dict[str, object]]]:
    grouped: dict[str, list[dict[str, object]]] = defaultdict(list)
    for finding in findings:
        for edit in finding.get("edits", []):
            grouped[edit["path"]].append(edit)
    return grouped


def protected_edit_issues(findings: list[dict[str, object]]) -> list[str]:
    issues: list[str] = []
    for finding in findings:
        for edit in finding.get("edits", []):
            if str(edit["path"]).endswith(".specify/memory/constitution.md"):
                issues.append(
                    f"Finding {finding['id']} targets .specify/memory/constitution.md. Constitution edits must stay manual handoffs."
                )
    return issues


def overlapping_edit_issues(edits_by_file: dict[str, list[dict[str, object]]]) -> list[str]:
    issues: list[str] = []
    for relative, edits in edits_by_file.items():
        previous: tuple[int, int] | None = None
        for edit in sorted(edits, key=lambda item: (int(item["start_line"]), int(item["end_line"]))):
            start = int(edit["start_line"])
            end = int(edit["end_line"])
            if previous and start <= previous[1]:
                issues.append(
                    f"Overlapping edits detected in {relative}: {previous[0]}-{previous[1]} conflicts with {start}-{end}."
                )
                break
            previous = (start, end)
    return issues


def main() -> int:
    args = parse_args()
    report_path = args.report.resolve()
    report_payload = extract_report_payload(report_path.read_text(encoding="utf-8"))
    report_copy = deep_copy_report(report_payload)
    workspace_root = args.workspace.resolve() if args.workspace else Path(report_copy["workspace_root"]).resolve()

    approved = approved_findings(report_copy, args.mode, set(args.approve))
    manual_handoffs = [finding for finding in report_copy.get("findings", []) if finding.get("manual_handoff")]
    if args.handoff_out:
        args.handoff_out.write_text(
            json.dumps(manual_handoffs, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    if args.mode == "report-only":
        print(format_apply_summary([], [], []), end="")
        return 0

    policy_issues = protected_edit_issues(approved)
    if policy_issues:
        print(format_apply_failure(policy_issues, []), end="")
        return 1

    source_hashes = {item["path"]: item["sha256"] for item in report_copy.get("source_metadata", [])}
    target_paths = sorted({edit["path"] for finding in approved for edit in finding.get("edits", [])})
    resolved_targets: dict[str, Path] = {}
    for relative in target_paths:
        try:
            target_path = resolve_workspace_path(workspace_root, relative)
        except ValueError as exc:
            print(format_apply_failure([str(exc)], []), end="")
            return 1
        resolved_targets[relative] = target_path
        if not target_path.exists():
            print(format_apply_failure([f"Target file disappeared after audit: {relative}"], []), end="")
            return 1
        current_hash = hashlib.sha256(target_path.read_bytes()).hexdigest()
        if source_hashes.get(relative) != current_hash:
            print(
                format_apply_failure(
                    [
                        f"Staleness check failed for {relative}: the file changed since the audit "
                        "(an agent-context managed-block update is a common cause). Re-run "
                        "/speckit-memorylint-audit to regenerate the report, then re-apply."
                    ],
                    [],
                ),
                end="",
            )
            return 1

    originals = {relative: read_text(resolved_targets[relative]) for relative in target_paths}
    edits_by_file = grouped_edits(approved)
    overlap_issues = overlapping_edit_issues(edits_by_file)
    if overlap_issues:
        print(format_apply_failure(overlap_issues, sorted(originals)), end="")
        return 1
    for relative, edits in edits_by_file.items():
        target_path = resolved_targets[relative]
        updated = apply_edits_to_lines(read_text(target_path).splitlines(), edits)
        target_path.write_text("\n".join(updated).rstrip() + "\n", encoding="utf-8")

    validation_issues: list[str] = []
    for relative, before_text in originals.items():
        after_text = read_text(resolved_targets[relative])
        if relative.endswith("AGENTS.md"):
            validation_issues.extend(validate_agents_integrity(before_text, after_text))
        if relative.endswith(".specify/memory/constitution.md"):
            finding_map = {finding["id"]: finding for finding in approved}
            validation_issues.extend(validate_constitution_integrity(before_text, after_text, finding_map))
    validation_issues.extend(validate_hook_consistency(workspace_root))
    validation_issues.extend(validate_repository_diff(workspace_root))

    if validation_issues:
        for relative, before_text in originals.items():
            resolved_targets[relative].write_text(before_text, encoding="utf-8")
        print(format_apply_failure(validation_issues, sorted(originals)), end="")
        return 1

    print(format_apply_summary(approved, sorted(originals), []), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
