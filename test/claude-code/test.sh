#!/bin/bash
set -e

source dev-container-features-test-lib

check "claude is installed" command -v claude
check "claude prints its version" bash -c "claude --version | grep -q ."

reportResults
