#!/bin/bash

set -e

JSON_FILE="dtos.json"

if [ ! -f "$JSON_FILE" ]; then
  echo "ERROR: '$JSON_FILE' not found."
  exit 1
fi

jq -c '.dtos[]' "$JSON_FILE" | while read -r entry; do
  NAME=$(echo "$entry" | jq -r '.name')
  GATEWAY_PATH=$(echo "$entry" | jq -r '.gatewayPath')
  MICROSERVICE_PATH=$(echo "$entry" | jq -r '.microservicePath')

  echo "[$NAME] Syncing '$MICROSERVICE_PATH' -> '$GATEWAY_PATH'"

  if [ ! -d "$MICROSERVICE_PATH" ]; then
    echo "[$NAME] ERROR: Microservice path '$MICROSERVICE_PATH' does not exist. Skipping."
    continue
  fi

  mkdir -p "$GATEWAY_PATH"
  rm -rf "${GATEWAY_PATH:?}"/*
  cp -r "$MICROSERVICE_PATH"/. "$GATEWAY_PATH/"

  echo "[$NAME] Done."
done