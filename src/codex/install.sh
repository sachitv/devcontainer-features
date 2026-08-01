#!/bin/bash
set -e

REPO_OWNER="openai"
REPO_NAME="codex"
BINARY_NAME="codex"

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" before running this script.' >&2
    exit 1
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
    fi
}

check_packages ca-certificates curl zstd

case "$(uname -m)" in
    x86_64)
        TARGET="x86_64-unknown-linux-musl"
        ;;
    aarch64 | arm64)
        TARGET="aarch64-unknown-linux-musl"
        ;;
    *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

ASSET_NAME="${BINARY_NAME}-${TARGET}.zst"
if [ -z "${RELEASE_TAG:-}" ] || [ "$RELEASE_TAG" = "latest" ]; then
    # This redirect resolves the stable release without consuming GitHub API
    # rate limit, which is shared by concurrent CI jobs.
    RELEASE_TAG="latest"
    DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest/download/$ASSET_NAME"
    echo "Fetching the latest stable Codex release..."
else
    DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$RELEASE_TAG/$ASSET_NAME"
    echo "Fetching Codex release $RELEASE_TAG..."
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Installing Codex $RELEASE_TAG for $TARGET..."
curl --fail --silent --show-error --location "$DOWNLOAD_URL" --output "$TMP_DIR/$ASSET_NAME"
zstd --decompress "$TMP_DIR/$ASSET_NAME" -o "$TMP_DIR/$BINARY_NAME"
install -m 0755 "$TMP_DIR/$BINARY_NAME" "/usr/local/bin/$BINARY_NAME"

"$BINARY_NAME" --version
echo "Codex $RELEASE_TAG installed successfully."
