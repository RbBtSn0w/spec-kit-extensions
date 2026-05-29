#!/usr/bin/env python3
"""Shared MemoryLint audit/apply primitives."""

from __future__ import annotations

import copy
import hashlib
import json
import re
import shlex
import subprocess
from collections import defaultdict
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Iterable


MARKDOWN_EXTENSIONS = {".md", ".markdown", ".txt"}
EDITOR_RULE_DIR = (".cursor", "rules")
CRITICAL_AGENTS_SECTION_FAMILIES = (
    ("build", "validation"),
    ("git workflow", "workflow", "hygiene"),
    ("release", "workflow rules"),
)
MEMORYLINT_EXPECTED_HOOKS = {
    "before_constitution": "speckit.memorylint.audit",
    "after_constitution": "speckit.memorylint.audit",
    "before_plan": "speckit.memorylint.load-agents",
}
CANONICAL_OWNER_MATRIX = {
    "architecture": ".specify/memory/constitution.md",
    "domain": ".specify/memory/constitution.md",
    "infrastructure": "AGENTS.md",
    "workflow": "AGENTS.md",
    "tooling": "AGENTS.md",
    "personal_preference": "AGENTS.md",
}


@dataclass(frozen=True)
class Rule:
    rule_id: str
    source: str
    line_range: str
    heading: str
    text: str
    summary: str
    category: str
    status: str = "ok"


@dataclass(frozen=True)
class Edit:
    path: str
    action: str
    start_line: int
    end_line: int
    replacement: list[str] = field(default_factory=list)
    reason: str = ""


@dataclass
class Finding:
    id: str
    drift_type: str
    severity: str
    confidence: str
    source: str
    evidence: str
    recommended_destination: str
    suggested_action: str
    detail: str
    rule_ids: list[str] = field(default_factory=list)
    category: str | None = None
    edits: list[Edit] = field(default_factory=list)
    manual_handoff: dict[str, object] | None = None

    def to_dict(self) -> dict[str, object]:
        payload = {
            "id": self.id,
            "drift_type": self.drift_type,
            "severity": self.severity,
            "confidence": self.confidence,
            "source": self.source,
            "evidence": self.evidence,
            "recommended_destination": self.recommended_destination,
            "suggested_action": self.suggested_action,
            "detail": self.detail,
        }
        if self.rule_ids:
            payload["rule_ids"] = self.rule_ids
        if self.category:
            payload["category"] = self.category
        if self.edits:
            payload["edits"] = [asdict(edit) for edit in self.edits]
        if self.manual_handoff:
            payload["manual_handoff"] = self.manual_handoff
        return payload


@dataclass
class AuditReport:
    schema_version: str
    workspace_root: str
    source_metadata: list[dict[str, str]]
    instruction_map: list[dict[str, str]]
    findings: list[dict[str, object]]
    metrics: dict[str, object]
    summary: dict[str, dict[str, int]]

    def to_dict(self) -> dict[str, object]:
        return {
            "schema_version": self.schema_version,
            "workspace_root": self.workspace_root,
            "source_metadata": self.source_metadata,
            "instruction_map": self.instruction_map,
            "findings": self.findings,
            "metrics": self.metrics,
            "summary": self.summary,
        }


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def resolve_workspace_path(workspace_root: Path, relative: str, *, base_path: Path | None = None) -> Path:
    candidate_root = base_path if base_path is not None else workspace_root
    candidate = (candidate_root / relative).resolve()
    try:
        candidate.relative_to(workspace_root)
    except ValueError as exc:
        raise ValueError(f"Path escapes workspace: {relative}") from exc
    return candidate


def relative_path(path: Path, workspace_root: Path) -> str:
    return path.relative_to(workspace_root).as_posix()


def normalize_whitespace(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip())


def normalize_rule_text(text: str) -> str:
    text = text.strip()
    text = re.sub(r"`([^`]+)`", r"\1", text)
    text = re.sub(r"\[[^\]]+\]\([^)]+\)", "", text)
    text = re.sub(r"[“”\"'`]", "", text)
    text = re.sub(r"[^a-zA-Z0-9{}./:+\-\s]", " ", text)
    return normalize_whitespace(text).lower()


def path_kind(path: Path) -> str:
    parts = path.parts
    posix = path.as_posix()
    if path.name == "AGENTS.md":
        return "agents"
    if posix.endswith(".specify/memory/constitution.md"):
        return "constitution"
    if path.name == "CLAUDE.md":
        return "claude"
    if EDITOR_RULE_DIR[0] in parts and EDITOR_RULE_DIR[1] in parts:
        return "cursor"
    if path.name == "README.md":
        return "readme"
    if ".github" in parts and "workflows" in parts:
        return "workflow"
    if path.name == "extension.yml":
        return "manifest"
    if "tests" in parts:
        return "test"
    return "other"


def discover_sources(workspace_root: Path) -> list[Path]:
    patterns = [
        "AGENTS.md",
        "**/AGENTS.md",
        ".specify/memory/constitution.md",
        "**/.specify/memory/constitution.md",
        "CLAUDE.md",
        "**/CLAUDE.md",
        ".cursor/rules/*",
        "**/.cursor/rules/*",
        "README.md",
        "*/README.md",
        "**/README.md",
        ".github/workflows/*.yml",
        "**/.github/workflows/*.yml",
        "tests/*",
        "**/tests/*",
        "extension.yml",
        "**/extension.yml",
    ]

    discovered: set[Path] = set()
    for pattern in patterns:
        for candidate in workspace_root.glob(pattern):
            if not candidate.is_file():
                continue
            if ".git" in candidate.parts:
                continue
            discovered.add(candidate)
    return sorted(discovered)


