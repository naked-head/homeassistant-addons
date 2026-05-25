FROM ghcr.io/maziggy/bambuddy:latest

# Copy our S6-less startup wrapper
COPY rootfs/etc/services.d/bambuddy/run /start.sh
RUN chmod a+x /start.sh

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
