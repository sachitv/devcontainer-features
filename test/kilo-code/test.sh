#!/bin/bash
set -e

source dev-container-features-test-lib

check "kilo is installed" command -v kilo
check "kilo prints its version" bash -c "kilo --version | grep -q ."
check "/usr/local/bin remains mode 755" bash -c '[ "$(stat -c %a /usr/local/bin)" = "755" ]'

reportResults
