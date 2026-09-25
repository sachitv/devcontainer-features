
# Opencode 2 (opencode2)

A feature for installing the opencode 2 CLI tool

## Example Usage

```json
"features": {
    "ghcr.io/sachitv/devcontainer-features/opencode2:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of opencode 2 to install. Use 'latest' for the most recent release. | string | latest |

## Notes

- **Command & Coexistence with Opencode (v1)**: The OpenCode 2 binary is installed to `/usr/local/lib/opencode2/bin/opencode` and exposed via `/usr/local/bin/opencode2`. If `/usr/local/bin/opencode` is not already present, it is also linked to `opencode2`. If the `opencode` (v1) feature is also used in the same devcontainer, the existing `opencode` binary is preserved and OpenCode 2 is accessed via `opencode2`.
- **System Dependencies**: Requires `ca-certificates`, `curl`, and `tar`. Automatically installed via `apt-get`, `apk`, `dnf`, `yum`, `pacman`, or `zypper`.
- **Installer Script**: Uses the vendor's official bootstrap installer from `https://opencode.ai/v2/install`, which performs platform, libc (glibc/musl), and CPU architecture/AVX2 detection to fetch the appropriate binary artifact.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/sachitv/devcontainer-features/blob/main/src/opencode2/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