def markdown_rules(path: Path, workspace_root: Path, next_rule_id: int) -> tuple[list[Rule], int]:
    rules: list[Rule] = []
    current_heading = ""
    for line_number, line in enumerate(read_text(path).splitlines(), start=1):
        heading_match = re.match(r"^\s{0,3}#{1,6}\s+(.+?)\s*$", line)
        if heading_match:
            current_heading = heading_match.group(1).strip()
            continue
        bullet_match = re.match(r"^\s*(?:[-*]|\d+\.)\s+(.+?)\s*$", line)
        if not bullet_match:
            continue
        text = bullet_match.group(1).strip()
        if not text:
            continue
        rule_id = f"R-{next_rule_id:03d}"
        next_rule_id += 1
        summary = text
        category = classify_rule(summary, path_kind(path), current_heading)
        rules.append(
            Rule(
                rule_id=rule_id,
                source=relative_path(path, workspace_root),
                line_range=str(line_number),
                heading=current_heading,
                text=text,
                summary=summary,
                category=category,
            )
        )
    return rules, next_rule_id


def parse_extension_commands(text: str) -> set[str]:
    commands: set[str] = set()
    in_commands = False
    for line in text.splitlines():
        if re.match(r"^\s*commands:\s*$", line):
            in_commands = True
            continue
        if in_commands and re.match(r"^\s*[a-z_]+:\s*$", line):
            break
        if in_commands:
            command_value = parse_declared_command_value(line)
            if command_value:
                commands.add(command_value)
    return commands


def parse_declared_command_value(line: str) -> str | None:
    match = re.match(r"^\s*-\s+name:\s*(.+?)\s*$", line)
    if not match:
        return None
    value = match.group(1).strip()
    if value.startswith('"'):
        quoted = re.match(r'^"([^"]+)"(?:\s+#.*)?$', value)
        return quoted.group(1) if quoted else None
    if value.startswith("'"):
        quoted = re.match(r"^'([^']+)'(?:\s+#.*)?$", value)
        return quoted.group(1) if quoted else None
    return re.sub(r"\s+#.*$", "", value).strip() or None


def parse_extension_hooks(text: str) -> dict[str, str]:
    hooks: dict[str, str] = {}
    hook_match = re.search(r"^\s*hooks:\s*$", text, re.MULTILINE)
    if not hook_match:
        return hooks

    current_hook: str | None = None
    for line in text.splitlines():
        hook_name_match = re.match(r"^\s{2}([a-z_]+):\s*$", line)
        if hook_name_match:
            current_hook = hook_name_match.group(1)
            continue
        command_value = parse_hook_command_value(line)
        if current_hook and command_value:
            hooks[current_hook] = command_value
    return hooks


def parse_hook_command_value(line: str) -> str | None:
    match = re.match(r"^\s{4}command:\s*(.+?)\s*$", line)
    if not match:
        return None
    value = match.group(1).strip()
    if value.startswith('"'):
        quoted = re.match(r'^"([^"]+)"(?:\s+#.*)?$', value)
        return quoted.group(1) if quoted else None
    if value.startswith("'"):
        quoted = re.match(r"^'([^']+)'(?:\s+#.*)?$", value)
        return quoted.group(1) if quoted else None
    return re.sub(r"\s+#.*$", "", value).strip() or None


def find_hook_command_line(text: str, hook_name: str) -> int | None:
    current_hook: str | None = None
    for index, line in enumerate(text.splitlines(), start=1):
        hook_name_match = re.match(r"^\s{2}([a-z_]+):\s*$", line)
        if hook_name_match:
            current_hook = hook_name_match.group(1)
            continue
        if current_hook != hook_name:
            continue
        if parse_hook_command_value(line):
            return index
    return None


def rewrite_hook_command_line(line: str, replacement: str) -> str:
    prefix_match = re.match(r"^(\s*command:\s*)(.+?)\s*$", line)
    if not prefix_match:
        return line

    original_value = prefix_match.group(2).strip()
    if original_value.startswith('"'):
        comment_match = re.match(r'^"[^"]+"(\s+#.*)?$', original_value)
    elif original_value.startswith("'"):
        comment_match = re.match(r"^'[^']+'(\s+#.*)?$", original_value)
    else:
        comment_match = re.match(r"^[^#\n]+?(\s+#.*)?$", original_value)
    comment = comment_match.group(1) if comment_match and comment_match.group(1) else ""
    return f'{prefix_match.group(1)}"{replacement}"{comment}'


def manifest_rules(path: Path, workspace_root: Path, next_rule_id: int) -> tuple[list[Rule], int]:
    text = read_text(path)
    rules: list[Rule] = []

    extension_id_match = re.search(r'^\s*id:\s*["\']?([^"\']+)["\']?\s*$', text, re.MULTILINE)
    extension_id = extension_id_match.group(1) if extension_id_match else ""

    for hook_name, command_name in parse_extension_hooks(text).items():
        line_number = find_hook_command_line(text, hook_name) or 1
        rule_id = f"R-{next_rule_id:03d}"
        next_rule_id += 1
        summary = f"Hook {hook_name} uses command {command_name}"
        category = "domain" if extension_id else "infrastructure"
        rules.append(
            Rule(
                rule_id=rule_id,
                source=relative_path(path, workspace_root),
                line_range=str(line_number),
                heading="hooks",
                text=summary,
                summary=summary,
                category=category,
            )
        )
    return rules, next_rule_id


