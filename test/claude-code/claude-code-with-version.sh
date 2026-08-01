#!/bin/bash
set -e

source dev-container-features-test-lib

check "validate claude version contains 2.1.220" bash -c "claude --version | grep -q '2.1.220'"

reportResults
