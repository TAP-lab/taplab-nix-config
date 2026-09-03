#!/usr/bin/env bash
set -euo pipefail

# Sets the url to the config repo.
FLAKE="https://github.com/tap-lab/taplab-nix-config"

# Displays a help message.
usage() {
    cat <<EOF
Usage:
    $(basename "$0") [OPTIONS]

Options:
    -g              Run garbage collection after rebuilding.
    -f FLAKE        Override the flake path (default: "$FLAKE").
    -b BRANCH       Override the flake branch (default: "$BRANCH").
    -a ACTION       Rebuild action to run (default: switch).
    -o OUTPUT       Override flake output (default: current hostname).
    -h, --help      Show this help and exit.
EOF
}

for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then
        usage
        exit 0
    fi
done

# Sets the default values for the script.
GC=0
ACTION="switch"
OUTPUT=$(hostname)

if [[ -f /etc/branch ]]; then
    BRANCH=$(cat /etc/branch)
else
    BRANCH="main"
fi

# Parses the command line arguments.
while getopts ":hgf:b:a:o:" opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
        g) GC=1 ;;
        f) FLAKE="$OPTARG" ;;
        b) BRANCH="$OPTARG" ;;
        a) ACTION="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        :)
            echo "Error: -$OPTARG requires an argument"
            usage
            exit 2
            ;;
        \?)
            echo "Unknown flag: -$OPTARG"
            usage
            exit 2
            ;;
    esac
done

if [[ $(whoami) != "root" ]]; then
    echo "Error: This script must be run as root"
    exit 1
fi

echo "Using output: $OUTPUT"

# Prompts for the laptop number if it hasn't been set yet, (used for identifying the device on the network)
# Will only prompt if rebuild.sh is manually run with an interactive terminal
if [[ ! -f /etc/taplab-laptop-number && -t 0 ]]; then
    read -rp "Enter the laptop number: " LAPTOP_NUMBER
    echo "$LAPTOP_NUMBER" > /etc/taplab-laptop-number
fi

# Rebuilds the system using specified parameters.
rebuild_start=$(date +%s)
if nixos-rebuild "$ACTION" --refresh --flake "git+$FLAKE/?ref=$BRANCH#$OUTPUT"; then
    rebuild_elapsed=$(( $(date +%s) - rebuild_start ))
    echo "==> Rebuild/$ACTION complete in $(( rebuild_elapsed / 60 ))m $(( rebuild_elapsed % 60 ))s"
else
    echo "Error: nixos-rebuild $ACTION failed"
    exit 1
fi

echo "$BRANCH" > /etc/branch

if [[ "$GC" -eq 1 ]]; then
    echo "==> Running garbage collection"
    nix-collect-garbage -d 2>/dev/null | tail -n 1
    echo "==> Garbage collection complete"
fi
