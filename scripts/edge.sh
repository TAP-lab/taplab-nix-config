#!/bin/bash

set -e

# Default server lookup file
LOOKUP_FILE="/etc/nixos/resources/servers.ini"

SERVER=""
IP=""

# Parses arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --server)
            SERVER="$2"
            shift 2
            ;;
        --ip)
            IP="$2"
            shift 2
            ;;
        --file)
            LOOKUP_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# Only allow either --server or --ip, not both
if [[ -n "$SERVER" && -n "$IP" ]]; then
    echo "Error: --server and --ip cannot be used together."
    echo "Usage: edge [--server <name> | --ip <address>]"
    exit 1
fi

# Determines which IP/Server to use
if [[ -n "$IP" ]]; then
    SELECTED_IP="$IP"
    SERVER="$SELECTED_IP"
elif [[ -n "$SERVER" ]]; then
    SELECTED_IP=$(grep -m1 "^${SERVER}=" "$LOOKUP_FILE" | cut -d'=' -f2-)
    if [[ -z "$SELECTED_IP" ]]; then
        echo "Server '$SERVER' not found in $LOOKUP_FILE"
        exit 1
    fi
else
    # If no server or IP is specified, ping each server in the servers.txt file (in order)
    while IFS='=' read -r name addr; do
        # Skips empty lines and comments
        [[ -z "$name" || "$name" =~ ^# ]] && continue
        if [[ -n "$name" && -n "$addr" ]]; then
            echo "Pinging $name ($addr)..."
            if ping -c 1 -W 1 "$addr" >/dev/null 2>&1; then
                echo "Selected $name ($addr)"
                SELECTED_IP="$addr"
                SERVER="$name"
                break
            fi
        fi
    done < "$LOOKUP_FILE"
    if [[ -z "$SELECTED_IP" ]]; then
        echo "No reachable servers found in $LOOKUP_FILE"
        exit 1
    fi
fi

echo "Pulling from server: '$SERVER' at '$SELECTED_IP'"

# Kills edge if it's running
pkill msedge || true

# Ensures the config directory exists
mkdir -p ~/.config/microsoft-edge
cd ~/.config/microsoft-edge

# Downloads the pre-configured edge profile
if curl -fsSL "$SELECTED_IP:8080/edge" -o Default.tar.xz; then
    echo "Edge profile downloaded successfully."
else
    echo "Failed to download edge profile." >&2
    exit 1
fi

# Removes the old profile
rm -rf Default

# Extracts the new profile
tar -xf Default.tar.xz 

# Cleans up the downloaded file
rm Default.tar.xz

echo "Microsoft Edge profile updated."