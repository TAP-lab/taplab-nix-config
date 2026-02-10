#!/usr/bin/env bash
set -euo pipefail

CONFIG_REPO="$HOME/nix-config"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--upgrade] [--help]

Options:
  --upgrade    Run 'nix flake update' in $CONFIG_REPO and then upgrade the system
  -h, --help   Show this help
EOF
}

UPGRADE=0
ACTION="test"
HOSTNAME=$(hostname)
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

if [[ ! -d "$CONFIG_REPO" ]]; then
    echo "Error: config repo '$CONFIG_REPO' not found"
    exit 1
fi


if [[ "$UPGRADE" -eq 1 ]]; then
    echo "==> Updating flake in $CONFIG_REPO"
    cd "$CONFIG_REPO"
    nix flake update
    echo "==> Flake update complete"
fi

echo "Using hostname: $HOSTNAME"

echo "==> Rebuild/$ACTION system for flake: $CONFIG_REPO#$HOSTNAME"
if sudo nixos-rebuild $ACTION --flake "$CONFIG_REPO#$HOSTNAME"; then
    echo "==> Rebuild/$ACTION complete"
else
    echo "Error: nixos-rebuild failed"
    exit 1
fi