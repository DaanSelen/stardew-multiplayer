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

#configure_mods() {
#  # TO DO
#}

# Function to launch Stardew Valley
launch_stardew() {
  bash -c "sleep 5s \
  && /data/stardewvalley/StardewValley" &
  stardew_valley_pid=$!
}

ln -sv /config/autoload/config.json /data/stardewvalley/Mods/AutoLoadGame/config.json
ln -sv /config/always_on_server/config.json /data/stardewvalley/Mods/Always\ On\ Server/config.json

# Main script execution
echo "Starting the Stardew Valley server instance for the first time..."
#configure_mods

echo "Starting to follow the SMAPI logs..."
tail_smapi &

echo "Configuring Mods"
#configure_mods

echo "Launching Stardew Valley..."
launch_stardew
