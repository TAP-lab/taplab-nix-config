#!/usr/bin/env bash

# Simple wrapper script to run all of the credential setup scripts in one go.
set -euo pipefail

SCRIPT_DIR = "$HOME/nix-config/scripts/credentials"

echo "Running auto-setup for credentials..."

echo "Running wifi setup..."
sh "$SCRIPT_DIR/wifi.sh"

echo "Running mema nas share setup..."
sh "$SCRIPT_DIR/mema.sh"

echo "Running Minecraft account setup..."
sh "$SCRIPT_DIR/minecraft-account.sh"

echo "Running edge setup..."
sh "$SCRIPT_DIR/edge.sh"

echo "All credentials setup complete!"