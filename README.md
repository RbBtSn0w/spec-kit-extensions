# Spec Kit Extensions

A collection of high-performance extensions for [Spec Kit](https://github.com/github/spec-kit) (SDD Workflow).

## Extensions

| Extension | Version | Description |
|---|---|---|
| [Superpowers Bridge](./superpowers-bridge) | 1.0.0 | Orchestrates obra/superpowers skills inside Spec Kit workflow. |

## Installation

To add an extension to your Spec Kit environment:

```bash
specify extension add https://github.com/RbBtSn0w/spec-kit-extensions/tree/main/[extension-name]
```

Example:

```bash
specify extension add https://github.com/RbBtSn0w/spec-kit-extensions/tree/main/superpowers-bridge
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
