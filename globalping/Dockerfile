# BUILD_FROM is supplied by the Home Assistant supervisor at build time
# and selects the per-arch base image. Declared at the top so it is a
# global ARG visible to every FROM stage.
ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.1.1

# Globalping probe pins itself to a specific Node major (currently 22.x)
# and tries to self-update Node via nvm if it doesn't match. nvm can't
# install glibc Node binaries on Alpine, so we provide a Node 22 musl
# build directly from the official node:22-alpine image instead.
# hadolint ignore=DL3007
FROM node:22-alpine AS node22

# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Copy Node 22 (musl) from the official node image.
COPY --from=node22 /usr/local/bin/node /usr/local/bin/node
COPY --from=node22 /usr/local/lib/node_modules /usr/local/lib/node_modules

# Copy root filesystem
COPY rootfs /

# Install runtime dependencies for the Globalping probe.
# - coreutils replaces BusyBox df/du so the probe's `df --block-size=MB`
#   call works.
# - util-linux-misc provides lscpu, which the probe also calls.
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
        util-linux-misc \
    && update-ca-certificates \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && chmod +x /etc/globalping/entrypoint.sh

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
