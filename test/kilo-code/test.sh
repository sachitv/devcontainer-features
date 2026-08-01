#!/bin/bash
set -e

source dev-container-features-test-lib

check "kilo is installed" command -v kilo
check "kilo prints its version" bash -c "kilo --version | grep -q ."

reportResults
