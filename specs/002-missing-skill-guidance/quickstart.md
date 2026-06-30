# Quickstart: Missing Skill Installation Guidance

**Feature**: [spec.md](./spec.md) | **Date**: 2026-06-30

This guide provides runnable validation scenarios that prove the feature works end-to-end.

## Prerequisites

- macOS or Linux with `bash`
- Node.js and `npx` in PATH (for auto-install scenarios)
- The `superpowers-bridge` extension installed in a Spec Kit project
- Git repository with `.specify/` initialized

## Scenario 1: Check Command Shows Guidance for Missing Skills

**Purpose**: Verify that `/speckit-superb-check` includes installation guidance when skills are missing.

### Setup

```bash
# Ensure no superpowers skills are installed at project level or via project-local plugins
rm -rf ./.agents/skills/test-driven-development
rm -rf ./.agents/skills/verification-before-completion
rm -rf ./.agents/skills/brainstorming
rm -rf ./.agents/plugins
# (remove all 11 skill directories if present)
```

### Run

```bash
# Execute the check command via your coding agent
/speckit-superb-check
```

### Expected Outcome

1. Skill Status table shows all 11 skills as `MISSING` with `Install via adg` in the Guidance column
2. Quick Setup section appears at the bottom with:
   - Hard Requirements table listing `test-driven-development` and `verification-before-completion` as blocking
   - Optional Skills table listing the remaining 9 skills
   - Three installation approaches (plugins recommended, global skills, project skills)
3. If `npx` is available: an interactive prompt asks user to select approach 1-3 or skip
4. If `npx` is not available: manual guidance with adg repository link is shown instead
5. Verdict is `BLOCKED` (because hard requirements are missing)

---

## Scenario 2: Interactive Auto-Install via Check Command

**Purpose**: Verify that confirming installation installs all skills and re-checks status.

### Setup

```bash
# Ensure no superpowers skills installed
rm -rf ./.agents/skills/test-driven-development
rm -rf ./.agents/skills/verification-before-completion
rm -rf ./.agents/plugins
# Verify npx is available
command -v npx
```

### Run

```bash
# Execute check, then select approach 1 (recommended: plugins)
/speckit-superb-check
# When prompted: select "1" (plugins approach)
```

### Expected Outcome

1. `npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g` is executed
2. After installation, an automatic re-check runs
3. Post-Install Verification table shows `MISSING → ✅ READY` for all previously missing skills
4. Updated verdict changes from `BLOCKED` to `READY`

---

## Scenario 3: Inline Guidance on Command Invocation

**Purpose**: Verify that individual bridge commands show guidance when their dependency is missing.

### Setup

```bash
# Remove the skill that /speckit-superb-debug depends on
rm -rf ./.agents/skills/systematic-debugging
rm -rf ./.agents/plugins
rm -rf ~/.agents/skills/systematic-debugging
rm -rf ~/.agents/plugins/*/skills/systematic-debugging
rm -rf ~/.agents/plugins/*/*/skills/systematic-debugging
```

### Run

```bash
# Invoke the debug command
/speckit-superb-debug
```

### Expected Outcome

1. Error message appears:
   ```
   ERROR: Optional superpowers skill `systematic-debugging` not found.
   
   💡 Install via adg (https://github.com/RbBtSn0w/adg):
      Recommended:  npx adg plugins add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -g
      Global:       npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development --global -y
      Project:      npx adg skills add obra/superpowers --skill test-driven-development --skill verification-before-completion --skill brainstorming --skill systematic-debugging --skill receiving-code-review --skill finishing-a-development-branch --skill dispatching-parallel-agents --skill requesting-code-review --skill writing-plans --skill executing-plans --skill subagent-driven-development -y
   
   Run /speckit-superb-check for full diagnostics and interactive installation.
   ```
2. If `npx` is available, the command asks:
   `Would you like to install now? (Select approach 1-3, or skip)`
3. If the user selects an approach and installation succeeds, the command re-checks the
   skill and proceeds.
4. If the user skips, `npx` is unavailable, or install/re-check fails, the command does
   not execute (remains UNAVAILABLE)

---

## Scenario 4: npx Not Available Fallback

**Purpose**: Verify graceful fallback when `npx` is not in PATH.

### Setup

```bash
# Temporarily hide npx (simulate unavailability)
# Option A: test in a clean PATH environment
PATH=/usr/bin:/bin /speckit-superb-check
```

### Expected Outcome

1. Check output shows missing skills with guidance
2. Quick Setup section shows:
   - "npx was not detected" message
   - Manual installation instructions with adg repository link
   - Alternative: direct git clone instructions (e.g. `npx adg plugins add obra/superpowers --skill ...`)
3. No interactive install prompt is offered

---

## Scenario 5: Partial Installation Verification

**Purpose**: Verify that post-install re-check correctly shows mixed results.

### Setup

```bash
# Install only hard requirements manually in direct skill roots
mkdir -p ./.agents/skills/test-driven-development
echo "# Test-Driven Development" > ./.agents/skills/test-driven-development/SKILL.md
mkdir -p ./.agents/skills/verification-before-completion
echo "# Verification" > ./.agents/skills/verification-before-completion/SKILL.md
```

### Run

```bash
/speckit-superb-check
```

### Expected Outcome

1. Hard requirements show as `READY`
2. Optional skills show as `MISSING` with installation guidance
3. Verdict is `PARTIAL` (not BLOCKED, since hard requirements are met)
4. Quick Setup section only lists missing optional skills
5. Install prompt is still offered for remaining optional skills

---

## Test Script Validation

After implementation, run the automated tests:

```bash
# Run installation guidance tests
bash superpowers-bridge/tests/test-install-guidance.sh

# Run npx detection tests
bash superpowers-bridge/tests/test-npx-detection.sh

# Run discovery helper tests
bash superpowers-bridge/tests/test-resolve-skill.sh

# Run existing regression tests to ensure no breakage
bash superpowers-bridge/tests/test-status-sync.sh
bash tests/test-review-regressions.sh
```

### Expected: All tests pass with exit code 0.
