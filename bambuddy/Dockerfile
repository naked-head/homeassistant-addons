ARG BUILD_FROM
FROM ghcr.io/maziggy/bambuddy:latest AS bambuddy
FROM ${BUILD_FROM}

# Copy entire BamBuddy filesystem from official image
COPY --from=bambuddy /app /app
COPY --from=bambuddy /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --from=bambuddy /usr/local /usr/local
COPY --from=bambuddy /usr/sbin/gosu /usr/sbin/gosu

# Copy our S6 run scripts
COPY rootfs /

# Make scripts executable
RUN chmod a+x /etc/services.d/bambuddy/run \
    && chmod a+x /etc/services.d/bambuddy/finish \
    && chmod a+x /usr/local/bin/docker-entrypoint.sh \
    && chmod a+x /usr/sbin/gosu

WORKDIR /app

# Web UI
EXPOSE 8000/tcp
# Slicer bind/detect
EXPOSE 3000/tcp
EXPOSE 3002/tcp
# SSDP discovery
EXPOSE 2021/udp
# MQTT over TLS
EXPOSE 8883/tcp
# File transfer tunnel
EXPOSE 6000/tcp
# RTSP camera (X1/H2/P2)
EXPOSE 322/tcp
# FTPS control
EXPOSE 990/tcp
# Proprietary slicer ports (A1/P1S)
EXPOSE 2024/tcp
EXPOSE 2025/tcp
EXPOSE 2026/tcp
# FTP passive data
EXPOSE 50000-50100/tcp
