#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root.' >&2
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

readonly AGY_INSTALLER_SHA256='ee1ea43ce4e9e56356c4ab6dad907ef357ae4bdfcaadb682735909fb57c9c640'

INSTALLER=$(mktemp)
trap 'rm -f "$INSTALLER"' EXIT

echo "Installing the latest stable agy CLI..."
curl --fail --silent --show-error --location \
    https://antigravity.google/cli/install.sh \
    --output "$INSTALLER"

echo "Verifying agy installer checksum..."
if ! echo "${AGY_INSTALLER_SHA256}  ${INSTALLER}" | sha256sum --check - >/dev/null 2>&1; then
    echo 'agy installer SHA-256 checksum verification failed.' >&2
    exit 1
fi

bash "$INSTALLER" --dir /usr/local/bin
agy --version
