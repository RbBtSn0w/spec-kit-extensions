# Spec Kit Extensions

A collection of high-performance extensions for [Spec Kit](https://github.com/github/spec-kit) (SDD Workflow).

## Extensions

| Extension | Version | Description |
|---|---|---|
| [Superpowers Bridge](./superpowers-bridge) | 2.0.0 | Orchestrates obra/superpowers skills inside Spec Kit workflow. |
| [MemoryLint](./memorylint) | 2.0.0 | Agent memory governance tool: Bidirectional audit and boundary management between AGENTS.md and the constitution. |

## Installation

Since this is a collection of extensions, you should clone this repository and install the specific extension you need:

```bash
git clone https://github.com/RbBtSn0w/spec-kit-extensions.git
cd spec-kit-extensions

# Install the extension you want
specify extension add --dev ./superpowers-bridge
```

## Development

1. Clone this repository.
2. Add your extension in a new directory.
3. Register your development extension locally:

```bash
specify extension add --dev ./[extension-name]
```

## License

MIT
