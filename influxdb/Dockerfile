# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
#
# InfluxDB v2.x — Home Assistant App.
#
# Builds on top of the official InfluxData image (Debian-based, multi-arch
# amd64/arm64) instead of a HA base image: the influxd binary and the
# upstream init logic (/entrypoint.sh, DOCKER_INFLUXDB_INIT_MODE, etc.) are
# the ones InfluxData itself tests. s6-overlay v3 + bashio are layered on
# top by hand, the same way bambu-studio-api does it on ubuntu:24.04.
#
# IMPORTANT: the tag is always pinned explicitly. Since 27 May 2026 the
# `latest`/`2` tags on Docker Hub point to InfluxDB 3 Core, not the 2.x
# series anymore — an unpinned FROM would silently break compatibility with
# an existing v2 database.
FROM influxdb:2.8.0

ARG S6_OVERLAY_VERSION=3.2.0.2
ARG BASHIO_VERSION=v0.16.2
ARG TARGETARCH

LABEL org.opencontainers.image.title="Home Assistant App: InfluxDB"
LABEL org.opencontainers.image.description="InfluxDB v2.x time-series database, for Home Assistant long-term history and any other time-series data."
LABEL org.opencontainers.image.source="https://github.com/naked-head/homeassistant-addons"
LABEL org.opencontainers.image.authors="naked-head"
LABEL org.opencontainers.image.licenses="MIT"

# jq/curl/ca-certificates/xz-utils are only needed to bootstrap s6-overlay
# and bashio below; the official InfluxDB image doesn't include them.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        xz-utils \
        jq \
    && rm -rf /var/lib/apt/lists/*

# s6-overlay v3 (the HA add-on supervision layer)
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
        amd64) S6_ARCH=x86_64 ;; \
        arm64) S6_ARCH=aarch64 ;; \
        *)     S6_ARCH=x86_64 ;; \
    esac; \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
        | tar -Jxpf - -C /; \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" \
        | tar -Jxpf - -C /

# bashio (the HA add-on config helper used in the s6 run script)
RUN set -eux; \
    mkdir -p /tmp/bashio; \
    curl -fsSL "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" \
        | tar -xzf - --strip-components=1 -C /tmp/bashio; \
    mv /tmp/bashio/lib /usr/lib/bashio; \
    ln -s /usr/lib/bashio/bashio /usr/bin/bashio; \
    rm -rf /tmp/bashio

# s6-overlay v3 installs `with-contenv` at /command/with-contenv, but the
# conventional HA add-on shebang line "#!/usr/bin/with-contenv bashio" (used
# by every HA base-* image) expects it at /usr/bin/with-contenv. Without
# this symlink, s6-supervise fails to spawn the run script with "No such
# file or directory" because the kernel can't resolve the interpreter path
# in the shebang.
RUN ln -s /command/with-contenv /usr/bin/with-contenv

# HA add-on s6 service plumbing
COPY rootfs /
RUN chmod a+x /etc/services.d/influxdb/run \
              /etc/services.d/influxdb/finish

EXPOSE 8086/tcp

ENTRYPOINT ["/init"]