def extract_rules(workspace_root: Path, sources: list[Path]) -> list[Rule]:
    rules: list[Rule] = []
    next_rule_id = 1
    for path in sources:
        kind = path_kind(path)
        if path.suffix in MARKDOWN_EXTENSIONS or kind in {"agents", "constitution", "claude", "cursor", "readme"}:
            extracted, next_rule_id = markdown_rules(path, workspace_root, next_rule_id)
            rules.extend(extracted)
            continue
        if kind == "manifest":
            extracted, next_rule_id = manifest_rules(path, workspace_root, next_rule_id)
            rules.extend(extracted)
    return rules


def classify_rule(summary: str, source_kind: str, heading: str) -> str:
    normalized = normalize_rule_text(f"{heading} {summary}")
    if any(
        keyword in normalized
        for keyword in (
            "architecture",
            "hexagonal",
            "mvc",
            "redux",
            "module",
            "boundary",
            "repository pattern",
            "rest principles",
            "json:api",
            "composition over inheritance",
            "jsdoc",
            "command pattern",
            "business logic",
            "type annotations",
            "type annotation",
            "error handling",
        )
    ):
        return "architecture"
    if any(keyword in normalized for keyword in ("prefer", "terse", "concise", "style choice", "single quotes", "functional components")):
        return "personal_preference"
    if any(keyword in normalized for keyword in ("conventional commit", "force-push", "force push", "review approval", "git workflow", "pull request", "prs require")):
        return "workflow"
    if any(keyword in normalized for keyword in ("ci", "build", "test", "lint", "release", "deploy", "workflow", "tag", "package", "validation")):
        return "infrastructure"
    if any(keyword in normalized for keyword in ("speckit.", "constitution", "command naming", "extension", "hook", "command names must follow")):
        return "domain"
    if any(keyword in normalized for keyword in ("python", "ruby", "nvm", "pyenv", "rbenv", "cursor", "claude", "editor", "tool")):
        return "tooling"
    if source_kind == "manifest":
        return "domain"
    return "infrastructure"


def canonical_destination(rule: Rule) -> str | None:
    return CANONICAL_OWNER_MATRIX.get(rule.category)


def source_metadata(workspace_root: Path, sources: list[Path]) -> list[dict[str, str]]:
    return [
        {
            "path": relative_path(path, workspace_root),
            "sha256": sha256(path),
        }
        for path in sources
    ]


def missing_constitution_finding(workspace_root: Path, rules: list[Rule]) -> Finding | None:
    constitution_path = workspace_root / ".specify/memory/constitution.md"
    if constitution_path.exists():
        return None
    architecture_like = [rule for rule in rules if rule.category in {"architecture", "domain"}]
    if not architecture_like:
        return None
    return Finding(
        id="",
        drift_type="reality",
        severity="info",
        confidence="medium",
        source=".specify/memory/constitution.md",
        evidence="The workspace does not contain .specify/memory/constitution.md, so architecture/domain rules do not have their canonical home.",
        recommended_destination=".specify/memory/constitution.md",
        suggested_action="keep",
        detail="The canonical constitution file is missing. Create or restore it before consolidating architecture/domain rules.",
        category="architecture",
    )


def make_boundary_findings(workspace_root: Path, rules: list[Rule]) -> list[Finding]:
    findings: list[Finding] = []
    for rule in rules:
        destination = canonical_destination(rule)
        if not destination:
            continue
        source_kind_name = path_kind(Path(rule.source))
        if destination == ".specify/memory/constitution.md":
            allowed = source_kind_name == "constitution"
        elif destination == "AGENTS.md":
            allowed = source_kind_name in {"agents", "claude", "cursor"}
        else:
            allowed = False
        if allowed:
            continue
        if source_kind_name in {"readme", "manifest", "workflow", "test"}:
            continue
        if source_kind_name in {"claude", "cursor"} and rule.category in {"infrastructure", "workflow", "tooling", "personal_preference"}:
            continue
        if source_kind_name == "agents" and "/" in rule.source and rule.category in {"infrastructure", "workflow", "tooling", "personal_preference"}:
            continue
        detail = f"Rule '{rule.summary}' belongs in {destination}, not in {rule.source}."
        handoff = None
        edits: list[Edit] = []
        if destination == ".specify/memory/constitution.md":
            handoff = {
                "target_path": destination,
                "target_section": rule.heading or "Imported rules",
                "rule_text": rule.text,
                "merge_rationale": "Move architecture/domain guidance into the canonical constitution without auto-rewriting the constitution.",
                "requires_human_review": True,
            }
            edits.append(
                Edit(
                    path=rule.source,
                    action="delete",
                    start_line=int(rule.line_range.split("-")[0]),
                    end_line=int(rule.line_range.split("-")[-1]),
                    reason="Remove misplaced rule from non-canonical source after manual constitution handoff.",
                )
            )
        findings.append(
            Finding(
                id="",
                drift_type="boundary",
                severity="warning",
                confidence="high",
                source=f"{rule.source}:{rule.line_range}",
                evidence=f"{rule.source} contains a {rule.category} rule under heading '{rule.heading or 'Unsectioned'}'.",
                recommended_destination=destination,
                suggested_action="move",
                detail=detail,
                rule_ids=[rule.rule_id],
                category=rule.category,
                edits=edits,
                manual_handoff=handoff,
            )
        )
    return findings


def find_line_number(text: str, snippet: str) -> int | None:
    for index, line in enumerate(text.splitlines(), start=1):
        if snippet in line:
            return index
    return None


