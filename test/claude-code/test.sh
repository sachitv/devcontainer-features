#!/bin/bash
set -e

source dev-container-features-test-lib

check "claude is installed at /usr/local/bin/claude" bash -c "command -v claude | grep -qx '/usr/local/bin/claude'"
check "claude prints its version" bash -c "claude --version | grep -q ."

reportResults
