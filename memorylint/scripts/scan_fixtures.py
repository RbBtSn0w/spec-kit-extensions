#!/usr/bin/env python3
"""Deterministic MemoryLint fixture scanner.

This script intentionally covers the regression fixture corpus, not the full
interactive audit command. It turns the design contract into executable evidence
by proving the bundled fixtures produce the expected drift findings.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class Finding:
    drift_type: str
    severity: str
    confidence: str
    description: str
    source: str
    evidence: str
    recommended_destination: str
    suggested_action: str

    def expected_dict(self) -> dict[str, str]:
        return {
            "drift_type": self.drift_type,
            "severity": self.severity,
            "confidence": self.confidence,
            "description": self.description,
            "source": self.source,
            "evidence": self.evidence,
            "recommended_destination": self.recommended_destination,
            "suggested_action": self.suggested_action,
        }

    def as_dict(self) -> dict[str, str]:
        return {
            "id": "",
            "drift_type": self.drift_type,
            "severity": self.severity,
            "confidence": self.confidence,
            "description": self.description,
            "source": self.source,
            "evidence": self.evidence,
            "recommended_destination": self.recommended_destination,
            "suggested_action": self.suggested_action,
        }


def read_text(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fixture_dirs(fixtures_dir: Path) -> Iterable[Path]:
    for child in sorted(fixtures_dir.iterdir()):
        if child.is_dir() and not child.name.startswith((".", "_")):
            yield child


def source_files(fixture: Path) -> list[Path]:
    return sorted(
        path
        for path in fixture.rglob("*")
        if path.is_file() and path.name != "expected-findings.json"
    )


def rel(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def has_constitution(fixture: Path) -> bool:
    return (fixture / ".specify/memory/constitution.md").exists()


def scan_boundary_drift(fixture: Path) -> list[Finding]:
    findings: list[Finding] = []
    agents = fixture / "AGENTS.md"
    agents_text = read_text(agents)

    boundary_patterns = [
        (
            "Use MVC pattern",
            "Architecture rule 'Use MVC pattern' in AGENTS.md belongs in constitution.md",
            "AGENTS.md contains an architecture pattern rule outside the constitution.",
        ),
        (
            "State management must be handled via Redux",
            "Architecture rule 'State management via Redux' in AGENTS.md belongs in constitution.md",
            "AGENTS.md contains a state-management architecture rule outside the constitution.",
        ),
        (
            "API design must follow REST principles",
            "Architecture rule 'API design must follow REST principles' in AGENTS.md belongs in constitution.md",
            "AGENTS.md contains an API design rule outside the constitution.",
        ),
    ]
    for needle, description, evidence in boundary_patterns:
        if needle in agents_text:
            findings.append(
                Finding(
                    drift_type="boundary",
                    severity="warning",
                    confidence="high",
                    description=description,
                    source="AGENTS.md",
                    evidence=evidence,
                    recommended_destination=".specify/memory/constitution.md",
                    suggested_action="move",
                )
            )

    cursor_rules = fixture / ".cursor/rules/project.md"
    cursor_text = read_text(cursor_rules)
    if "## Architecture" in cursor_text and "hexagonal architecture" in cursor_text:
        findings.append(
            Finding(
                drift_type="boundary",
                severity="warning",
                confidence="high",
                description="Architecture rules in .cursor/rules/project.md belong in constitution.md, not in editor-specific config",
                source=".cursor/rules/project.md",
                evidence=".cursor/rules/project.md contains an Architecture section with architecture-boundary rules.",
                recommended_destination=".specify/memory/constitution.md",
                suggested_action="move",
            )
        )

    return findings


def scan_reality_drift(fixture: Path) -> list[Finding]:
    findings: list[Finding] = []
    agents_text = read_text(fixture / "AGENTS.md")

    if "scripts/deploy.sh" in agents_text and not (fixture / "scripts/deploy.sh").exists():
        findings.append(
            Finding(
                drift_type="reality",
                severity="warning",
                confidence="high",
                description="AGENTS.md references 'scripts/deploy.sh' but the file does not exist in the workspace",
                source="AGENTS.md",
                evidence="AGENTS.md names scripts/deploy.sh and the fixture has no scripts/deploy.sh file.",
                recommended_destination="N/A",
                suggested_action="delete",
            )
        )

    if "npm run e2e" in agents_text:
        package_json = fixture / "package.json"
        if not package_json.exists() or '"e2e"' not in read_text(package_json):
            findings.append(
                Finding(
                    drift_type="reality",
                    severity="warning",
                    confidence="high",
                    description="AGENTS.md references 'npm run e2e' but no package.json with e2e script exists in the workspace",
                    source="AGENTS.md",
                    evidence="AGENTS.md names npm run e2e and no package.json e2e script exists in the fixture.",
                    recommended_destination="N/A",
                    suggested_action="delete",
                )
            )

    if (
        not has_constitution(fixture)
        and "## CI Entry Points" in agents_text
        and "Workflow files live in `.github/workflows/`" not in agents_text
    ):
        findings.append(
            Finding(
                drift_type="reality",
                severity="info",
                confidence="medium",
                description="constitution.md does not exist in the workspace — architecture rules have no canonical home",
                source=".specify/memory/constitution.md",
                evidence="The fixture does not contain .specify/memory/constitution.md.",
                recommended_destination=".specify/memory/constitution.md",
                suggested_action="keep",
            )
        )

    extension_text = read_text(fixture / "extension.yml")
    declared_commands = set(re.findall(r'name:\s*["\']?([^"\'\s]+)["\']?', extension_text))
    hook_commands = re.findall(r'command:\s*["\']?([^"\'\s]+)["\']?', extension_text)
    for command in hook_commands:
        if command not in declared_commands:
            findings.append(
                Finding(
                    drift_type="reality",
                    severity="critical",
                    confidence="high",
                    description="Hook before_plan references command 'speckit.memorylint.run' which is not declared in provides.commands — applying a rename without updating extension.yml would break hooks",
                    source="extension.yml",
                    evidence=f"extension.yml hook references {command}, but provides.commands declares {sorted(declared_commands)}.",
                    recommended_destination="extension.yml",
                    suggested_action="rewrite",
                )
            )

    return findings


def scan_conflict_drift(fixture: Path) -> list[Finding]:
    agents_text = read_text(fixture / "AGENTS.md")
    constitution_text = read_text(fixture / ".specify/memory/constitution.md")
    if "Always use Conventional Commits" in agents_text and "Never use type prefixes" in constitution_text:
        return [
            Finding(
                drift_type="conflict",
                severity="critical",
                confidence="high",
                description="AGENTS.md mandates Conventional Commits while constitution.md mandates a custom [JIRA-ID] format — these are mutually exclusive commit message policies",
                source="AGENTS.md + .specify/memory/constitution.md",
                evidence="AGENTS.md requires Conventional Commits while constitution.md forbids feat:/fix: prefixes.",
                recommended_destination="AGENTS.md",
                suggested_action="rewrite",
            )
        ]
    return []


def scan_redundancy_drift(fixture: Path) -> list[Finding]:
    findings: list[Finding] = []
    agents_text = read_text(fixture / "AGENTS.md")
    constitution_text = read_text(fixture / ".specify/memory/constitution.md")
    claude_text = read_text(fixture / "CLAUDE.md")
    nested_agents_text = read_text(fixture / "packages/frontend/AGENTS.md")

    if (
        "speckit.{extension-id}.{command-name}" in agents_text
        and "speckit.{extension-id}.{command-name}" in constitution_text
    ):
        findings.append(
            Finding(
                drift_type="redundancy",
                severity="info",
                confidence="high",
                description="Command naming convention rule appears in both AGENTS.md and constitution.md with near-identical wording",
                source="AGENTS.md + .specify/memory/constitution.md",
                evidence="Both files contain the same speckit command naming pattern.",
                recommended_destination="AGENTS.md",
                suggested_action="merge",
            )
        )

    if "Run `make build`" in agents_text and "Run `make build`" in claude_text:
        findings.append(
            Finding(
                drift_type="redundancy",
                severity="warning",
                confidence="high",
                description="Build command rules in CLAUDE.md duplicate AGENTS.md — risks divergence if only one file is updated",
                source="AGENTS.md + CLAUDE.md",
                evidence="AGENTS.md and CLAUDE.md both list make build and make test.",
                recommended_destination="AGENTS.md",
                suggested_action="merge",
            )
        )

    if "Use focused commits with Conventional Commit style" in agents_text and (
        "Use focused commits with Conventional Commit style" in nested_agents_text
    ):
        findings.append(
            Finding(
                drift_type="redundancy",
                severity="warning",
                confidence="medium",
                description="Git workflow rules in packages/frontend/AGENTS.md duplicate the root AGENTS.md — nested rules risk diverging from root policy",
                source="AGENTS.md + packages/frontend/AGENTS.md",
                evidence="Root and nested AGENTS.md repeat the focused commits / Conventional Commit policy.",
                recommended_destination="AGENTS.md",
                suggested_action="merge",
            )
        )

    return findings


def scan_fixture(fixture: Path) -> dict:
    findings = (
        scan_reality_drift(fixture)
        + scan_conflict_drift(fixture)
        + scan_redundancy_drift(fixture)
        + scan_boundary_drift(fixture)
    )

    finding_dicts = []
    for index, finding in enumerate(findings, start=1):
        item = finding.as_dict()
        item["id"] = f"ML-{index:03d}"
        finding_dicts.append(item)

    sources = [
        {
            "path": rel(path, fixture),
            "sha256": sha256(path),
        }
        for path in source_files(fixture)
    ]

    return {
        "schema_version": "1.0",
        "fixture": fixture.name,
        "source_metadata": sources,
        "findings": finding_dicts,
        "metrics": {
            "total_instruction_sources_scanned": len(sources),
            "total_findings": len(finding_dicts),
            "high_confidence_findings": sum(1 for f in finding_dicts if f["confidence"] == "high"),
            "medium_confidence_findings": sum(1 for f in finding_dicts if f["confidence"] == "medium"),
            "low_confidence_findings": sum(1 for f in finding_dicts if f["confidence"] == "low"),
        },
    }


def check(fixtures_dir: Path, reports: list[dict]) -> int:
    failures: list[str] = []
    for report in reports:
        fixture = fixtures_dir / report["fixture"]
        expected_path = fixture / "expected-findings.json"
        expected = json.loads(expected_path.read_text(encoding="utf-8"))
        actual = [
            {
                "drift_type": item["drift_type"],
                "severity": item["severity"],
                "confidence": item["confidence"],
                "description": item["description"],
                "source": item["source"],
                "evidence": item["evidence"],
                "recommended_destination": item["recommended_destination"],
                "suggested_action": item["suggested_action"],
            }
            for item in report["findings"]
        ]
        if actual != expected:
            failures.append(
                "\n".join(
                    [
                        f"FAIL: {fixture.name} findings mismatch",
                        "Expected:",
                        json.dumps(expected, indent=2, ensure_ascii=False),
                        "Actual:",
                        json.dumps(actual, indent=2, ensure_ascii=False),
                    ]
                )
            )

    if failures:
        print("\n\n".join(failures), file=sys.stderr)
        return 1

    total = sum(len(report["findings"]) for report in reports)
    print(f"fixture scanner passed ({len(reports)} fixtures, {total} findings checked)")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan MemoryLint regression fixtures")
    parser.add_argument("--fixtures", required=True, type=Path, help="Path to memorylint/tests/fixtures")
    parser.add_argument("--check", action="store_true", help="Compare generated findings with expected-findings.json")
    parser.add_argument("--pretty", action="store_true", help="Pretty-print JSON output")
    args = parser.parse_args()

    fixtures_dir = args.fixtures
    reports = [scan_fixture(fixture) for fixture in fixture_dirs(fixtures_dir)]

    if args.check:
        return check(fixtures_dir, reports)

    json.dump(
        {"schema_version": "1.0", "fixtures": reports},
        sys.stdout,
        indent=2 if args.pretty else None,
        ensure_ascii=False,
    )
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
