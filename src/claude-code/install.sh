#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root.' >&2
    exit 1
fi

VERSION="${VERSION:-latest}"
if ! [[ "$VERSION" =~ ^(latest|[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.-]+)?)$ ]]; then
    echo "Invalid Claude Code version: $VERSION" >&2
    exit 1
fi

echo "Installing Claude Code $VERSION..."
npm install --global --omit=dev "@anthropic-ai/claude-code@$VERSION"
claude --version
