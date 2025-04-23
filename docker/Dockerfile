# Base image
FROM linuxserver/webtop:debian-i3

ARG SMAPI_VERSION="4.2.1"

RUN apt-get update \
    && apt-get install -y \
        xterm \
        curl \
        libstdc++6 \
        #build-essential \
        libc6 \
        libicu-dev \
        unzip \
    && mkdir -p /data/nexus \
    && mkdir -p /custom-cont-init.d \
    && mkdir -p /ephemerality \
    && mkdir -p /config/always_on_server \
    && apt-get upgrade -y

# DOTNET SDK
RUN curl -o /tmp/dotnet-install.sh https://raw.githubusercontent.com/dotnet/install-scripts/refs/heads/main/src/dotnet-install.sh \
    && bash /tmp/dotnet-install.sh --install-dir /usr/local/share/dotnet \
    && echo "export PATH=$PATH:/usr/local/share/dotnet" >> /etc/profile

# Please do NOT pirate this, I do NOT condone it. This is here for the purpose of the server.
COPY ./latest.tar.gz /tmp/latest.tar.gz
#RUN curl -L -o /tmp/latest.tar.gz https://cloud.nerthus.nl/s/Hz88KtpRdB8bnQi/download/latest.tar.gz \
RUN tar zxf /tmp/latest.tar.gz -C /data \
    && rm /tmp/latest.tar.gz \
    && mv /data/Stardew\ Valley /data/stardewvalley \
\
    && curl -L -o /tmp/nexus.zip https://github.com/Pathoschild/SMAPI/releases/download/${SMAPI_VERSION}/SMAPI-${SMAPI_VERSION}-installer.zip \
    && unzip /tmp/nexus.zip -d /data/nexus \
    && SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true \
    /bin/bash -c '/data/nexus/SMAPI\ ${SMAPI_VERSION}\ installer/internal/linux/SMAPI.Installer --install --game-path "/data/stardewvalley" <<< "2"' \
\
    && curl -L -o /tmp/always_on_server.zip https://github.com/perkmi/Always-On-Server-for-Multiplayer/releases/latest/download/Always.On.Server.zip \
    && unzip /tmp/always_on_server.zip -d /data/stardewvalley/Mods

# Copy predefined mods
COPY ./mods /data/stardewvalley/Mods

# Place the entrypoint which actually starts Stardew Valley!
COPY ./docker/entrypoint.sh /custom-cont-init.d/99-entrypoint.sh

# Copy assets
COPY ./assets/configure-i3.sh /custom-cont-init.d/00-configure-i3.sh
COPY ./assets/always_on_server_config.json /config/always_on_server/config.json

VOLUME /config/autoload
VOLUME /config/.config/StardewValley/Saves

WORKDIR /data
