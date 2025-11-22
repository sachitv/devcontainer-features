# Useful Dev Container Features

> This repository provides a collection of useful [dev container Features](https://containers.dev/implementors/features/) for enhancing your development environments. These features are hosted on GitHub Container Registry and follow the [dev container Feature distribution specification](https://containers.dev/implementors/features-distribution/).
>
> To provide feedback to the specification, please leave a comment [on spec issue #70](https://github.com/devcontainers/spec/issues/70). For more broad feedback regarding dev container Features, please see [spec issue #61](https://github.com/devcontainers/spec/issues/61).

## Table of Contents

- [Features](#features)
  - [Codex](#codex)
  - [Opencode](#opencode)

## Features

This repository contains the following dev container features:

### Codex

The Codex feature installs the [Codex CLI tool](https://github.com/openai/codex), an AI-powered coding assistant. This feature downloads and installs the specified version of Codex, making it available in your dev container.

#### Usage

Add the feature to your `devcontainer.json`:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/sachitv/devcontainer-features/codex:1": {
            "release_tag": "latest"
        }
    }
}
```

After building the container, you can use Codex:

```bash
$ codex --version
Codex v0.58.0

$ codex-cli --help
# Or use the wrapper script
```

#### Options

- `release_tag`: Specify the GitHub release tag for Codex to install (default: "latest"). You can provide a specific tag like "rust-v0.58.0" or use "latest" for the most recent release.

#### Notes

- Ensure you set the `OPENAI_API_KEY` environment variable for Codex to function properly.
- The feature installs Codex to `/usr/local/bin/` and creates a wrapper script for convenience.

### Opencode

The Opencode feature installs the [opencode CLI tool](https://github.com/sst/opencode) so it is available inside your dev container. It fetches the requested release from GitHub and places the binary on your PATH.

#### Usage

Add the feature to your `devcontainer.json`:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/sachitv/devcontainer-features/opencode:1": {
            "version": "latest"
        }
    }
}
```

After building the container, you can verify the installation:

```bash
$ opencode --help
```

#### Options

- `version`: Version of opencode to install (default: `latest`). Provide a specific semantic version like `1.2.3` to pin the install.


