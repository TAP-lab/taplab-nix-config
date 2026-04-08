#!/usr/bin/env bash
set -euo pipefail

# Sets the path to the config repo.
CONFIG_REPO="/root/nix-config"

# Displays a help message.
usage() {
    cat <<EOF
Usage: $(basename "$0") [--upgrade] [--help]

Options:
  --action <action>    Specify the nixos-rebuild action (default: test)
  --branch <branch>    Specify the git branch to use (default: main)
  --hostname <hostname> Specify the hostname to use for the flake (default: current hostname)
  --upgrade            Pull the latest changes from the config repo (default: false)
  --help               Show this help message and exit
EOF
}

# Sets the default values for the script.
UPGRADE=0
ACTION="test"
HOSTNAME=$(hostname)
BRANCH=""

# Parses the command line arguments.
while [[ ${#} -gt 0 ]]; do
    case "$1" in
        -a|--action)
            if [[ $# -lt 2 ]]; then
                echo "Error: --action requires an argument"
                usage
                exit 2
            fi
            ACTION="$2"
            shift 2
            ;;
        -b|--branch)
            if [[ $# -lt 2 ]]; then
                echo "Error: --branch requires an argument"
                usage
                exit 2
            fi
            BRANCH="$2"
            shift 2
            ;;
        -u|--upgrade)
            UPGRADE=1
            shift
            ;;
        -h|--hostname)
            if [[ $# -lt 2 ]]; then
                echo "Error: --hostname requires an argument"
                usage
                exit 2
            fi
            HOSTNAME="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            exit 2
            ;;
    esac
done

# Checks if the config repo exists, and auto picks the branch to use.
if [[ -z "$BRANCH" ]]; then
    if [[ -d "$CONFIG_REPO/.git" ]]; then
        BRANCH=$(git -C "$CONFIG_REPO" rev-parse --abbrev-ref HEAD)
    else
        BRANCH="main"
    fi
fi

# Checks if the config repo exists, and pulls the latest changes. If it doesn't exist, clones it.
if [[ "$UPGRADE" -eq 1 ]]; then
    if cd "$CONFIG_REPO"; then
        git pull
    else
        git clone https://github.com/TAP-lab/taplab-nix-config.git "$CONFIG_REPO"
    fi
fi

if [[ ! -d "$CONFIG_REPO" ]]; then
    echo "Error: config repo '$CONFIG_REPO' not found"
    exit 1
fi

# Changes working directory.
cd "$CONFIG_REPO"

# Copies the hardware configuration file to the config repo to ensure it is included in the rebuild.
cp /etc/nixos/hardware-configuration.nix "$CONFIG_REPO"

# Ensures the correct branch is being used.
git checkout "$BRANCH" || { echo "Error: branch '$BRANCH' not found in $CONFIG_REPO"; exit 1; }

echo "Using hostname: $HOSTNAME"

# this file breaks the rebuild for some reason, quick workaround.
rm /home/taplab/.gtkrc-2.0 || true

# Rebuilds the system using specified parameters.
echo "==> Rebuild/$ACTION system for flake: $CONFIG_REPO#$HOSTNAME"
if nixos-rebuild $ACTION --flake "$CONFIG_REPO#$HOSTNAME"; then
    echo "==> Rebuild/$ACTION complete"
else
    echo "Error: nixos-rebuild failed"
    exit 1
fi