#!/usr/bin/env bash
set -euo pipefail

# Sets the url to the config repo.
REPO="https://github.com/tap-lab/taplab-nix-config"

# Displays a help message.
usage() {
    cat <<EOF
Usage: $(basename "$0")[--branch <branch>] [--output <output>] [-g] [--help]

Options:
  --action|a <action>    Specify the nixos-rebuild action (default: test)
  -g                     Run garbage collection after rebuild (default: false)
  --output|o <output>    Specify the output to use for the flake (default: nixos)
  --help               Show this help message and exit
EOF
}

# Sets the default values for the script.
ACTION="test"
OUTPUT="nixos"
GC=0

if [[ -f /etc/branch ]]; then
    BRANCH=$(cat /etc/branch)
else
    BRANCH="main"
fi

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
        -o|--output)
            if [[ $# -lt 2 ]]; then
                echo "Error: --output requires an argument"
                usage
                exit 2
            fi
            OUTPUT="$2"
            shift 2
            ;;
        -g)
            GC=1
            shift
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

if [[ $(whoami) != "root" ]]; then
    echo "Error: This script must be run as root"
    exit 1
fi

echo "Using output: $OUTPUT"

# Rebuilds the system using specified parameters.
echo "==> Rebuild/$ACTION system for flake: $REPO/$BRANCH#$OUTPUT"
if nixos-rebuild "$ACTION" --flake "git+$REPO/?ref=$BRANCH#$OUTPUT"; then
    echo "==> Rebuild/$ACTION complete"
else
    echo "Error: nixos-rebuild failed"
    exit 1
fi

echo "$BRANCH" > /etc/branch

if [[ "$GC" -eq 1 ]]; then
    echo "==> Running garbage collection"
    nix-collect-garbage -d 2>/dev/null | tail -n 1
    echo "==> Garbage collection complete"
fi
