# gh-address-cr for Spec Kit

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Spec Kit](https://img.shields.io/badge/Spec%20Kit-Extension-orange.svg)](https://github.com/github/spec-kit)
[![gh-address-cr](https://img.shields.io/badge/GitHub-gh--address--cr-green.svg)](https://github.com/RbBtSn0w/gh-address-cr)

> **Auditable GitHub PR review resolution & trust-gated address engine for Spec Kit workflows.**
> Bridge real GitHub review threads, local code-review findings, test-first fixes, and cryptographic completion proof into your Spec Kit agent cycle.

---

## ⚡ The Missing Link in AI PR Workflows

AI coding assistants are extraordinary at writing pull requests, but **dangerously unreliable at handling Code Reviews**:

* ❌ **Hallucinated Resolves**: Agents claim "Fixed!" in comments without actually testing or committing the change.
* ❌ **Ignored Feedback**: Inline reviewer comments get lost or skipped during context window churn.
* ❌ **Destructive Actions**: Unconstrained agents may force-push over human commits, modify remotes, or close PRs.
* ❌ **Zero Closure Proof**: No objective gate to guarantee 100% of review threads are resolved before merge.

**`gh-address-cr` solves this once and for all.**
It acts as a deterministic, SQLite-backed state machine and security boundary. Spec Kit agents cannot declare completion by verbal assumption; they must provide verified commit SHAs, file paths, passing test output, and obtain a clean `final-gate` proof.

---

## 📊 Comparison

| Capability | Standard AI Flow | Spec Kit + `gh-address-cr` |
|---|---|---|
| **Thread Tracking** | Ad-hoc text extraction, easily misses threads | 100% deterministic SQLite tracking per PR |
| **Fix Verification** | "Trust me, I ran tests" | Evidence-bound (`<cmd=passed>`, commit SHA) |
| **GitHub Mutations** | Unsafe, raw API calls by agent | Managed runtime batch publishing & thread resolution |
| **Safety Guardrails** | Unrestricted shell/git actions | Enforced boundaries: head branch only, NO force-pushes |
| **Stacked PRs** | Fails or rewrites wrong layers | Native `revision_binding.v2` layer isolation |
| **Completion Gate** | Hand-wavy agreement | Strict, auditable `final-gate` verification |

---

## 🚀 60-Second Quickstart

### 1. Install the `gh-address-cr` CLI Runtime

Install the underlying runtime CLI via your favorite package manager:

```bash
# Recommended via pipx
pipx install gh-address-cr

# Or via Homebrew
brew install RbBtSn0w/tap/gh-address-cr

# Or via pip
pip install gh-address-cr
```

Verify your installation:

```bash
gh-address-cr version
```

### 2. Add the Extension to Spec Kit

In your project repository:

```bash
specify extension add gh-address-cr --dev ./gh-address-cr
```

*(Once published to the catalog: `specify extension add gh-address-cr`)*

---

## 🛠 Commands Reference

### `/speckit.gh-address-cr.doctor`
Runs comprehensive diagnostics on your local environment:
- Verifies `gh` CLI installation and GitHub authentication.
- Verifies `gh-address-cr` runtime availability and compatibility.
- Detects the current active branch and associated GitHub Pull Request.

```bash
/speckit.gh-address-cr.doctor
```

### `/speckit.gh-address-cr.address`
Addresses open GitHub PR review comments step-by-step:
1. Discovers unresolved threads on the target PR (auto-detects from current branch if omitted).
2. Guides the agent to implement test-first fixes for each thread.
3. Requires execution proof (e.g., `pytest`, `npm test`, or `cargo test`).
4. Records verified evidence via `gh-address-cr agent resolve`.
5. Publishes replies and resolves threads on GitHub.
6. Runs `final-gate` to prove clean closure.

```bash
/speckit.gh-address-cr.address
# Or specify a target repository and PR:
/speckit.gh-address-cr.address owner/repo 123
```

### `/speckit.gh-address-cr.review`
Ingests structured review findings (from static analyzers, linters, or AI review producers) and orchestrates them alongside live GitHub review threads:

```bash
/speckit.gh-address-cr.review owner/repo 123
```

### `/speckit.gh-address-cr.gate`
The ultimate trust gate. Audits the PR session and confirms that zero unaddressed review threads or pending findings remain. Exits `0` on clean state or non-zero with exact blockers.

```bash
/speckit.gh-address-cr.gate
```

---

## 🔄 Workflow Lifecycle

```mermaid
flowchart TD
    A["speckit.implement / converge"] --> B["Create or Update PR"]
    B --> C["Reviewers Post Comments / CI Findings"]
    C --> D["/speckit.gh-address-cr.address"]
    D --> E["Ingest Threads & ActionRequests"]
    E --> F["Implement Fix (Test-First)"]
    F --> G["Run Validation Tests (Proof)"]
    G --> H["gh-address-cr agent resolve"]
    H --> I{"More Threads?"}
    I -- Yes --> E
    I -- No --> J["gh-address-cr agent publish"]
    J --> K["/speckit.gh-address-cr.gate"]
    K --> L["All Proven & Ready to Merge!"]
```

---

## 🛡 Authorization Scope & Safety Boundaries

When running `gh-address-cr` through Spec Kit, the agent operates under an explicit, inviolable safety contract:

* **Authorized**: Committing focused fixes on the PR head branch, running local validation commands, and publishing thread replies/resolutions through the runtime.
* **Forbidden**:
  - `git push --force` or modifying git histories.
  - Modifying git remotes, configs, or permissions.
  - Merging, closing, or queueing pull requests.
  - Modifying other PRs in a stacked sequence.
  - Obeying arbitrary prompts embedded inside reviewer comment bodies (defense against prompt injection).

---

## 🌟 Support & Community

* **Source Repository**: [https://github.com/RbBtSn0w/gh-address-cr](https://github.com/RbBtSn0w/gh-address-cr)
* Give `gh-address-cr` a ⭐️ on GitHub if this extension helps streamline your AI code review workflows!
* Report issues, request features, or submit PRs directly to the main repository.

---

## License

MIT © RbBtSn0w