def detect_path_references(rule: Rule) -> Iterable[str]:
    def looks_like_path_reference(value: str) -> bool:
        return value.startswith(("scripts/", "bin/", "tools/", "./", "../")) or value.endswith((".sh", ".py", ".rb", ".js", ".ts"))

    for match in re.findall(r"`([^`]+)`", rule.text):
        if "://" in match or "{" in match:
            continue
        normalized = match.strip().rstrip(".,;:")
        if " " not in normalized and looks_like_path_reference(normalized):
            yield normalized
            continue
        try:
            tokens = shlex.split(match)
        except ValueError:
            tokens = match.split()
        for token in tokens[1:] if len(tokens) > 1 else tokens:
            normalized_token = token.strip().rstrip(".,;:")
            if looks_like_path_reference(normalized_token):
                yield normalized_token
                break


def detect_reality_findings(workspace_root: Path, rules: list[Rule]) -> list[Finding]:
    findings: list[Finding] = []
    seen_sources: set[tuple[str, str]] = set()

    def needs_manual_stale_path_rewrite(rule_text: str, reference: str) -> bool:
        lowered = rule_text.lower()
        stripped = lowered.replace(f"`{reference.lower()}`", "")
        return any(token in stripped for token in (",", ";", " and ", " then ", " while "))

    for rule in rules:
        rule_path = workspace_root / rule.source
        rule_text_normalized = normalize_rule_text(rule.text)
        line_number = int(rule.line_range.split("-")[0])

        for reference in detect_path_references(rule):
            key = (rule.source, reference)
            try:
                candidate = resolve_workspace_path(workspace_root, reference, base_path=rule_path.parent)
            except ValueError:
                if key in seen_sources:
                    continue
                seen_sources.add(key)
                findings.append(
                    Finding(
                        id="",
                        drift_type="reality",
                        severity="warning",
                        confidence="high",
                        source=f"{rule.source}:{rule.line_range}",
                        evidence=f"{rule.source} references `{reference}` but that path escapes the workspace boundary.",
                        recommended_destination="N/A",
                        suggested_action="delete",
                        detail=f"Remove or replace the out-of-workspace reference `{reference}`.",
                        rule_ids=[rule.rule_id],
                        category=rule.category,
                        edits=[
                            Edit(
                                path=rule.source,
                                action="delete",
                                start_line=line_number,
                                end_line=line_number,
                                reason=f"Delete out-of-workspace reference {reference}.",
                            )
                        ],
                    )
                )
                continue
            if not candidate.exists():
                if key in seen_sources:
                    continue
                seen_sources.add(key)
                manual_rewrite = needs_manual_stale_path_rewrite(rule.text, reference)
                findings.append(
                    Finding(
                        id="",
                        drift_type="reality",
                        severity="warning",
                        confidence="high",
                        source=f"{rule.source}:{rule.line_range}",
                        evidence=f"{rule.source} references `{reference}` but that path does not exist in the workspace.",
                        recommended_destination="N/A",
                        suggested_action="rewrite" if manual_rewrite else "delete",
                        detail=(
                            f"Rewrite the mixed-content rule in {rule.source} to remove the stale reference `{reference}` without dropping the remaining guidance."
                            if manual_rewrite
                            else f"Remove or replace the stale reference to `{reference}`."
                        ),
                        rule_ids=[rule.rule_id],
                        category=rule.category,
                        edits=[] if manual_rewrite else [
                            Edit(
                                path=rule.source,
                                action="delete",
                                start_line=line_number,
                                end_line=line_number,
                                reason=f"Delete stale reference to missing path {reference}.",
                            )
                        ],
                    )
                )

        npm_match = re.search(r"npm run ([a-zA-Z0-9:_-]+)", rule.text)
        if npm_match:
            script_name = npm_match.group(1)
            package_json = nearest_package_json(rule_path, workspace_root)
            package_data: dict[str, object] = {}
            if package_json and package_json.exists():
                try:
                    loaded = json.loads(package_json.read_text(encoding="utf-8"))
                except json.JSONDecodeError:
                    manifest_reference = relative_path(package_json, workspace_root)
                    key = (rule.source, manifest_reference)
                    if key in seen_sources:
                        continue
                    seen_sources.add(key)
                    findings.append(
                        Finding(
                            id="",
                            drift_type="reality",
                            severity="warning",
                            confidence="high",
                            source=f"{rule.source}:{rule.line_range}",
                            evidence=f"{rule.source} references `npm run {script_name}`, but `{manifest_reference}` is not valid JSON.",
                            recommended_destination=manifest_reference,
                            suggested_action="rewrite",
                            detail=f"Fix `{manifest_reference}` so MemoryLint can verify the `{script_name}` script.",
                            rule_ids=[rule.rule_id],
                            category=rule.category,
                        )
                    )
                    continue
                if isinstance(loaded, dict):
                    package_data = loaded
            scripts = package_data.get("scripts", {}) if isinstance(package_data, dict) else {}
            if script_name not in scripts:
                findings.append(
                    Finding(
                        id="",
                        drift_type="reality",
                        severity="warning",
                        confidence="high",
                        source=f"{rule.source}:{rule.line_range}",
                        evidence=f"{rule.source} references `npm run {script_name}` but the workspace has no package.json script named `{script_name}`.",
                        recommended_destination="N/A",
                        suggested_action="delete",
                        detail=f"Remove or update the stale npm script reference `{script_name}`.",
                        rule_ids=[rule.rule_id],
                        category=rule.category,
                        edits=[
                            Edit(
                                path=rule.source,
                                action="delete",
                                start_line=line_number,
                                end_line=line_number,
                                reason=f"Delete stale npm script reference {script_name}.",
                            )
                        ],
                    )
                )

        if "speckit.memorylint.run" in rule_text_normalized and path_kind(rule_path) != "manifest":
            replacement = "speckit.memorylint.load-agents" if "planning phase" in rule_text_normalized or "before plan" in rule_text_normalized else "speckit.memorylint.audit"
            findings.append(
                Finding(
                    id="",
                    drift_type="reality",
                    severity="warning",
                    confidence="high",
                    source=f"{rule.source}:{rule.line_range}",
                    evidence=f"{rule.source} still references removed command `speckit.memorylint.run`.",
                    recommended_destination=rule.source,
                    suggested_action="rewrite",
                    detail=f"Rewrite the stale command reference to `{replacement}`.",
                    rule_ids=[rule.rule_id],
                    category=rule.category,
                    edits=[
                        Edit(
                            path=rule.source,
                            action="replace",
                            start_line=line_number,
                            end_line=line_number,
                            replacement=[read_text(rule_path).splitlines()[line_number - 1].replace("speckit.memorylint.run", replacement)],
                            reason=f"Replace removed command name with {replacement}.",
                        )
                    ],
                )
            )

    scanned_manifests: set[str] = set()
    for manifest in [rule for rule in rules if path_kind(Path(rule.source)) == "manifest"]:
        if manifest.source in scanned_manifests:
            continue
        scanned_manifests.add(manifest.source)
        manifest_path = workspace_root / manifest.source
        manifest_text = read_text(manifest_path)
        extension_id_match = re.search(r'^\s*id:\s*["\']?([^"\']+)["\']?\s*$', manifest_text, re.MULTILINE)
        extension_id = extension_id_match.group(1) if extension_id_match else ""
        declared = parse_extension_commands(manifest_text)
        for hook_name, command_name in parse_extension_hooks(manifest_text).items():
            if command_name in declared:
                continue
            replacement = MEMORYLINT_EXPECTED_HOOKS.get(hook_name, command_name) if extension_id == "memorylint" else command_name
            line_number = find_hook_command_line(manifest_text, hook_name) or 1
            edits: list[Edit] = []
            detail = f"Rewrite hook `{hook_name}` to use a declared command."
            if replacement != command_name:
                edits = [
                    Edit(
                        path=manifest.source,
                        action="replace",
                        start_line=line_number,
                        end_line=line_number,
                        replacement=[rewrite_hook_command_line(manifest_text.splitlines()[line_number - 1], replacement)],
                        reason=f"Rewrite hook {hook_name} to the declared command {replacement}.",
                    )
                ]
            else:
                detail = f"Declare `{command_name}` under provides.commands or replace hook `{hook_name}` with a declared command."
            findings.append(
                Finding(
                    id="",
                    drift_type="reality",
                    severity="critical",
                    confidence="high",
                    source=f"{manifest.source}:{line_number}",
                    evidence=f"{manifest.source} hook `{hook_name}` references `{command_name}`, but provides.commands declares {sorted(declared)}.",
                    recommended_destination=manifest.source,
                    suggested_action="rewrite",
                    detail=detail,
                    rule_ids=[manifest.rule_id],
                    category="domain",
                    edits=edits,
                )
            )

    missing_constitution = missing_constitution_finding(workspace_root, rules)
    if missing_constitution:
        findings.append(missing_constitution)
    return findings


