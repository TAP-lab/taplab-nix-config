#!/usr/bin/env bash
# not implemented at taplab yet - for my testing

SERVER="http://192.168.1.220:8080"

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

curl -fsSL "$SERVER/wifi" -o "$TMPFILE"

SSID=$(sed -n '1p' "$TMPFILE")
PSK=$(sed -n '2p' "$TMPFILE")

if [ -z "$SSID" ] || [ -z "$PSK" ]; then
  echo "Error: Could not parse SSID or PSK from file."
  exit 2
fi

echo "Connecting to SSID: $SSID"

nmcli device wifi connect "$SSID" password "$PSK"

echo "Connected to $SSID."