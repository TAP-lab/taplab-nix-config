#!/usr/bin/env bash

set -e

# Ensure the secrets directory exists
sudo mkdir -p /etc/nixos/secrets

SERVER="http://credentials.nix-config.taplab.nz:8080"

# Downloads the mema credentials
echo "Downloading credentials from $SERVER..."
if sudo curl -fsSL "$SERVER/mema" -o /etc/nixos/secrets/mema; then
    echo "Credentials downloaded successfully."
else
    echo "Failed to download credentials." >&2
    exit 1
fi

# Makes the credentials file readable only by root
sudo chmod 600 /etc/nixos/secrets/mema