# Claude Code

Installs the [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) command-line coding agent from its official native binary on GitHub Releases and makes `claude` available on `PATH`. No Node.js or npm is required.

## Example Usage

```json
"features": {
    "ghcr.io/sachitv/devcontainer-features/claude-code:1": {
        "version": "latest"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of Claude Code to install, or `latest`. | string | latest |
