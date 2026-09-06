#!/bin/bash
set -o errexit
set -o pipefail
set -o noclobber
set -o nounset

readonly npmScope='@opencode-ai'
readonly npmPackagePrefix='cli-linux'
readonly binaryName='opencode2'
readonly binaryTargetFolder='/usr/local/bin'
readonly registryBase='https://registry.npmjs.org'

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

apt_get_checkinstall() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends --no-install-suggests --option 'Debug::pkgProblemResolver=true' --option 'Debug::pkgAcquire::Worker=1' "$@"
    fi
}

apt_get_cleanup() {
    apt-get clean
    rm -rf /var/lib/apt/lists/*
}

check_curl_tar_installed() {
    declare -a requiredAptPackagesMissing=()
    if ! [ -r '/etc/ssl/certs/ca-certificates.crt' ]; then
        requiredAptPackagesMissing+=('ca-certificates')
    fi
    if ! command -v curl >/dev/null 2>&1; then
        requiredAptPackagesMissing+=('curl')
    fi
    if ! command -v tar >/dev/null 2>&1; then
        requiredAptPackagesMissing+=('tar')
    fi
    declare -i requiredAptPackagesMissingCount=${#requiredAptPackagesMissing[@]}
    if [ $requiredAptPackagesMissingCount -gt 0 ]; then
        apt_get_update
        apt_get_checkinstall "${requiredAptPackagesMissing[@]}"
        apt_get_cleanup
    fi
}

echo_banner() {
    local text="$1"
    echo -e "\e[1m\e[97m\e[41m$text\e[0m"
}

debian_get_arch() {
    local arch
    arch=$(uname -m)
    if [[ "$arch" == "aarch64" ]]; then
        arch="arm64"
    elif [[ "$arch" == "x86_64" ]]; then
        arch="x64"
    fi
    echo "$arch"
}

utils_check_version() {
    local version=$1
    if ! [[ "${version:-}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        printf >&2 '=== [ERROR] Option "version" (value: "%s") must be an npm dist-tag or version made up of letters, numbers, dots, underscores and hyphens!\n' \
            "$version"
        exit 1
    fi
}

npm_urlencode_package_name() {
    local name=$1
    name="${name//@/%40}"
    name="${name//\//%2f}"
    echo "$name"
}

npm_resolve_tarball_url() {
    local packageName=$1
    local version=$2
    local encodedPackageName
    encodedPackageName="$(npm_urlencode_package_name "$packageName")"
    local manifestUrl="${registryBase}/${encodedPackageName}/${version}"
    local manifest
    manifest=$(curl --silent --show-error --fail --location --connect-timeout 5 "$manifestUrl") || {
        echo "Failed to resolve '$packageName' at version/tag '$version' from '$manifestUrl'." >&2
        return 1
    }
    local tarballUrl
    tarballUrl=$(printf '%s' "$manifest" | grep -oE '"tarball"\s*:\s*"[^"]+"' | head -n1 | sed -E 's/.*"tarball"\s*:\s*"([^"]+)"/\1/')
    if [ -z "$tarballUrl" ]; then
        echo "Could not find a tarball URL for '$packageName' at version/tag '$version'." >&2
        return 1
    fi
    echo "$tarballUrl"
}

install() {
    utils_check_version "$VERSION"
    check_curl_tar_installed
    local architecture
    architecture="$(debian_get_arch)"
    local packageName="${npmScope}/${npmPackagePrefix}-${architecture}"
    local tarballUrl
    tarballUrl="$(npm_resolve_tarball_url "$packageName" "$VERSION")"
    local tempFile
    tempFile=$(mktemp)
    curl --silent --show-error --fail --location --connect-timeout 5 --output "$tempFile" "$tarballUrl"
    tar -xzf "$tempFile" -C "$binaryTargetFolder" --strip-components=2 "package/bin/${binaryName}"
    rm "$tempFile"
    chmod 755 "${binaryTargetFolder}/${binaryName}"
}

echo_banner "devcontainer.community"
echo "Installing ${binaryName}..."
install "$@"
echo "(*) Done!"
