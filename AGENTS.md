# AGENTS.md

## 1. Purpose
This document defines the operational boundaries and expectations for automated agents interacting with this repository. The primary goal of allowing agents is to assist with maintenance, documentation updates, testing improvements, and feature iteration while ensuring the stability and security of the devcontainer features.

## 2. Allowed Agent Actions
Agents are authorized to perform the following actions:
- **Modify Feature Implementation:** Update `Dockerfile`, `install.sh`, and feature metadata (`devcontainer-feature.json`) to fix bugs or implement requested features.
- **Update Documentation:** Improve `README.md`, feature-specific documentation, and usage examples.
- **Enhance Testing:** Add new test scenarios, improve existing validation scripts, and ensure test coverage for changes.
- **Maintenance:** Propose version bumps, update changelogs, and refresh dependencies.

## 3. Disallowed Agent Actions
Agents are strictly prohibited from:
- **Releasing:** Publishing releases or git tags.
- **Security Sensitive Changes:** Modifying CI/CD secrets, workflows involving credentials, or effectively altering the security posture without human review.
- **Breaking Changes:** Introducing changes that break backward compatibility without explicit instruction and approval.
- **API Changes:** Silently changing feature IDs, options, or public interfaces.

## 4. Change Safety Rules
- **Intent:** Every change must be accompanied by a clear explanation of the intent.
- **Impact Analysis:** Agents must summarize the potential impact and risk of the change, specifically highlighting any changes to the user interface (options) or runtime behavior.
- **Scope:** Changes must be minimal and scoped strictly to the requested task. Avoid "cleanup" or unrelated refactoring unless explicitly requested.

## 5. Devcontainer Feature Constraints
- **Specification Compliance:** All changes must adhere to the [Devcontainer Feature Specification](https://containers.dev/implementors/features/).
- **Minimalism:** Keep image layers and size impact minimal. Clean up package manager caches and temporary files.
- **Determinism:** Implementations should be deterministic. Avoid relying on `latest` tags where possible; pin versions or use checksums.
- **Offline Capability:** Prefer build-time installation and configuration. Avoid runtime network calls unless explicitly necessary for the feature's function.

## 6. Testing & Validation Expectations
- **Local Validation:** Agents must verify changes by running the feature's test scenarios (e.g., using `devcontainer features test`).
- **Idempotency:** Install scripts (`install.sh`) must be idempotent. Agents should verify that re-running the script does not cause errors or unintended side effects.
- **OS Compatibility:** Validation should consider supported distributions (e.g., Debian, Ubuntu, Alpine) as defined in the feature metadata.

## 7. Documentation Standards
- **Sync:** Documentation must be updated in the same commit as the code changes that necessitate it.
- **Style:** Documentation should be clear, concise, and example-driven. Use standard Markdown.
- **Auto-generation:** If documentation is auto-generated (e.g., from metadata), the agent must ensure the source metadata is correct and regenerate the artifacts.

## 8. Review & Approval Workflow
- **Presentation:** Changes must be presented via Pull Request (or equivalent) with a descriptive title and body.
- **Artifacts:** Include summaries of test results and specific diffs for critical files (e.g., `devcontainer-feature.json`).
- **Checklists:** Use checklists to verify that safety rules and testing expectations have been met.

## 9. Tone & Operating Principles
- **Conservative:** Prioritize stability and existing behavior over novelty.
- **Trust:** Optimize for developer trust. If a change is ambiguous, ask for clarification.
- **Clarity:** Prefer clear, readable code and documentation over clever or complex solutions.
