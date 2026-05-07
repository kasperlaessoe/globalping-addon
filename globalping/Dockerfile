# BUILD_FROM is supplied by the Home Assistant supervisor at build time
# and selects the per-arch base image. Declared at the top so it is a
# global ARG visible to every FROM stage.
ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.1.1

# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Globalping probe pins itself to an exact Node version (currently
# v22.16.0) and tries to nvm-install that version on startup if it does
# not match. nvm fetches from nodejs.org/dist which does not host musl
# builds, so we install Node from unofficial-builds.nodejs.org at build
# time instead. This guarantees process.version === wanted version and
# disables the noisy self-update path entirely.
ARG NODE_VERSION=22.16.0

# Copy root filesystem
COPY rootfs /

# Install runtime dependencies for the Globalping probe.
# - coreutils replaces BusyBox df/du so the probe's `df --block-size=MB`
#   call works.
# - util-linux / util-linux-misc provide lscpu.
# - libstdc++ is required by Node native modules (e.g. better-sqlite3).
# hadolint ignore=DL3018
RUN apk add --no-cache \
        bash \
        bind-tools \
        ca-certificates \
        coreutils \
        curl \
        expect \
        iputils \
        jq \
        libstdc++ \
        mtr \
        tar \
        tini \
        traceroute \
        util-linux \
        util-linux-misc \
        xz \
    && update-ca-certificates

# Install Node.js (musl) at the exact pinned version.
# hadolint ignore=DL3018
RUN set -eux; \
    arch="$(uname -m)"; \
    case "${arch}" in \
        x86_64) node_arch=x64 ;; \
        aarch64) node_arch=arm64 ;; \
        *) echo "unsupported arch: ${arch}"; exit 1 ;; \
    esac; \
    url="https://unofficial-builds.nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}-musl.tar.xz"; \
    curl -fsSL "${url}" -o /tmp/node.tar.xz; \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
        --exclude='*/CHANGELOG.md' --exclude='*/LICENSE' --exclude='*/README.md'; \
    rm -f /tmp/node.tar.xz; \
    node --version; \
    chmod +x /etc/globalping/entrypoint.sh

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Kasper Laesso Sorensen <kasper@laessoerensen.dk>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Globalping Home Assistant Addon" \
    org.opencontainers.image.authors="Kasper Laesso Sorensen <kasper@laessoerensen.dk>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/kasperlaessoe/globalping-addon" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
