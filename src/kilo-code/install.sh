#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root.' >&2
    exit 1
fi

readonly githubRepository='Kilo-Org/kilocode'
readonly binaryName='kilo'
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

curl_download_stdout() {
    curl --fail --silent --show-error --location --connect-timeout 5 "$1"
}

github_get_latest_release() {
    local latestUrl
    latestUrl="$(curl --fail --silent --show-error --location \
        --output /dev/null --write-out '%{url_effective}' \
        "https://github.com/${githubRepository}/releases/latest")"
    case "$latestUrl" in
        */releases/tag/v*) printf '%s\n' "${latestUrl##*/releases/tag/v}" ;;
        *)
            echo "Unable to determine the latest Kilo Code release." >&2
            exit 1
            ;;
    esac
}

utils_check_version() {
    if ! [[ "$1" =~ ^(latest|[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.-]+)?)$ ]]; then
        echo "Invalid Kilo Code CLI version: $1" >&2
        exit 1
    fi
}

tempDirectory=''

install_kilo() {
    local requestedVersion="${VERSION:-latest}"
    local version
    local architecture
    local downloadUrl

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

    if [ "$requestedVersion" = 'latest' ]; then
        version="$(github_get_latest_release)"
    else
        version="$requestedVersion"
    fi

    downloadUrl="https://github.com/${githubRepository}/releases/download/v${version}/${binaryName}-linux-${architecture}.tar.gz"
    echo "Installing Kilo Code CLI $version..."
    tempDirectory="$(mktemp -d)"
    trap 'rm -rf "$tempDirectory"' EXIT
    curl_download_stdout "$downloadUrl" | tar -xzf - -C "$tempDirectory"
    mkdir -p "$binaryTargetFolder"
    install -m 0755 "$tempDirectory/$binaryName" "$binaryTargetFolder/$binaryName"
}

install_kilo
kilo --version