def nearest_package_json(rule_path: Path, workspace_root: Path) -> Path | None:
    for candidate_dir in [rule_path.parent, *rule_path.parents]:
        if candidate_dir == workspace_root.parent:
            break
        package_json = candidate_dir / "package.json"
        if package_json.exists():
            return package_json
        if candidate_dir == workspace_root:
            break
    return None


def commit_policy_signature(rule: Rule) -> str | None:
    normalized = normalize_rule_text(rule.text)
    if "conventional commit" in normalized:
        return "conventional-commits"
    if "[jira-id]" in normalized or "never use type prefixes" in normalized:
        return "jira-commits"
    return None


def detect_conflicts(rules: list[Rule]) -> list[Finding]:
    findings: list[Finding] = []
    grouped: defaultdict[str, list[Rule]] = defaultdict(list)
    for rule in rules:
        signature = commit_policy_signature(rule)
        if signature:
            grouped[signature].append(rule)

    if grouped["conventional-commits"] and grouped["jira-commits"]:
        lhs = grouped["conventional-commits"][0]
        rhs = grouped["jira-commits"][0]
        findings.append(
            Finding(
                id="",
                drift_type="conflict",
                severity="critical",
                confidence="high",
                source=f"{lhs.source}:{lhs.line_range} + {rhs.source}:{rhs.line_range}",
                evidence=f"{lhs.source} requires Conventional Commits while {rhs.source} forbids type prefixes and requires a JIRA format.",
                recommended_destination="AGENTS.md",
                suggested_action="rewrite",
                detail="The commit message policies are mutually exclusive and must be reconciled in one canonical source.",
                rule_ids=[lhs.rule_id, rhs.rule_id],
                category="workflow",
            )
        )
    return findings


def redundancy_signature(rule: Rule) -> str | None:
    normalized = normalize_rule_text(rule.text)
    if "speckit.{extension-id}.{command-name}" in normalized:
        return "command-naming-pattern"
    if "make build" in normalized:
        return "make-build"
    if "make test" in normalized:
        return "make-test"
    if "use focused commits" in normalized:
        return "focused-commits"
    if "do not force-push to main" in normalized or "do not force push to main" in normalized:
        return "no-force-push-main"
    return None


