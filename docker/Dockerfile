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
    && mkdir -p /ephemerality

# DOTNET SDK
RUN curl -o /tmp/dotnet-install.sh https://raw.githubusercontent.com/dotnet/install-scripts/refs/heads/main/src/dotnet-install.sh \
    && bash /tmp/dotnet-install.sh --install-dir /usr/local/share/dotnet \
    && echo "export PATH=$PATH:/usr/local/share/dotnet" >> /etc/profile

RUN apt-get upgrade -y

# Please do NOT pirate this, I do NOT condone it. This is here for the purpose of the server.
RUN curl -L -o /tmp/latest.tar.gz https://cloud.nerthus.nl/s/Hz88KtpRdB8bnQi/download/latest.tar.gz \
    && tar zxf /tmp/latest.tar.gz -C /data \
    && rm /tmp/latest.tar.gz \
    && mv /data/Stardew\ Valley /data/stardewvalley

RUN curl -L -o /tmp/nexus.zip https://github.com/Pathoschild/SMAPI/releases/download/${SMAPI_VERSION}/SMAPI-${SMAPI_VERSION}-installer.zip \
    && unzip /tmp/nexus.zip -d /data/nexus \
    && SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true \
    /bin/bash -c '/data/nexus/SMAPI\ ${SMAPI_VERSION}\ installer/internal/linux/SMAPI.Installer --install --game-path "/data/stardewvalley" <<< "2"'

COPY ./mods /data/stardewvalley/Mods

WORKDIR /data

COPY ./docker/autoload_config.json /config/autoload/config.json

# Make the default i3 message go away for a clean startup.
COPY ./scripts/configure-i3.sh /custom-cont-init.d/00-configure-i3.sh

# Place the entrypoint which actually starts Stardew Valley!
COPY ./docker/entrypoint.sh /custom-cont-init.d/99-entrypoint.sh

VOLUME /config/autoload
VOLUME /config/.config/StardewValley/Saves