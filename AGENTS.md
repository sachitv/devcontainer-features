# Repository Guidelines

## Project Structure & Module Organization
- `src/` holds devcontainer features, one directory per feature (e.g., `src/codex`, `src/opencode`). Each feature includes `devcontainer-feature.json`, `install.sh`, and an auto-generated `README.md`.
- `test/` mirrors the feature layout with devcontainer CLI tests (e.g., `test/codex`, `test/opencode`) plus `scenarios.json` and shell-based checks.
- `README.md` at the repo root documents the published features and usage examples.

## Build, Test, and Development Commands
- `devcontainer features test --features codex --remote-user root --skip-scenarios --base-image mcr.microsoft.com/devcontainers/base:ubuntu .`
  Runs the Codex feature tests via the devcontainer CLI.
- `devcontainer features test --features opencode --remote-user root --skip-scenarios --base-image mcr.microsoft.com/devcontainers/base:ubuntu .`
  Runs the Opencode feature tests via the devcontainer CLI.
- Shell scripts in `test/<feature>/*.sh` can be run individually inside the devcontainer test harness.

## Coding Style & Naming Conventions
- Shell scripts are Bash (`#!/bin/bash`) with `set -e`; keep indentation consistent (4 spaces in conditionals) and prefer explicit variable names like `REPO_OWNER`.
- Feature directories use lowercase names that match the feature ID (e.g., `codex`, `opencode`).
- Keep feature metadata in `devcontainer-feature.json`; documentation in `src/<feature>/README.md` is auto-generated.

## Testing Guidelines
- Tests rely on the devcontainer CLI test library (`dev-container-features-test-lib`) and use `check "label" <cmd>` plus `reportResults`.
- Name test scripts by scenario (e.g., `test.sh`, `codex-with-version.sh`); keep scenarios in `scenarios.json` per feature.

## Commit & Pull Request Guidelines
- Commit subjects in this repo are short and imperative (e.g., "Add test for opencode version 1.1.8"); use a conventional prefix like `feat:` when it adds clarity.
- Include issue/PR references in the subject when applicable (e.g., `(#8)`).
- PRs should describe the feature change, include test evidence (command + result), and update relevant READMEs if behavior or options change.

## Configuration Notes
- Features are published to GitHub Container Registry; example usage lives in `README.md` and `src/<feature>/README.md`.
- Install scripts expect root inside the container; call out any new system dependencies in `install.sh`.