def root_agents_rule(rules: list[Rule], signature: str) -> Rule | None:
    for rule in rules:
        if rule.source == "AGENTS.md" and redundancy_signature(rule) == signature:
            return rule
    return None


def detect_redundancies(rules: list[Rule]) -> list[Finding]:
    findings: list[Finding] = []
    by_signature: defaultdict[str, list[Rule]] = defaultdict(list)
    for rule in rules:
        signature = redundancy_signature(rule)
        if signature:
            by_signature[signature].append(rule)

    command_rules = by_signature.get("command-naming-pattern", [])
    root_command = root_agents_rule(command_rules, "command-naming-pattern")
    constitution_command = next((rule for rule in command_rules if path_kind(Path(rule.source)) == "constitution"), None)
    if root_command and constitution_command:
        findings.append(
            Finding(
                id="",
                drift_type="redundancy",
                severity="info",
                confidence="high",
                source=f"{root_command.source}:{root_command.line_range} + {constitution_command.source}:{constitution_command.line_range}",
                evidence="Both sources contain the same speckit command naming pattern.",
                recommended_destination=".specify/memory/constitution.md",
                suggested_action="merge",
                detail="Keep one canonical copy of the command naming rule to avoid future divergence.",
                rule_ids=[root_command.rule_id, constitution_command.rule_id],
                category="domain",
                edits=[
                    Edit(
                        path=root_command.source,
                        action="delete",
                        start_line=int(root_command.line_range),
                        end_line=int(root_command.line_range),
                        reason="Remove duplicate rule from non-canonical source.",
                    )
                ],
            )
        )

    root_build = root_agents_rule(rules, "make-build")
    root_test = root_agents_rule(rules, "make-test")
    claude_build = next((rule for rule in by_signature.get("make-build", []) if path_kind(Path(rule.source)) == "claude"), None)
    claude_test = next((rule for rule in by_signature.get("make-test", []) if path_kind(Path(rule.source)) == "claude"), None)
    if root_build and root_test and claude_build and claude_test:
        findings.append(
            Finding(
                id="",
                drift_type="redundancy",
                severity="warning",
                confidence="high",
                source=f"{root_build.source}:{root_build.line_range} + {claude_build.source}:{claude_build.line_range}",
                evidence="AGENTS.md and CLAUDE.md both list make build and make test.",
                recommended_destination="AGENTS.md",
                suggested_action="merge",
                detail="Build command rules are duplicated across AGENTS.md and CLAUDE.md, risking divergence.",
                rule_ids=[root_build.rule_id, root_test.rule_id, claude_build.rule_id, claude_test.rule_id],
                category="infrastructure",
                edits=[
                    Edit(
                        path=claude_build.source,
                        action="delete",
                        start_line=int(claude_build.line_range),
                        end_line=int(claude_test.line_range),
                        reason="Remove duplicate build/test rules from secondary source.",
                    )
                ],
            )
        )

    root_focused = root_agents_rule(rules, "focused-commits")
    nested_focused = next(
        (
            rule
            for rule in by_signature.get("focused-commits", [])
            if path_kind(Path(rule.source)) == "agents" and rule.source != "AGENTS.md"
        ),
        None,
    )
    if root_focused and nested_focused:
        findings.append(
            Finding(
                id="",
                drift_type="redundancy",
                severity="warning",
                confidence="medium",
                source=f"{root_focused.source}:{root_focused.line_range} + {nested_focused.source}:{nested_focused.line_range}",
                evidence="Root and nested AGENTS.md repeat the focused commits policy.",
                recommended_destination="AGENTS.md",
                suggested_action="merge",
                detail="Nested workflow rules duplicate the root policy and risk divergence.",
                rule_ids=[root_focused.rule_id, nested_focused.rule_id],
                category="workflow",
                edits=[
                    Edit(
                        path=nested_focused.source,
                        action="delete",
                        start_line=int(nested_focused.line_range),
                        end_line=int(nested_focused.line_range),
                        reason="Remove duplicate workflow rule from nested AGENTS.md.",
                    )
                ],
            )
        )
    return findings


def assign_finding_ids(findings: list[Finding]) -> list[Finding]:
    assigned: list[Finding] = []
    for index, finding in enumerate(findings, start=1):
        finding.id = f"ML-{index:03d}"
        assigned.append(finding)
    return assigned


def apply_instruction_status(rules: list[Rule], findings: list[Finding]) -> list[dict[str, str]]:
    rule_status: dict[str, str] = {rule.rule_id: "ok" for rule in rules}
    for finding in findings:
        status = {
            "boundary": "boundary_drift",
            "reality": "reality_drift",
            "conflict": "conflict",
            "redundancy": "redundant",
        }.get(finding.drift_type, "ok")
        for rule_id in finding.rule_ids:
            rule_status[rule_id] = status

    return [
        {
            "rule_id": rule.rule_id,
            "source": rule.source,
            "line_range": rule.line_range,
            "summary": rule.summary,
            "category": rule.category,
            "status": rule_status[rule.rule_id],
        }
        for rule in rules
    ]


def summarize_findings(findings: list[Finding]) -> dict[str, dict[str, int]]:
    summary: dict[str, dict[str, int]] = {
        drift: {"critical": 0, "warning": 0, "info": 0, "total": 0}
        for drift in ("boundary", "reality", "conflict", "redundancy")
    }
    summary["total"] = {"critical": 0, "warning": 0, "info": 0, "total": 0}
    for finding in findings:
        bucket = summary[finding.drift_type]
        bucket[finding.severity] += 1
        bucket["total"] += 1
        summary["total"][finding.severity] += 1
        summary["total"]["total"] += 1
    return summary


