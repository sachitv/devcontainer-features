#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root.' >&2
    exit 1
fi

if [ -n "${VERSION:-}" ] && [ "$VERSION" != "latest" ]; then
    echo "The agy CLI feature installs the latest stable release; version pinning is not supported." >&2
    exit 1
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

if ! command -v curl >/dev/null 2>&1; then
    apt_get_update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl
fi

INSTALLER=$(mktemp)
trap 'rm -f "$INSTALLER"' EXIT

echo "Installing the latest stable agy CLI..."
curl --fail --silent --show-error --location \
    https://antigravity.google/cli/install.sh \
    --output "$INSTALLER"
bash "$INSTALLER" --dir /usr/local/bin
agy --version
