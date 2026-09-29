#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" before running this script.' >&2
    exit 1
fi

readonly appName='opencode2'
readonly installScriptUrl='https://opencode.ai/v2/install'
readonly binaryTargetFolder='/usr/local/bin'
readonly opencode2LibDir='/usr/local/lib/opencode2/bin'
readonly binaryName='opencode'
readonly shimName='opencode2'
readonly defaultDbName='opencode2.db'

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
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y "${missing[@]}"
        elif command -v yum >/dev/null 2>&1; then
            yum install -y "${missing[@]}"
        elif command -v pacman >/dev/null 2>&1; then
            pacman -Sy --noconfirm "${missing[@]}"
        elif command -v zypper >/dev/null 2>&1; then
            zypper install -y "${missing[@]}"
        else
            echo "=== [ERROR] Missing required packages: ${missing[*]}. Could not find a supported package manager (apt-get, apk, dnf, yum, pacman, zypper)." >&2
            exit 1
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

    # Install the OpenCode 2 binary in a dedicated directory to prevent collisions with opencode v1
    mkdir -p "$opencode2LibDir"
    command install -m 0755 "${tempHome}/.opencode/bin/${binaryName}" "${opencode2LibDir}/${binaryName}"

    # Detect opencode v1 (e.g. from the opencode feature). A symlink back to our own
    # shim is left over from a previous opencode2-only install and does not count.
    local opencodeV1Present='false'
    if [ -e "${binaryTargetFolder}/${binaryName}" ] \
        && [ "$(readlink -f "${binaryTargetFolder}/${binaryName}")" != "$(readlink -f "${binaryTargetFolder}/${shimName}")" ]; then
        opencodeV1Present='true'
    fi

    mkdir -p "$binaryTargetFolder"
    if [ "$opencodeV1Present" = 'true' ]; then
        # Both versions installed: give OpenCode 2 its own database (via OPENCODE_DB) so it
        # never migrates the one opencode v1 uses. Relative paths resolve under the opencode
        # data dir. OPENCODE2_DB overrides it; a global OPENCODE_DB is ignored on purpose.
        echo "Existing '${binaryTargetFolder}/${binaryName}' detected; keeping it and using '${shimName}' for OpenCode 2 with a separate database."
        cat << EOF > "${binaryTargetFolder}/${shimName}"
#!/bin/sh
OPENCODE_DB="\${OPENCODE2_DB:-${defaultDbName}}"
export OPENCODE_DB
exec ${opencode2LibDir}/${binaryName} "\$@"
EOF
        chmod 755 "${binaryTargetFolder}/${shimName}"
    else
        # OpenCode 2 alone: plain wrapper using the upstream default database, and link
        # /usr/local/bin/opencode to it.
        cat << EOF > "${binaryTargetFolder}/${shimName}"
#!/bin/sh
exec ${opencode2LibDir}/${binaryName} "\$@"
EOF
        chmod 755 "${binaryTargetFolder}/${shimName}"
        ln -sf "${binaryTargetFolder}/${shimName}" "${binaryTargetFolder}/${binaryName}"
    fi

    cleanup
    trap - EXIT
}

echo "Installing $appName..."
install_opencode2
"${binaryTargetFolder}/${shimName}" --version
echo "(*) Done!"