def metrics_from_findings(sources: list[Path], rules: list[Rule], findings: list[Finding]) -> dict[str, object]:
    files_that_would_be_modified = sorted(
        {
            edit.path
            for finding in findings
            for edit in finding.edits
            if edit.path and finding.suggested_action in {"delete", "merge", "rewrite", "move"}
        }
    )
    return {
        "total_instruction_sources_scanned": len(sources),
        "total_rules_catalogued": len(rules),
        "total_findings": len(findings),
        "high_confidence_findings": sum(1 for finding in findings if finding.confidence == "high"),
        "medium_confidence_findings": sum(1 for finding in findings if finding.confidence == "medium"),
        "low_confidence_findings": sum(1 for finding in findings if finding.confidence == "low"),
        "files_that_would_be_modified": files_that_would_be_modified,
    }


def generate_report(workspace_root: Path) -> AuditReport:
    sources = discover_sources(workspace_root)
    rules = extract_rules(workspace_root, sources)
    findings = assign_finding_ids(
        make_boundary_findings(workspace_root, rules)
        + detect_reality_findings(workspace_root, rules)
        + detect_conflicts(rules)
        + detect_redundancies(rules)
    )
    instruction_map = apply_instruction_status(rules, findings)
    summary = summarize_findings(findings)
    metrics = metrics_from_findings(sources, rules, findings)
    return AuditReport(
        schema_version="1.0",
        workspace_root=str(workspace_root),
        source_metadata=source_metadata(workspace_root, sources),
        instruction_map=instruction_map,
        findings=[finding.to_dict() for finding in findings],
        metrics=metrics,
        summary=summary,
    )


def markdown_report(report: AuditReport) -> str:
    payload = report.to_dict()
    lines: list[str] = [
        "## MemoryLint Drift Report",
        "",
        "### Instruction Map",
        "",
        "| rule_id | source | line_range | summary | category | status |",
        "|---------|--------|------------|---------|----------|--------|",
    ]
    for item in report.instruction_map:
        lines.append(
            f"| {item['rule_id']} | {item['source']} | {item['line_range']} | {item['summary']} | {item['category']} | {item['status']} |"
        )

    lines.extend(["", "### Findings", ""])
    if not report.findings:
        lines.append("No findings.")
    for finding in report.findings:
        lines.extend(
            [
                f"#### {finding['id']}",
                f"- **drift_type**: {finding['drift_type']}",
                f"- **severity**: {finding['severity']}",
                f"- **confidence**: {finding['confidence']}",
                f"- **source**: {finding['source']}",
                f"- **evidence**: {finding['evidence']}",
                f"- **recommended_destination**: {finding['recommended_destination']}",
                f"- **suggested_action**: {finding['suggested_action']}",
                f"- **detail**: {finding['detail']}",
            ]
        )
        if "manual_handoff" in finding:
            handoff = finding["manual_handoff"]
            lines.append(f"- **manual_handoff**: {json.dumps(handoff, ensure_ascii=False)}")
        lines.append("")

    lines.extend(
        [
            "### Summary",
            "",
            "| Drift Type | Critical | Warning | Info | Total |",
            "|------------|----------|---------|------|-------|",
        ]
    )
    for drift in ("boundary", "reality", "conflict", "redundancy", "total"):
        bucket = report.summary[drift]
        name = "**Total**" if drift == "total" else drift
        lines.append(
            f"| {name} | {bucket['critical']} | {bucket['warning']} | {bucket['info']} | {bucket['total']} |"
        )

    lines.extend(
        [
            "",
            "### Metrics",
            "",
            "| Metric | Value |",
            "|--------|-------|",
            f"| Total instruction sources scanned | {report.metrics['total_instruction_sources_scanned']} |",
            f"| Total rules catalogued | {report.metrics['total_rules_catalogued']} |",
            f"| Total findings | {report.metrics['total_findings']} |",
            f"| High-confidence findings | {report.metrics['high_confidence_findings']} |",
            f"| Medium-confidence findings | {report.metrics['medium_confidence_findings']} |",
            f"| Low-confidence findings | {report.metrics['low_confidence_findings']} |",
            f"| Files that would be modified by suggested actions | {', '.join(report.metrics['files_that_would_be_modified']) or 'None'} |",
            "",
            "### Source Metadata",
            "",
            "| File Path | Content Hash (SHA-256) |",
            "|-----------|------------------------|",
        ]
    )
    for item in report.source_metadata:
        lines.append(f"| {item['path']} | {item['sha256']} |")

    lines.extend(
        [
            "",
            "### Machine-Readable Report",
            "",
            "```memorylint-report.json",
            json.dumps(payload, indent=2, ensure_ascii=False),
            "```",
        ]
    )
    return "\n".join(lines) + "\n"


def extract_report_payload(text: str) -> dict[str, object]:
    stripped = text.strip()
    if stripped.startswith("{"):
        return json.loads(stripped)
    match = re.search(r"```memorylint-report\.json\n(.*?)\n```", text, re.DOTALL)
    if not match:
        raise ValueError("memorylint-report.json artifact not found")
    return json.loads(match.group(1))


def safe_mode_eligible(finding: dict[str, object]) -> bool:
    if finding["confidence"] != "high":
        return False
    if finding["severity"] not in {"info", "warning"}:
        return False
    if finding["suggested_action"] == "move":
        return False
    if finding.get("category") in {"architecture", "domain"} and finding["suggested_action"] != "rewrite":
        return False
    return bool(finding.get("edits"))


