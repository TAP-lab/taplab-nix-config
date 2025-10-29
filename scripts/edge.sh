#!/usr/bin/env bash

set -e

SERVER="http://nas:8080"

# Kills edge if it's running
pkill msedge || true

# Ensures the config directory exists
mkdir -p ~/.config/microsoft-edge
cd ~/.config/microsoft-edge

# Downloads the pre-configured edge profile
curl -fsSL $SERVER/edge -o Default.tar.xz

# Removes the old profile
rm -rf Default

# Extracts the new profile
tar -xf Default.tar.xz 

# Cleans up the downloaded file
rm Default.tar.xz

echo "Microsoft Edge profile updated."