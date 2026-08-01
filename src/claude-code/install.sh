#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root.' >&2
    exit 1
fi

readonly githubRepository='anthropics/claude-code'
readonly binaryName='claude'
readonly binaryTargetFolder='/usr/local/bin'

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* -maxdepth 0 2>/dev/null | wc -l)" = "0" ]; then
        apt-get update -y
    fi
}

apt_get_checkinstall() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
    fi
}

apt_get_cleanup() {
    apt-get clean
    rm -rf /var/lib/apt/lists/*
}

check_required_tools() {
    declare -a missing=()
    [ -r '/etc/ssl/certs/ca-certificates.crt' ] || missing+=('ca-certificates')
    command -v curl >/dev/null 2>&1 || missing+=('curl')
    command -v tar >/dev/null 2>&1 || missing+=('tar')
    if [ "${#missing[@]}" -gt 0 ]; then
        apt_get_checkinstall "${missing[@]}"
        apt_get_cleanup
    fi
}

github_get_latest_release() {
    local latestUrl
    latestUrl="$(curl --fail --silent --show-error --location \
        --output /dev/null --write-out '%{url_effective}' \
        "https://github.com/${githubRepository}/releases/latest")"
    case "$latestUrl" in
        */releases/tag/v*) printf '%s\n' "${latestUrl##*/releases/tag/v}" ;;
        *)
            echo "Unable to determine the latest Claude Code release." >&2
            exit 1
            ;;
    esac
}

utils_check_version() {
    if ! [[ "$1" =~ ^(latest|[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.-]+)?)$ ]]; then
        echo "Invalid Claude Code version: $1" >&2
        exit 1
    fi
}

verify_sha256() {
    local sumsFile="$1"
    local assetName="$2"
    local assetPath="$3"
    local expected
    expected="$(awk -v n="$assetName" '$2 == n { print $1; exit }' "$sumsFile")"
    if [ -z "$expected" ]; then
        echo "SHA256 entry for $assetName not found in $sumsFile" >&2
        return 1
    fi
    local actual
    actual="$(sha256sum "$assetPath" | awk '{ print $1 }')"
    if [ "$expected" != "$actual" ]; then
        echo "SHA256 mismatch for $assetName: expected $expected, got $actual" >&2
        return 1
    fi
}

tempDirectory=''

install_claude_code() {
    local requestedVersion="${VERSION:-latest}"
    local version
    local architecture
    local libc
    local assetName
    local downloadBase
    local sumsFile

    utils_check_version "$requestedVersion"
    check_required_tools

    architecture="$(uname -m)"
    case "$architecture" in
        x86_64) architecture='x64' ;;
        aarch64) architecture='arm64' ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac

    if ldd --version 2>&1 | head -n 1 | grep -qi musl; then
        libc='-musl'
    else
        libc=''
    fi

    if [ "$requestedVersion" = 'latest' ]; then
        version="$(github_get_latest_release)"
    else
        version="$requestedVersion"
    fi

    assetName="claude-linux-${architecture}${libc}.tar.gz"
    downloadBase="https://github.com/${githubRepository}/releases/download/v${version}"
    echo "Installing Claude Code $version..."
    tempDirectory="$(mktemp -d)"
    trap 'rm -rf "$tempDirectory"' EXIT

    curl --fail --silent --show-error --location --connect-timeout 5 \
        -o "$tempDirectory/$assetName" "$downloadBase/$assetName"
    curl --fail --silent --show-error --location --connect-timeout 5 \
        -o "$tempDirectory/SHASUMS256.txt" "$downloadBase/SHASUMS256.txt"

    sumsFile="$tempDirectory/SHASUMS256.txt"
    verify_sha256 "$sumsFile" "$assetName" "$tempDirectory/$assetName"

    tar -xzf "$tempDirectory/$assetName" -C "$tempDirectory"
    mkdir -p "$binaryTargetFolder"
    install -m 0755 "$tempDirectory/$binaryName" "$binaryTargetFolder/$binaryName"
}

install_claude_code
claude --version
