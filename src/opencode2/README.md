
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
- **Configuration Locations & Precedence**:
  - Global config: `~/.config/opencode/opencode.json(c)` and `~/.config/opencode/cli.json` (CLI settings).
  - Project config: `<project>/.opencode/opencode.json(c)` and `<project>/opencode.json(c)`.
  - Extensions & definitions: `<project>/.opencode/` (`skills/`, `commands/`, `agents/`).
  - Precedence: Discovered configs are merged from current directory to root. Every discovered `.opencode/` config overrides direct `opencode.json(c)` configs, which override the global config.
- **V1 Compatibility & Differences**:
  - OpenCode 2 reads existing V1 configurations and normalizes them in-memory without rewriting files. Existing skills, commands, and agent definitions under `.opencode/` continue to work.
  - Native V2 configurations introduce schema changes: `permissions` is an ordered list (using actions `shell`, `edit`, `subagent`, `websearch`), `agent`/`mode` becomes `agents` (with `system` replacing `prompt`), and `command` becomes `commands`.
  - V1 plugins do not run in V2 due to a new plugin API contract.
- **Coexistence Warning with Opencode (v1)**: OpenCode 1 and OpenCode 2 share default configuration paths (`~/.config/opencode/` and `.opencode/`). While V2 can read V1 configs, V1 will not recognize native V2 syntax. If both features are installed in the same devcontainer, keep configs in the V1 format, isolate them per project, or configure options using environment variables.
- **System Dependencies**: Requires `ca-certificates`, `curl`, and `tar`. Automatically installed via `apt-get`, `apk`, `dnf`, `yum`, `pacman`, or `zypper`.
- **Installer Script**: Uses the vendor's official bootstrap installer from `https://opencode.ai/v2/install`, which performs platform, libc (glibc/musl), and CPU architecture/AVX2 detection to fetch the appropriate binary artifact.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/sachitv/devcontainer-features/blob/main/src/opencode2/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
