
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
| version | npm dist-tag ('beta', 'next', 'dev', 'tui-v2') or an explicit @opencode-ai/cli-linux-<arch> package version to install. These all resolve to '0.0.0-<tag>-<build>' style pre-release versions, not semantic versions. 'latest' is not supported since it points at the unrelated, stable opencode v1 release line. | string | beta |

## Notes

- This installs the `opencode2` binary, which is the in-development, pre-release build of the next major version of [opencode](https://github.com/anomalyco/opencode). It is published on npm as the platform-specific `@opencode-ai/cli-linux-x64` / `@opencode-ai/cli-linux-arm64` packages under the `beta`, `next`, `dev` and `tui-v2` dist-tags, and this feature downloads the matching binary directly from the npm registry with `curl` and extracts it with `tar` — no Node.js or npm CLI is installed or invoked.
- All of these dist-tags resolve to pre-release build identifiers shaped like `0.0.0-<tag>-<build>` (e.g. `0.0.0-beta-19157`), not semantic versions, and the build number keeps advancing as the project publishes new preview builds. Pin `version` to a specific one of these strings if you need a reproducible install.
- `version: latest` is **not** supported and will fail: on the underlying npm packages, `latest` points at the stable, already-released opencode v1 line (currently `1.18.x`), which ships a differently named binary, not `opencode2`.
- This is a separate tool/binary from the stable `opencode` feature in this repository and can be installed alongside it without conflict, since it installs to `/usr/local/bin/opencode2`.



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/sachitv/devcontainer-features/blob/main/src/opencode2/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
