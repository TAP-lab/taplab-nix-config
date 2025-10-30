#!/bin/bash

set -e

# Default server lookup file
LOOKUP_FILE="/etc/nixos/resources/servers.txt"

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
# Ensure the secrets directory exists
sudo mkdir -p /etc/nixos/secrets

# Downloads the mema credentials
if sudo curl -fsSL "$SELECTED_IP/mema" -o /etc/nixos/secrets/mema; then
    echo "Credentials downloaded successfully."
else
    echo "Failed to download credentials." >&2
    exit 1
fi

# Makes the credentials file readable only by root
sudo chmod 600 /etc/nixos/secrets/mema