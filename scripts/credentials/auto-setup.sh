#!/usr/bin/env bash

# Simple wrapper script to run all of the credential setup scripts in one go.
set -euo pipefail

echo "Running auto-setup for credentials..."

echo "Running wifi setup..."
wifi-setup

echo "Running mema nas share setup..."
mema-setup

echo "Running Minecraft account setup..."
minecraft-setup

echo "Running edge setup..."
edge-setup

echo "Running OrcaSlicer setup..."
orcaslicer-setup

echo "All credentials setup complete!"