def approved_findings(report_payload: dict[str, object], mode: str, approved_ids: set[str] | None = None) -> list[dict[str, object]]:
    findings = list(report_payload.get("findings", []))
    if mode == "report-only":
        return []
    if mode == "apply-safe-fixes":
        return [finding for finding in findings if safe_mode_eligible(finding)]
    approved_ids = approved_ids or set()
    return [finding for finding in findings if finding["id"] in approved_ids]


def apply_edits_to_lines(lines: list[str], edits: list[dict[str, object]]) -> list[str]:
    updated = list(lines)
    for edit in sorted(edits, key=lambda item: (item["start_line"], item["end_line"]), reverse=True):
        start = int(edit["start_line"]) - 1
        end = int(edit["end_line"])
        replacement = list(edit.get("replacement", []))
        updated[start:end] = replacement
    return updated


def agents_headings(lines: list[str]) -> list[str]:
    headings = []
    for line in lines:
        match = re.match(r"^\s{0,3}##\s+(.+?)\s*$", line)
        if match:
            headings.append(match.group(1).strip())
    return headings


def validate_agents_integrity(before_text: str, after_text: str) -> list[str]:
    issues: list[str] = []
    before_headings = agents_headings(before_text.splitlines())
    after_headings = agents_headings(after_text.splitlines())
    before_normalized = [heading.lower() for heading in before_headings]
    after_normalized = [heading.lower() for heading in after_headings]
    for family in CRITICAL_AGENTS_SECTION_FAMILIES:
        if any(keyword in heading for heading in before_normalized for keyword in family):
            if not any(keyword in heading for heading in after_normalized for keyword in family):
                issues.append(f"Missing AGENTS.md critical section family after apply: {family[0]}")
    has_heading_above = False
    for index, line in enumerate(after_text.splitlines(), start=1):
        if re.match(r"^\s{0,3}#{1,2}\s+", line):
            has_heading_above = True
            continue
        if re.match(r"^\s*[-*]\s+", line):
            if not has_heading_above:
                issues.append(f"Found orphaned list item in AGENTS.md at line {index}")
                break
    return issues


def count_constitution_rules(text: str) -> int:
    return sum(1 for line in text.splitlines() if re.match(r"^\s*(?:[-*]|\d+\.)\s+", line))


def validate_constitution_integrity(before_text: str, after_text: str, finding_map: dict[str, dict[str, object]]) -> list[str]:
    issues: list[str] = []
    if not before_text:
        return issues
    deleted_constitution = any(
        edit["path"] == ".specify/memory/constitution.md" and edit["action"] == "delete"
        for finding in finding_map.values()
        for edit in finding.get("edits", [])
    )
    if count_constitution_rules(after_text) < count_constitution_rules(before_text) and not deleted_constitution:
        issues.append("Constitution rule count decreased without an explicit delete finding.")
    return issues


def validate_hook_consistency(workspace_root: Path) -> list[str]:
    issues: list[str] = []
    for manifest_path in discover_sources(workspace_root):
        if path_kind(manifest_path) != "manifest":
            continue
        text = read_text(manifest_path)
        declared = parse_extension_commands(text)
        for hook_name, command_name in parse_extension_hooks(text).items():
            if command_name not in declared:
                issues.append(
                    f"{relative_path(manifest_path, workspace_root)} hook `{hook_name}` references undeclared command `{command_name}`"
                )
    return issues


def validate_repository_diff(workspace_root: Path) -> list[str]:
    try:
        repo_check = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=workspace_root,
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        return []
    if repo_check.returncode != 0:
        return []

    diff_check = subprocess.run(
        ["git", "diff", "--check", "--", "."],
        cwd=workspace_root,
        capture_output=True,
        text=True,
        check=False,
    )
    if diff_check.returncode == 0:
        return []

    output = (diff_check.stdout + diff_check.stderr).strip()
    if not output:
        return ["git diff --check failed after apply."]
    return [f"git diff --check failed: {line}" for line in output.splitlines()]


def format_apply_summary(applied: list[dict[str, object]], files_modified: list[str], validation_issues: list[str]) -> str:
    lines = [
        "## Apply Summary",
        "",
        "| Metric | Value |",
        "|--------|-------|",
        f"| Findings applied | {len(applied)} |",
        f"| Files modified | {len(files_modified)} |",
        f"| Lines changed | {sum(sum(edit['end_line'] - edit['start_line'] + 1 for edit in finding.get('edits', [])) for finding in applied)} |",
        f"| Validations passed | {0 if validation_issues else 4} |",
        f"| Validations failed | {len(validation_issues)} |",
        "",
        "### Changes Applied",
    ]
    if not applied:
        lines.append("- None")
    for finding in applied:
        lines.append(f"- {finding['id']}: {finding['detail']}")
    return "\n".join(lines) + "\n"


def format_apply_failure(validation_issues: list[str], reverted_files: list[str]) -> str:
    lines = [
        "## Apply Failed — All Changes Reverted",
        "",
        "### Validation Failures",
    ]
    for issue in validation_issues:
        lines.append(f"- {issue}")
    lines.extend(["", "### Reverted Files"])
    for file_path in reverted_files:
        lines.append(f"- {file_path}")
    lines.extend(
        [
            "",
            "### Recommendation",
            "- Fix the underlying issue, regenerate the audit report if needed, and retry the apply run.",
        ]
    )
    return "\n".join(lines) + "\n"


def deep_copy_report(payload: dict[str, object]) -> dict[str, object]:
    return copy.deepcopy(payload)
