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

check_packages ca-certificates curl jq zstd

case "$(uname -m)" in
    x86_64)
        TARGET="x86_64-unknown-linux-musl"
        ;;
    aarch64 | arm64)
        TARGET="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

if [ -z "${RELEASE_TAG:-}" ] || [ "$RELEASE_TAG" = "latest" ]; then
    # GitHub's latest endpoint returns the release marked latest and excludes
    # releases that are drafts or prereleases.
    RELEASE_API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
    echo "Fetching the latest stable Codex release..."
else
    RELEASE_API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/tags/$RELEASE_TAG"
    echo "Fetching Codex release $RELEASE_TAG..."
fi

RELEASE_INFO=$(curl --fail --silent --show-error --location "$RELEASE_API_URL")
RELEASE_TAG=$(echo "$RELEASE_INFO" | jq -r '.tag_name // empty')
if [ -z "$RELEASE_TAG" ]; then
    echo "Could not determine a Codex release tag from $RELEASE_API_URL." >&2
    exit 1
fi

ASSET_NAME="${BINARY_NAME}-${TARGET}.zst"
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | jq -r --arg name "$ASSET_NAME" \
    '.assets[] | select(.name == $name) | .browser_download_url' | head -n 1)
if [ -z "$DOWNLOAD_URL" ]; then
    echo "Release $RELEASE_TAG has no $ASSET_NAME asset." >&2
    exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Installing Codex $RELEASE_TAG for $TARGET..."
curl --fail --silent --show-error --location "$DOWNLOAD_URL" --output "$TMP_DIR/$ASSET_NAME"
zstd --decompress "$TMP_DIR/$ASSET_NAME" --output "$TMP_DIR/$BINARY_NAME"
install -m 0755 "$TMP_DIR/$BINARY_NAME" "/usr/local/bin/$BINARY_NAME"

# Retain the convenience command exposed by earlier versions of this Feature.
ln -sf "/usr/local/bin/$BINARY_NAME" "/usr/local/bin/${BINARY_NAME}-cli"

"$BINARY_NAME" --version
echo "Codex $RELEASE_TAG installed successfully."
