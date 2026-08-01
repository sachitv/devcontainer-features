#!/bin/bash
set -e

source dev-container-features-test-lib

check "validate kilo version contains 7.4.18" bash -c "kilo --version | grep -q '7.4.18'"

reportResults
