
# Opencode 2 (opencode2)

A feature for installing opencode2, the preview/beta build of the next major version of the opencode CLI tool

## Example Usage

```json
"features": {
    "ghcr.io/sachitv/devcontainer-features/opencode2:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | npm dist-tag ('beta', 'next', 'dev', 'tui-v2') or an explicit @opencode-ai/cli-linux-<arch> package version to install. | string | beta |

## Notes

- This installs the `opencode2` binary, which is the in-development, pre-release build of the next major version of [opencode](https://github.com/anomalyco/opencode). It is published on npm as the platform-specific `@opencode-ai/cli-linux-x64` / `@opencode-ai/cli-linux-arm64` packages under the `beta`, `next`, `dev` and `tui-v2` dist-tags, and this feature downloads the matching binary directly from the npm registry without requiring Node.js or npm.
- Because this tracks an unreleased, actively changing build, it can be unstable and its version identifiers (e.g. `0.0.0-beta-19157`) are not semantic versions. Pin `version` to a specific package version if you need a reproducible install.
- This is a separate tool/binary from the stable `opencode` feature in this repository and can be installed alongside it without conflict, since it installs to `/usr/local/bin/opencode2`.



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/sachitv/devcontainer-features/blob/main/src/opencode2/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
