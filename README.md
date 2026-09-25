# Useful Dev Container Features

> This repository provides a collection of useful [dev container Features](https://containers.dev/implementors/features/) for enhancing your development environments. These features are hosted on GitHub Container Registry and follow the [dev container Feature distribution specification](https://containers.dev/implementors/features-distribution/).
>
> To provide feedback to the specification, please leave a comment [on spec issue #70](https://github.com/devcontainers/spec/issues/70). For more broad feedback regarding dev container Features, please see [spec issue #61](https://github.com/devcontainers/spec/issues/61).

## Usage

All of the features below can be used with the following base image. Append whichever features you want from the sections below to the `features` object:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        ...
    }
}
```

## Table of Contents

- [Usage](#usage)
- [Features](#features)
  - [Codex](#codex)
  - [Opencode](#opencode)
  - [Opencode 2](#opencode-2)
  - [Claude Code](#claude-code)
  - [Antigravity CLI](#antigravity-cli)
  - [Kilo Code CLI](#kilo-code-cli)

## Features

This repository contains the following dev container features:

### Codex

The Codex feature installs the [Codex CLI tool](https://github.com/openai/codex), an AI-powered coding assistant. This feature downloads and installs the specified version of Codex, making it available in your dev container.

#### Usage

Add the feature to the `features` object in your `devcontainer.json`:

```jsonc
"features": {
    "ghcr.io/sachitv/devcontainer-features/codex:1": {
        "release_tag": "latest"
    }
}
```

After building the container, you can use Codex:

```bash
$ codex --version
Codex v0.58.0

```

#### Options

- `release_tag`: Specify the GitHub release tag for Codex to install (default: "latest"). You can provide a specific tag like "rust-v0.58.0" or use "latest" for the stable release marked latest by GitHub; draft and prerelease releases are ignored.

#### Notes

- Ensure you set the `OPENAI_API_KEY` environment variable for Codex to function properly.
- The feature installs Codex to `/usr/local/bin/`.

### Opencode

The Opencode feature installs the [opencode CLI tool](https://github.com/anomalyco/opencode) so it is available inside your dev container. It fetches the requested release from GitHub and places the binary on your PATH.

#### Usage

Add the feature to the `features` object in your `devcontainer.json`:

```jsonc
"features": {
    "ghcr.io/sachitv/devcontainer-features/opencode:1": {
        "version": "latest"
    }
}
```

After building the container, you can verify the installation:

```bash
$ opencode --help
```

#### Options

- `version`: Version of opencode to install (default: `latest`). Provide a specific semantic version like `1.2.3` to pin the install.

### Opencode 2

The Opencode 2 feature installs the [OpenCode 2](https://opencode.ai/v2/docs) CLI tool. It runs the official v2 installer and places `opencode` and `opencode2` on your PATH.

#### Usage

Add the feature to the `features` object in your `devcontainer.json`:

```jsonc
"features": {
    "ghcr.io/sachitv/devcontainer-features/opencode2:1": {
        "version": "latest"
    }
}
```

After building the container, you can verify the installation:

```bash
$ opencode2 --version
```

#### Options

- `version`: Version of opencode 2 to install (default: `latest`). Provide a specific semantic version like `2.0.6` to pin the install.

#### Notes

- The OpenCode 2 binary is installed to `/usr/local/lib/opencode2/bin/opencode` and accessed via `/usr/local/bin/opencode2`.
- When installed alone, `/usr/local/bin/opencode` is also linked to `opencode2`. If the `opencode` (v1) feature is also included in the same devcontainer, the existing `opencode` binary is preserved and OpenCode 2 is available via `opencode2`.
- The feature requires `ca-certificates`, `curl`, and `tar` (automatically installed via `apt-get`, `apk`, `dnf`, `yum`, `pacman`, or `zypper`).
- Uses the vendor's official bootstrap installer from `https://opencode.ai/v2/install`, which performs platform, libc, and CPU architecture detection.

### Claude Code

The Claude Code feature installs [Anthropic's Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) command-line coding agent from its official native binary on GitHub Releases. No Node.js or npm is required.

#### Usage

Add the feature to the `features` object in your `devcontainer.json`:

```jsonc
"features": {
    "ghcr.io/sachitv/devcontainer-features/claude-code:1": {
        "version": "latest"
    }
}
```

Use the `version` option to install `latest` or pin a semantic version (for example `2.1.220`). After the container is built, run `claude --version` to verify the installation.

### Antigravity CLI

The Antigravity CLI feature installs the latest stable Antigravity CLI.

#### Usage

Add the feature to the `features` object in your `devcontainer.json`:

```jsonc
"features": {
    "ghcr.io/sachitv/devcontainer-features/agy:1": {}
}
```

After the container is built, run `agy --version` to verify the installation.

### Kilo Code CLI

The Kilo Code feature installs the [Kilo Code CLI](https://kilo.ai/cli) from its GitHub Releases native binary.

#### Usage

Add the feature to the `features` object in your `devcontainer.json`:

```jsonc
"features": {
    "ghcr.io/sachitv/devcontainer-features/kilo-code:1": {
        "version": "latest"
    }
}
```

Use the `version` option to install `latest` or pin a semantic version. After the container is built, run `kilo --version` to verify the installation.
