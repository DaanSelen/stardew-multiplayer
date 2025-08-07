FROM alpine:latest AS dotnet-installer

RUN apk add --no-cache \
        bash curl \
    && curl -o /tmp/dotnet-install.sh https://raw.githubusercontent.com/dotnet/install-scripts/refs/heads/main/src/dotnet-install.sh \
    && bash /tmp/dotnet-install.sh --install-dir /usr/local/share/dotnet

# Unpack Stardew Valley
FROM debian:stable-slim AS unpacker
# You'll need to supply your own Stardew Valley game files, in the followin name: 'latest.tar.gz' or change the following line.

ARG SMAPI_VERSION="4.3.2"

RUN apt-get update \
    && apt-get install -y \
        curl \
        unzip \
        libicu-dev

COPY ./latest.tar.gz /tmp/latest.tar.gz
RUN mkdir -p /game/nexus \
    && tar zxf /tmp/latest.tar.gz -C /game \
    && rm /tmp/latest.tar.gz \
    && mv /game/Stardew\ Valley /game/stardewvalley

RUN curl -L -o /tmp/nexus.zip https://github.com/Pathoschild/SMAPI/releases/download/${SMAPI_VERSION}/SMAPI-${SMAPI_VERSION}-installer.zip \
    && unzip /tmp/nexus.zip -d /game/nexus \
    && SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true \
    /bin/bash -c '/game/nexus/SMAPI\ ${SMAPI_VERSION}\ installer/internal/linux/SMAPI.Installer --install --game-path "/game/stardewvalley" <<< "2"'

RUN curl -L -o /tmp/always_on_server.zip https://github.com/perkmi/Always-On-Server-for-Multiplayer/releases/latest/download/Always.On.Server.zip \
    && unzip /tmp/always_on_server.zip -d /game/stardewvalley/Mods \
    && apt-get clean \
    && rm -rf /var/cache/*

# Base image
FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

RUN apt-get update \
    && apt-get install -y \
        xterm \
        curl \
        libstdc++6 \
        libc6 \
        libicu-dev \
        libx11-6 \
        libgl1 \
        mangohud \
        mesa-utils

RUN mkdir -p /custom-cont-init.d \
    && mkdir -p /config/.config/MangoHud \
    && mkdir -p /config/modconfs/always_on_server \
    && mkdir -p /config/modconfs/autoload

COPY --from=dotnet-installer /usr/local/share/dotnet /usr/local/share/dotnet
RUN echo "export PATH=$PATH:/usr/local/share/dotnet" >> /etc/profile

COPY --from=unpacker /game /data
COPY ./assets/MangoHud.conf /tmp/MangoHud.conf

# Copy predefined mods
COPY ./mods /data/stardewvalley/Mods

# Place the entrypoint which actually starts Stardew Valley! And other startup scripts
COPY ./scripts/stardew.sh /custom-cont-init.d/10-stardew.sh
COPY ./scripts/tail-smapi.sh /custom-cont-init.d/20-tail-smapi.sh

# JSON Configs
COPY ./assets/always_on_server_config.json /tmp/always_on_server_config.json
COPY ./assets/autoload_config.json /tmp/autoload_config.json

WORKDIR /data

ENV TITLE="Stardew Valley Multiplayer Server" \
  START_DOCKER=false
