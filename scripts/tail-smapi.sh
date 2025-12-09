#!/bin/bash

tail_smapi() {
  local smapi_logs="/config/.config/StardewValley/ErrorLogs/SMAPI-latest.txt"
  echo "Removing old logs if they exist..."
  [[ -f $smapi_logs ]] && rm $smapi_logs

  # Loop until the log file exists and has content
  while [[ ! -f "$smapi_logs" ]] || [[ -z $(cat "$smapi_logs") ]]; do
    echo "SMAPI logs are not yet here. waiting 3 seconds..."
    sleep 3s
  done

  # Now that the file exists and has content, tail it.
  # This function will block and keep tailing.
  exec tail -f "$smapi_logs"
}

echo "Starting to follow the SMAPI logs (main process)..."
tail_smapi &
