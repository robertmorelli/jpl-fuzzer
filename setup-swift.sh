#!/bin/bash

set -e

echo "Setting up Swift"

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Install required dependencies without removing anything later
echo "Installing dependencies..."
apt-get update -q && apt-get install -q -y --no-install-recommends \
    binutils \
    git \
    unzip \
    gnupg2 \
    libc6-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgcc-13-dev \
    libpython3-dev \
    libsqlite3-0 \
    libstdc++-13-dev \
    libxml2-dev \
    libncurses-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    zlib1g-dev \
    curl

# Define Swift installation variables
SWIFT_SIGNING_KEY="52BB7E3DE28A71BE22EC05FFEF80A866B47A981F"
SWIFT_PLATFORM="ubuntu24.04"
SWIFT_BRANCH="swift-6.0.3-release"
SWIFT_VERSION="swift-6.0.3-RELEASE"
SWIFT_WEBROOT="https://download.swift.org"

# Detect architecture
ARCH_NAME="$(dpkg --print-architecture)"
OS_ARCH_SUFFIX=""

case "${ARCH_NAME##*-}" in
    'amd64') OS_ARCH_SUFFIX='' ;;
    'arm64') OS_ARCH_SUFFIX='-aarch64' ;;
    *) echo >&2 "Error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;;
esac

# Construct Swift download URLs
SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)$OS_ARCH_SUFFIX"
SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM$OS_ARCH_SUFFIX.tar.gz"
SWIFT_SIG_URL="$SWIFT_BIN_URL.sig"

# Create temp directory for GPG
export GNUPGHOME="$(mktemp -d)"

# Download Swift and verify signature
echo "Downloading Swift toolchain..."
curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz
curl -fsSL "$SWIFT_SIG_URL" -o swift.tar.gz.sig

echo "Importing Swift GPG key and verifying signature..."
gpg --batch --quiet --keyserver keyserver.ubuntu.com --recv-keys "$SWIFT_SIGNING_KEY"
gpg --batch --verify swift.tar.gz.sig swift.tar.gz

# Extract Swift toolchain
echo "Extracting Swift toolchain..."
tar -xzf swift.tar.gz --directory / --strip-components=1

# Set permissions
chmod -R o+r /usr/lib/swift

# Cleanup only temporary files (no system package removals)
rm -rf "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz

# Print installed Swift version
echo "Swift installation complete!"
swift --version
