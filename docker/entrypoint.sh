#!/bin/bash

stardew_valley_loc="/data/stardewvalley"

graceful_shutdown() {
  echo "Received SIGTERM. Cleaning up..."
  pkill -9 $stardew_valley_pid

  echo "Killed Stardew Valley process, exiting..."
  exit 0
}
trap graceful_shutdown SIGTERM

# Function to configure mods
configure_mods() {
  echo "Configuring Mods"
  for modPath in ${stardew_valley_loc}/Mods/*/; do
    mod=$(basename "$modPath")

    # Only attempt to copy if the template exists
    if [ -f "${modPath}/config.json.template" ]; then
      if [ ! -s "${modPath}/config.json" ]; then
        echo "Configuring ${mod} by copying config.json.template"
        cp "${modPath}/config.json.template" "${modPath}/config.json"
      else
        echo "Config for ${mod} already exists, skipping."
      fi
    else
      echo "Warning: config.json.template missing for ${mod}, skipping configuration."
    fi
  done
}

tail_smapi() {
  local smapi_logs="/config/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"

  while [[ ! -f "$smapi_logs" ]] || [[ -z $(cat $smapi_logs) ]]; do
    echo "SMAPI logs are not yet here. waiting 3 seconds..."
    sleep 3s
  done

  tail -f $smapi_logs
}

# Function to launch Stardew Valley
launch_stardew() {
  bash -c "sleep 5s \
  && SYNC=0 strangle 6 /data/stardewvalley/StardewValley" &
  #stardew_valley_pid=$!
}

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

ln -sv /config/modconfs/autoload/config.json /data/stardewvalley/Mods/AutoLoadGame/config.json
ln -sv /config/modconfs/always_on_server/config.json /data/stardewvalley/Mods/Always\ On\ Server/config.json

echo "Starting..."
echo "Starting to follow the SMAPI logs..."
tail_smapi &

echo "Configuring Mods"
#configure_mods

echo "Launching Stardew Valley..."
launch_stardew
