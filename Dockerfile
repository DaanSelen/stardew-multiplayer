# Install Microsoft's DotNet for the game

FROM alpine:latest AS dotnet-installer

RUN apk add --no-cache \
        bash curl \
    && curl -o /tmp/dotnet-install.sh https://raw.githubusercontent.com/dotnet/install-scripts/refs/heads/main/src/dotnet-install.sh \
    && bash /tmp/dotnet-install.sh --install-dir /usr/local/share/dotnet

# Download the Stardew Valley game files from Steam (bypasses self-packaging)

FROM steamcmd/steamcmd:debian-trixie AS steam-downloader

ARG STEAM_USER
ARG STEAM_PASS

RUN if [ -n "$STEAM_USER" ] && [ -n "$STEAM_PASS" ]; then \
      echo "Trying to use Steam credentials!"; \
      steamcmd +force_install_dir /tmp/stardew +login ${STEAM_USER} ${STEAM_PASS} +app_update 413150 +quit; \
    else \
      mkdir /tmp/stardew; \
      echo "Steam username or Password not provided"; \
    fi

# Unpack Stardew Valley
FROM debian:stable-slim AS unpacker
# You'll need to supply your own Stardew Valley game files, in the followin name: 'latest.tar.gz' or change the following line.

ARG METHOD="LOCAL"
ARG SMAPI_VERSION="4.4.0"

RUN apt-get update \
    && apt-get install -y \
        curl \
        unzip \
        libicu-dev

### UNPACKER PROVIDE GAME FILES
COPY ./latest.tar.gz /tmp/local-stardew.tar.gz
COPY --from=steam-downloader /tmp/stardew /tmp/steam-stardew

RUN mkdir -p /game/nexus; \
    echo "METHOD: $METHOD"; \
    if [ "$METHOD" = "LOCAL" ]; then \
        tar -zxf /tmp/local-stardew.tar.gz -C /game; \
        \
        if [ -d "/game/Stardew Valley" ]; then \
            echo "Renaming Stardew Valley folder."; \
            mv -v "/game/Stardew Valley" "/game/stardewvalley"; \
        fi; \
    elif [ "$METHOD" = "STEAM" ]; then \
        mv /tmp/steam-stardew /game/stardewvalley; \
    fi; \
    rm -rfv /tmp/*-stardew.*

RUN curl -L -o /tmp/nexus.zip https://github.com/Pathoschild/SMAPI/releases/download/${SMAPI_VERSION}/SMAPI-${SMAPI_VERSION}-installer.zip \
    && unzip /tmp/nexus.zip -d /game/nexus \
    && SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true \
    /bin/bash -c '/game/nexus/SMAPI\ ${SMAPI_VERSION}\ installer/internal/linux/SMAPI.Installer --install --game-path "/game/stardewvalley" <<< "2"'

RUN curl -L -o /tmp/always_on_server.zip https://github.com/perkmi/Always-On-Server-for-Multiplayer/releases/latest/download/Always.On.Server.zip \
    && unzip /tmp/always_on_server.zip -d /game/stardewvalley/Mods \
    && apt-get clean \
    && rm -rf /var/cache/*

# Base image
FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie AS final

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
