#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
check "validate opencode reports v1 version" bash -c "opencode --version | grep -q '1.1.8'"
check "validate opencode2 reports v2 version" bash -c "opencode2 --version | grep -q '2.0.6'"
check "validate opencode2 does not share the opencode v1 database" bash -c "opencode2 debug paths db | grep -q 'opencode2\.db$'"
check "validate OPENCODE2_DB overrides the opencode2 database" bash -c "OPENCODE2_DB=custom.db opencode2 debug paths db | grep -q 'custom\.db$'"
check "validate opencode2 ignores a global OPENCODE_DB" bash -c "OPENCODE_DB=opencode.db opencode2 debug paths db | grep -q 'opencode2\.db$'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
