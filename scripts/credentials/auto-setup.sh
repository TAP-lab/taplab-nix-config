#!/usr/bin/env bash

# Simple wrapper script to run all of the credential setup scripts in one go.
set -euo pipefail

SCRIPT_DIR="$HOME/nix-config/scripts/credentials"

echo "Running auto-setup for credentials..."

echo "Running wifi setup..."
wifi-setup

echo "Running mema nas share setup..."
mema-setup

echo "Running Minecraft account setup..."
minecraft-account-setup

echo "Running edge setup..."
edge-setup

echo "Running OrcaSlicer setup..."
sh "$SCRIPT_DIR/orcaslicer.sh"

echo "All credentials setup complete!"