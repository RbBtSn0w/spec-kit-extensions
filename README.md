# Spec Kit Extensions

Evidence-first extensions for [Spec Kit](https://github.com/github/spec-kit) workflows.

The current wedge is trustable AI-agent completion: when an agent says an implementation is complete, the workflow should have fresh tests, requirement coverage, and durable evidence to prove it. Broader AI governance and cross-tool portability are roadmap items, not the first product promise.

## Extensions

| Extension | Version | Description |
|---|---|---|
| [Superpowers Bridge](./superpowers-bridge) | 1.5.0 | Bridges selected Superpowers disciplines into Spec Kit as evidence-first trust gates for agent workflows. |
| [MemoryLint](./memorylint) | 1.5.0 | Agent memory governance tool: Bidirectional audit and boundary management between AGENTS.md and the constitution. |

## Installation

Register this repository's catalog once so Spec Kit can install and update
extensions from an install-approved source:

```bash
specify extension catalog add https://raw.githubusercontent.com/RbBtSn0w/spec-kit-extensions/main/catalog.json \
  --name rbbtsn0w-spec-kit-extensions \
  --priority 1 \
  --install-allowed \
  --description "RbBtSn0w Spec Kit Extensions"
```

Then install or update by the extension IDs declared in the catalog:

```bash
specify extension add superb
specify extension update superb

specify extension add memorylint
specify extension update memorylint
```

For one-off installs without catalog-managed updates, install a single extension
from a published release:

```bash
specify extension add superpowers-bridge --from https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/superpowers-bridge-v1.5.0/superpowers-bridge.zip
specify extension add memorylint --from https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/memorylint-v1.5.0/memorylint.zip
```

For local development, clone this repository and either install a specific extension or register every top-level extension discovered by `install.sh`:

```bash
git clone https://github.com/RbBtSn0w/spec-kit-extensions.git
cd spec-kit-extensions

specify extension add --dev ./superpowers-bridge
# or
./install.sh
```

## Product Direction

- **Now:** evidence-based completion gates, status synchronization, and requirement drift review for Spec Kit users.
- **Next:** MemoryLint semantic audits for long-lived agent instructions.
- **Later:** Universal Bridge portability once the Spec Kit loop proves useful in real repositories.

## Development

1. Clone this repository.
2. Add your extension in a new directory.
3. Register your development extension locally:

```bash
specify extension add --dev ./[extension-name]
```

## License

MIT
