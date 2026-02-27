#!/bin/bash

current_user=$(id -u)
real_user=$(who am i | awk '{print $1}')
compressed_stardew="/home/${real_user}/Desktop/latest.tar.gz"

if [[ "${current_user}" -ne 0 ]]; then
    echo "[ ERROR ] Not running as root, please redo with sudo."
    exit 1
else
    echo "[ INFO ] Running with (sudo) root permissions."
fi

echo "[ INFO ] Trying to install Stardew Valley mono dependencies."
if ! apt install -y mono-complete libopenal1 libopenal-dev libsdl2-2.0-0 libsdl2-dev; then
    echo "[ ERROR ] Failed to install dependencies."
    exit 1
fi

echo "[ INPUT ] Please place your compressed (.tar.gz) Stardew Valley compatibility version on the Desktop."

echo "[ INPUT ] Input the correct path or press enter to continue."
read -r given_compressed_stardew

if [[ -z "${given_compressed_stardew}" ]]; then
    echo "[ INFO ] Using the default location."
else
    compressed_stardew=${given_compressed_stardew}
fi

echo "[ INFO ] The targeted file is: ${compressed_stardew}"

if [[ ! -f "${compressed_stardew}" ]]; then
    echo "[ ERROR ] File not found: ${compressed_stardew}"
    exit 1
fi

echo "[ INFO ] Decompressing the archive..."
tar -zxf "${compressed_stardew}" -C "/home/${real_user}/Desktop"

ls "/home/${real_user}/Desktop/Stardew Valley"
echo "[ INFO ] Removing breaking libraries (mono has replacements)..."
rm -v "/home/${real_user}/Desktop/Stardew Valley/System.dll" "/home/${real_user}/Desktop/Stardew Valley/System.Core.dll"

echo "[ INFO ] Downloading needed libraries..."
wget https://build.lwjgl.org/stable/linux/arm64/liblwjgl_lz4.so -O /lib/aarch64-linux-gnu/liblwjgl_lz.so
chmod +x /lib/aarch64-linux-gnu/liblwjgl_lz.so

echo "[ INFO ] Editing the MonoGame.Framework.dll.config..."
echo '''
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
''' > "/home/${real_user}/Desktop/Stardew Valley/MonoGame.Framework.dll.config"

echo "[ INFO ] Linking the system ARM64 library directory..."
ln -sv /lib/aarch64-linux-gnu "/home/${real_user}/Desktop/Stardew Valley/libaarch64"

echo "[ INFO ] Editing the openal configuration file..."
sed -i 's/^#drivers =/drivers = alsa/' /etc/openal/alsoft.conf

echo "[ FINISH ] All should be ready! Perhaps a reboot is needed."
