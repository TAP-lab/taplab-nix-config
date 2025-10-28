#!/usr/bin/env bash

SERVER="http://<server ip/name>:8080"

# Creates a temporary file to store the downloaded wifi credentials
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

# Downloads the wifi credentials
curl -fsSL "$SERVER/wifi" -o "$TMPFILE"

# Parses the SSID and PSK from the downloaded file
SSID=$(sed -n '1p' "$TMPFILE")
PSK=$(sed -n '2p' "$TMPFILE")

if [ -z "$SSID" ] || [ -z "$PSK" ]; then
  echo "Error: Could not parse SSID or PSK from file."
  exit 2
fi

echo "Connecting to SSID: $SSID"

# Sets up the wifi connection using nmcli
nmcli device wifi connect "$SSID" password "$PSK"

echo "Connected to $SSID."

# Cleans up the temporary file
rm -f "$TMPFILE"