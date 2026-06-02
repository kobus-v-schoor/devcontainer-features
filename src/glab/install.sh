#!/usr/bin/env bash

GLAB_VERSION="${VERSION:-"latest"}"

set -e

echo "Installing GitLab CLI (glab)..."

if [ "${GLAB_VERSION}" = "none" ]; then
    echo "Skipping installation per 'none' version option."
    exit 0
fi

# Install required dependencies if missing
if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -qq
        apt-get install -y -qq --no-install-recommends curl ca-certificates tar
        rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache curl ca-certificates tar
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y curl ca-certificates tar
    elif command -v yum >/dev/null 2>&1; then
        yum install -y curl ca-certificates tar
    else
        echo "(!) Package manager not found. Please install curl, ca-certificates, and tar manually."
        exit 1
    fi
fi

architecture=""
uname_m_out=$(uname -m 2>/dev/null || true)
case "${uname_m_out}" in
    x86_64)
        architecture="amd64"
        ;;
    aarch64 | arm64)
        architecture="arm64"
        ;;
    armv6l | armv7l)
        architecture="armv6"
        ;;
    *)
        echo "(!) Architecture ${uname_m_out} not supported by glab."
        exit 1
        ;;
esac

echo "Target architecture: ${architecture}"

if [ "${GLAB_VERSION}" = "latest" ]; then
    echo "Discovering latest glab version..."
    release_json=$(curl -fsSL -H "Accept: application/json" --max-time 30 \
        "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest")
    GLAB_VERSION=$(echo "${release_json}" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p')
    if [ -z "${GLAB_VERSION}" ]; then
        echo "(!) Failed to discover latest glab version."
        exit 1
    fi
    echo "Latest version detected: ${GLAB_VERSION}"
fi

# Strip leading 'v' for URL consistency
version_for_url="${GLAB_VERSION#v}"

tarball="glab_${version_for_url}_linux_${architecture}.tar.gz"
download_url="https://gitlab.com/gitlab-org/cli/-/releases/v${version_for_url}/downloads/${tarball}"

echo "Downloading ${tarball}..."
TEMPDIR=$(mktemp -d)
trap 'rm -rf "${TEMPDIR}"' EXIT

curl -fsSL --max-time 120 -o "${TEMPDIR}/${tarball}" "${download_url}"

echo "Extracting..."
tar -xzf "${TEMPDIR}/${tarball}" -C "${TEMPDIR}"

bin_path="${TEMPDIR}/bin/glab"
if [ ! -f "${bin_path}" ]; then
    # Some older packaging may have flat layout
    bin_path="${TEMPDIR}/glab"
fi

if [ ! -f "${bin_path}" ]; then
    echo "(!) Could not find glab binary in extracted tarball."
    ls -la "${TEMPDIR}"
    exit 1
fi

cp "${bin_path}" /usr/local/bin/glab
chmod +x /usr/local/bin/glab

# Verify
installed_version=$(glab --version 2>/dev/null || true)
echo "GitLab CLI installed: ${installed_version}"

echo "Done!"
