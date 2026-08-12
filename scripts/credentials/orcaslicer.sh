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
    echo "Usage: orcaslicer [--server <name> | --ip <address>]"
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

# Kills OrcaSlicer if it's running
pkill orca-slicer || true

# Ensures the config directory exists
mkdir -p /home/taplab/.config
cd /home/taplab/.config

# Downloads the pre-configured OrcaSlicer profile (SSH/SFTP first, web fallback)
if scp -q -o BatchMode=yes -o ConnectTimeout=5 -o IdentitiesOnly=yes -i "$HOME/.ssh/credserver.key" -o UserKnownHostsFile="$HOME/.ssh/taplab_known_hosts" "nix@$SELECTED_IP:/srv/orcaslicer.tar.xz" OrcaSlicer.tar.xz; then
    echo "OrcaSlicer profile downloaded successfully via SSH/SFTP."
elif curl -fsSL "$SELECTED_IP:8080/orcaslicer.tar.xz" -o OrcaSlicer.tar.xz; then
    echo "OrcaSlicer profile downloaded successfully via web fallback."
else
    echo "Failed to download OrcaSlicer profile via SSH/SFTP and web fallback." >&2
    exit 1
fi

# Removes the old profile
rm -rf OrcaSlicer

# Extracts the new profile into a temp dir, since the archive's top-level
# entry name/casing (OrcaSlicer/Orcaslicer/no wrapping folder) varies
EXTRACT_DIR=$(mktemp -d)
tar -xf OrcaSlicer.tar.xz -C "$EXTRACT_DIR"

# Normalizes whatever came out into ./OrcaSlicer
TOP_ENTRIES=("$EXTRACT_DIR"/*)
if [[ ${#TOP_ENTRIES[@]} -eq 1 && -d "${TOP_ENTRIES[0]}" ]]; then
    mv "${TOP_ENTRIES[0]}" OrcaSlicer
else
    mv "$EXTRACT_DIR" OrcaSlicer
fi
rmdir "$EXTRACT_DIR" 2>/dev/null || true

# Cleans up the downloaded file
rm OrcaSlicer.tar.xz

# Ensures the profile is owned by taplab, not root
chown -R taplab:users /home/taplab/.config/OrcaSlicer

echo "OrcaSlicer profile updated."
