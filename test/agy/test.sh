#!/bin/bash
set -e

source dev-container-features-test-lib

check "agy is installed" command -v agy
check "agy prints its version" bash -c "agy --version | grep -q ."

reportResults
