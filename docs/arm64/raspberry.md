# Running Stardew Valley on a Raspberry Pi

Welcome to this quick guide on how to run **Stardew Valley** on a **Raspberry Pi**!  
Whether you're looking to turn your Pi into a portable farming station or just love tinkering with Linux-based gaming setups, this guide will walk you through the process step-by-step.

We’ll cover:
- System requirements and recommended Raspberry Pi models
- Installing dependencies and getting started

Let’s get your digital farm up and running!

# Recommended Models:

From my personal experience testing with both the Raspberry Pi model 4 and 5 - I recommend 5 and higher.<br>
The Raspberry Pi 4 runs it fine and dandy, but its not very smooth... even though its running natively.

# Step-by-step guide:

## Automating (most) steps:

All these steps are also done automatically (perhaps with slight modifications) with: https://github.com/DaanSelen/stardew-multiplayer/blob/main/guides/arm64/prepare-raspberry.sh
You can download this script on Linux:
```sh
curl https://raw.githubusercontent.com/DaanSelen/stardew-multiplayer/refs/heads/main/guides/arm64/prepare-raspberry.sh > ~/Desktop/pi-prepare.sh # This places it on the DE's Desktop.
```

## The actual Guide:

Make sure your Raspberry Pi is up to date. You can do this like this:

```sh
sudo apt update && sudo apt full-upgrade -y
```

First off lets get some dependencies installed! Use the following command on Debian (apt)-based systems:

```sh
sudo apt install -y mono-complete libsdl2-2.0-0 libsdl2-dev
```

Then we need to clean up some inferior files that come from the Stardew Valley compat version.

```sh
sudo tar -zvxf compat-latest.tar.gz -C ~/Desktop
```

Then remove some non-working DLLs, mono replaces these with its own.

```sh
sudo rm "~/Desktop/Stardew Valley/System.dll" "~/Desktop/Stardew Valley/System.Core.dll"
```

Get the liblwjgl_lz4 library which Stardew needs:

```sh
sudo wget https://build.lwjgl.org/stable/linux/arm64/liblwjgl_lz4.so -O /lib/aarch64-linux-gnu/liblwjgl_lz.so \
    && sudo chmod +x /lib/aarch64-linux-gnu/liblwjgl_lz.so
```

> [Main URL for ARM64](https://www.lwjgl.org/browse/stable/linux/arm64)

After these steps, replace the "~/Desktop/Stardew Valley/MonoGame.Framework.dll.config" with the following lines.

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
	<dllmap dll="SDL2.dll" os="osx" target="libSDL2.dylib"/>
	<dllmap dll="soft_oal.dll" os="osx" target="libopenal.dylib" />
	<dllmap dll="SDL2.dll" os="linux" cpu="x86" target="./lib/libSDL2-2.0.so.0"/>
	<dllmap dll="soft_oal.dll" os="linux" cpu="x86" target="./lib/libopenal.so.1" />
	<dllmap dll="SDL2.dll" os="linux" cpu="x86-64" target="./lib64/libSDL2-2.0.so.0"/>
	<dllmap dll="soft_oal.dll" os="linux" cpu="x86-64" target="./lib64/libopenal.so.1" />
        <dllmap dll="SDL2.dll" os="linux" cpu="armv8" target="./libaarch64/libSDL2-2.0.so.0"/>
        <dllmap dll="soft_oal.dll" os="linux" cpu="armv8" target="./libaarch64/libopenal.so.1" />
        <dllmap dll="liblwjgl_lz4" os="linux" cpu="armv8" target="./libaarch64/liblwjgl_lz4.so"/>
</configuration>
```

For the next step, place a symbolic link inside the Stardew Valley directory.

```sh
ln -s /lib/aarch64-linux-gnu ~/Desktop/Stardew\ Valley/libaarch64
```

For the last step, to avoid possible openal (audio) errors, do the following.

```sh
sed -i 's/^#drivers =/drivers = alsa/' /etc/openal/alsoft.conf
```
> A reboot might be needed, or a restart of also/openal.

Now you can launch the game with `mono StardewValley.exe`.

Here an example .desktop file:
```ini
[Desktop Entry]
Name=Stardew Valley
Description= Stardew Valley through Mono
Exec=/usr/bin/mono $HOME/Desktop/Stardew\ Valley/StardewValley.exe
Type=Application
Categories=Games;
```
