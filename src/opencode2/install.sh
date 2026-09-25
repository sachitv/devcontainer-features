#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" before running this script.' >&2
    exit 1
fi

readonly appName='opencode2'
readonly installScriptUrl='https://opencode.ai/v2/install'
readonly binaryTargetFolder='/usr/local/bin'
readonly binaryName='opencode'
readonly shimName='opencode2'

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* -maxdepth 0 2>/dev/null | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
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
        if command -v apt-get >/dev/null 2>&1; then
            apt_get_checkinstall "${missing[@]}"
            apt_get_cleanup
        elif command -v apk >/dev/null 2>&1; then
            apk add --no-cache "${missing[@]}"
        fi
    fi
}

utils_check_version() {
    local version="$1"
    if ! [[ "${version:-}" =~ ^(latest|v?[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.-]+)?)$ ]]; then
        printf >&2 '=== [ERROR] Option "version" (value: "%s") is not "latest" or a valid semantic version format "X.Y.Z" !\n' \
            "$version"
        exit 1
    fi
}

install_opencode2() {
    local requestedVersion="${VERSION:-latest}"
    utils_check_version "$requestedVersion"
    check_required_tools

    local tempHome
    local installerPath
    installerPath="$(mktemp)"
    tempHome="$(mktemp -d)"

    cleanup() {
        rm -rf "$tempHome" "$installerPath"
    }
    trap cleanup EXIT

    echo "Downloading OpenCode v2 installer..."
    curl --fail --silent --show-error --location --connect-timeout 5 "$installScriptUrl" > "$installerPath"

    local -a installerArgs=('--no-modify-path')
    if [ "$requestedVersion" != 'latest' ]; then
        local cleanVersion="${requestedVersion#v}"
        installerArgs+=('--version' "$cleanVersion")
    fi

    echo "Running OpenCode v2 installer..."
    env -u VERSION \
        HOME="$tempHome" \
        SHELL="${SHELL:-/bin/bash}" \
        bash "$installerPath" "${installerArgs[@]}"

    if [ ! -x "${tempHome}/.opencode/bin/${binaryName}" ]; then
        echo "Expected '${tempHome}/.opencode/bin/${binaryName}' to exist after running the installer." >&2
        exit 1
    fi

    mkdir -p "$binaryTargetFolder"
    command install -m 0755 "${tempHome}/.opencode/bin/${binaryName}" "${binaryTargetFolder}/${binaryName}"
    if [ -f "${tempHome}/.opencode/bin/${shimName}" ]; then
        command install -m 0755 "${tempHome}/.opencode/bin/${shimName}" "${binaryTargetFolder}/${shimName}"
    else
        ln -sf "${binaryTargetFolder}/${binaryName}" "${binaryTargetFolder}/${shimName}"
    fi

    cleanup
    trap - EXIT
}

echo "Installing $appName..."
install_opencode2
"${binaryTargetFolder}/${shimName}" --version
echo "(*) Done!"
