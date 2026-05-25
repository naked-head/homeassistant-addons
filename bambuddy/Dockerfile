ARG BUILD_FROM
FROM ghcr.io/maziggy/bambuddy:latest AS bambuddy
FROM ${BUILD_FROM}

# Copy entire BamBuddy filesystem from official image
COPY --from=bambuddy /app /app
COPY --from=bambuddy /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --from=bambuddy /usr/local /usr/local

# Copy our S6 run scripts
COPY rootfs /

# Make scripts executable
RUN chmod a+x /etc/services.d/bambuddy/run \
    && chmod a+x /etc/services.d/bambuddy/finish \
    && chmod a+x /usr/local/bin/docker-entrypoint.sh

WORKDIR /app

# Expose ports
EXPOSE 8000 1883 8883 2222
