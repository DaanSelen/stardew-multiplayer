# Stardew Valley Multiplayer Server (Docker)

This container is thanks to:<br>
https://github.com/printfuck/stardew-multiplayer-docker

But the reason I made this adaptation is because I saw that the code in the above repository is becoming quite old.<br>
In particular the Debian version, at the moment was 10, which is slowly becoming deprecated.<br>

Therefor this project, it tries to modernize the packages with the same functionality.

# Getting the game files.

Getting the game files is arguably the hardest part. I love this game, and I do recommend buying it for yourself.<br>
It is possible to download the files from my server, but I do not condone this for anything else than the host of your server.<br>
Have fun!

# Building the image:

Once you clone this repository you can build the image using the following command:
```sh
docker build -f docker/Dockerfile . -t stardew-server:latest
```
If you want to integrate the building directory into the compose, you can use the following:
```yaml
services:
  stardew:
    restart: unless-stopped
    container_name: stardew-server
    build:
      context: .
      dockerfile: docker/Dockerfile
#    image: stardew:latest
    ports:
      - "3001:3001/tcp"
      - "24642:24642/udp"
    volumes:
      - config:/config
      - saves:/config/.config/StardewValley/Saves
#    deploy:
#      resources:
#        reservations:
#          devices:
#            - driver: nvidia
#              count: 1
#              capabilities: [gpu]
volumes:
  config:
  saves:
```
This compose creates the image from the source code once you type `docker compose up -d` with the -d meaning detached (in the background).

# CREDITS:

Mods:<br>
- [Always On Server For Multiplayer](https://github.com/perkmi/Always-On-Server-for-Multiplayer)<br>
- [Automate](https://www.nexusmods.com/stardewvalley/mods/1063)<br>
- [Auto Load Game](https://www.nexusmods.com/stardewvalley/mods/2509)<br>
- [Default On Cheats](https://www.nexusmods.com/stardewvalley/mods/21035)<br>
- [Multi-User Chests](https://www.nexusmods.com/stardewvalley/mods/9856)<br>
- [No Fence Decay Redux](https://www.nexusmods.com/stardewvalley/mods/20802)<br>
- [Non Destructive NPCs](https://forums.stardewvalley.net/threads/unofficial-mod-updates.2096/page-132#post-121034)<br>
- [Skip Intro](https://www.nexusmods.com/stardewvalley/mods/533)<br>
- [Unlimited Players](https://www.nexusmods.com/stardewvalley/mods/2213)<br>

Kind Regards.