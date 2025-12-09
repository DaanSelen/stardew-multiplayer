#!/bin/bash

# graceful_shutdown and trap SIGTERM should still be at the top
graceful_shutdown() {
  echo "Received SIGTERM. Cleaning up..."
  # Use pgrep to find the Stardew Valley process by name if you need to kill it
  # Or ensure launch_stardew sets stardew_valley_pid correctly
  pkill -TERM StardewValley # Or whatever the main executable name is
  echo "Killed Stardew Valley process, exiting..."
  exit 0
}
trap graceful_shutdown SIGTERM

# Function to launch Stardew Valley
launch_stardew() {
  echo "Entering Stardew Launching Function..."
  local retry_count=0

  while true; do
    echo "Sleeping for 5 seconds to give the DE some breathing time..."
    sleep 3s
    if [[ $retry_count -gt 5 ]]; then
      echo "Loop detected. Stopping..."
      exit 1
    fi

    echo "Executing Stardew/SMAPI Binaries!"
    SPDLOG_LEVEL=off mangohud --dlsym /data/stardewvalley/StardewValley
    ((retry_count++))
    echo "Restart attempt ${retry_count}. Stardew Valley crashed or exited. Restarting..."
  done
}

# FIRST-RUNS
if [[ ! -d /config/modconfs/autoload ]]; then
    echo "Creating Directory: autoload"
    mkdir -p /config/modconfs/autoload
fi

if [[ ! -d /config/modconfs/always_on_server ]]; then
    echo "Creating Directory: always_on_server"
    mkdir -p /config/modconfs/always_on_server
fi

if [[ ! -f /config/modconfs/autoload/config.json ]]; then
    echo "Moving config: autoload"
    mv /tmp/autoload_config.json /config/modconfs/autoload/config.json
fi

if [[ ! -f /config/modconfs/always_on_server/config.json ]]; then
    echo "Moving config: always on server"
    mv /tmp/always_on_server_config.json /config/modconfs/always_on_server/config.json
fi

# ALWAYS
if [[ ! -d /config/.config/MangoHud ]]; then
    mkdir -p /config/.config/MangoHud
fi

if [[ ! -f /config/.config/MangoHud/MangoHud.conf ]]; then
    mv /tmp/MangoHud.conf /config/.config/MangoHud/MangoHud.conf
fi

ln -sv /config/modconfs/autoload/config.json /data/stardewvalley/Mods/AutoLoadGame/config.json
ln -sv /config/modconfs/always_on_server/config.json /data/stardewvalley/Mods/Always\ On\ Server/config.json

echo "Starting..."

echo "Launching Stardew Valley in the background..."
launch_stardew &
stardew_valley_pid=$!
