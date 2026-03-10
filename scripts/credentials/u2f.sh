#!/bin/bash

set -e

# Default server lookup file
LOOKUP_FILE="$HOME/nix-config/resources/servers.ini"

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
    echo "Usage: u2f [--server <name> | --ip <address>]"
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

echo "Pulling U2F keys from server: '$SERVER' at '$SELECTED_IP'"

# Ensures the Yubico config directory exists
mkdir -p ~/.config/Yubico

# Downloads the U2F keys
if curl -fsSL "$SELECTED_IP:8080/u2f" -o ~/.config/Yubico/u2f_keys; then
    echo "U2F keys downloaded successfully."
else
    echo "Failed to download U2F keys." >&2
    exit 1
fi

# Makes the U2F keys file readable only by the user
chmod 600 ~/.config/Yubico/u2f_keys

echo "U2F configuration complete."
