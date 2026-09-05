#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" before running this script.' >&2
    exit 1
fi

readonly appName='opencode2'
readonly installScriptUrl='https://opencode.ai/v2/install'
readonly binaryName='opencode2'
readonly binaryTargetFolder='/usr/local/bin'

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
        apt_get_checkinstall "${missing[@]}"
        apt_get_cleanup
    fi
}

curl_check_url() {
    local url=$1
    local status_code
    status_code=$(curl --silent --output /dev/null --write-out '%{http_code}' "$url")
    if [ "$status_code" -ne 200 ] && [ "$status_code" -ne 302 ]; then
        echo "Failed to download '$url'. Status code: $status_code." >&2
        return 1
    fi
}

curl_download_stdout() {
    curl --fail --silent --show-error --location --connect-timeout 5 "$1"
}

utils_check_version() {
    local version=$1
    if ! [[ "${version:-}" =~ ^(latest|[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?)$ ]]; then
        printf >&2 '=== [ERROR] Option "version" (value: "%s") is not "latest" or a valid version string (e.g. "0.0.0-beta-19157") !\n' \
            "$version"
        exit 1
    fi
}

tempHome=''
installerPath=''

cleanup() {
    if [ -n "$tempHome" ]; then
        rm -rf "$tempHome"
    fi
    if [ -n "$installerPath" ]; then
        rm -f "$installerPath"
    fi
}

# Installs the opencode2 binary into ${binaryTargetFolder} by running the
# official OpenCode V2 installer.
install_opencode2() {
    local requestedVersion="${VERSION:-latest}"
    local installedBinaryPath

    utils_check_version "$requestedVersion"
    check_required_tools

    installerPath="$(mktemp)"
    tempHome="$(mktemp -d)"
    trap cleanup EXIT

    curl_check_url "$installScriptUrl"
    curl_download_stdout "$installScriptUrl" >"$installerPath"

    # 'latest' is this Feature's own sentinel; the installer resolves it to the
    # npm 'beta' dist-tag when no version is requested, so never forward it.
    local -a installerArgs=('--no-modify-path')
    if [ "$requestedVersion" != 'latest' ]; then
        installerArgs+=('--version' "$requestedVersion")
    fi

    # The installer stages the binary under ${HOME}/.opencode/bin and offers no
    # way to override that, so run it against a throwaway HOME to keep the real
    # user home clean. VERSION is cleared because the installer reads it as its
    # own option.
    #
    # ${binaryTargetFolder} is dropped from the child PATH because the installer
    # exits early (without staging a binary) when it finds a matching version
    # already installed. Every other PATH entry is kept so tooling resolved by
    # the parent script, such as curl, stays reachable.
    local installerChildPath
    installerChildPath="$(printf '%s' "$PATH" \
        | tr ':' '\n' \
        | grep -Fxv "$binaryTargetFolder" \
        | paste -sd: - || true)"
    if [ -z "$installerChildPath" ]; then
        installerChildPath='/usr/sbin:/usr/bin:/sbin:/bin'
    fi

    env -u VERSION \
        HOME="$tempHome" \
        PATH="$installerChildPath" \
        SHELL="${SHELL:-/bin/bash}" \
        bash "$installerPath" "${installerArgs[@]}"

    installedBinaryPath="${tempHome}/.opencode/bin/${binaryName}"
    if [ ! -x "$installedBinaryPath" ]; then
        echo "Expected '${installedBinaryPath}' to exist after running the installer." >&2
        exit 1
    fi

    # Publish the binary on the system PATH so every user of the container can
    # run it, not only the user that built the image.
    # 'command' bypasses shell functions: were this function named 'install',
    # the coreutils call below would recurse back into it forever.
    mkdir -p "$binaryTargetFolder"
    command install -m 0755 "$installedBinaryPath" "${binaryTargetFolder}/${binaryName}"
    cleanup
    trap - EXIT
}

echo "Installing $appName..."
install_opencode2
"${binaryTargetFolder}/${binaryName}" --version
echo "(*) Done!"
