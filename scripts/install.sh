#!/usr/bin/env bash

set -euo pipefail

# Sets the default values for the installation, which can be overridden by command line arguments.
FLAKE="https://github.com/tap-lab/taplab-nix-config"

DISK="/dev/sda"
OUTPUT="nixos"
BRANCH="main"
SKIP_DISKO=false
SKIP_INSTALL=false

# Displays a help message.
usage() {
    cat <<EOF
Usage:
    $(basename "$0") [OPTIONS]

Options:
    -f              Override the flake path (default: "$FLAKE").
    -b              Override the flake branch (default: "$BRANCH").
    -d              Specify the target disk for installation (default: "$DISK").
    -o              Specify the output to use for the flake (default: "$OUTPUT").
    --skip-disko    Skip the disk partitioning step (will not mount the filesystem)
    --skip-install  Skip the NixOS installation step (for further customization)
    -h, --help      Show this help
EOF
}

for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then
        usage
        exit 0
    fi
done

# Parses the arguments passed to the script and sets the corresponding variables.
while getopts ":f:b:d:o:h" opt; do
	case $opt in
		-h)
			usage
			exit 0
			;;
		f) FLAKE="$OPTARG" ;;
		b) BRANCH="$OPTARG" ;;
		d) DISK="$OPTARG" ;;
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

mkdir -p ~/.config/nix
cat <<EOF > ~/.config/nix/nix.conf
experimental-features = nix-command flakes
accept-flake-config = true
EOF

# Validates that the required arguments are provided.
if [[ -z "$DISK" ]]; then
    echo "Error: --disk argument is required."
    usage
    exit 1
fi

echo "Installing NixOS on disk: $DISK"
echo "Using output: $OUTPUT"
echo "Using configuration branch: $BRANCH"

echo "Partitioning disk $DISK"

if [[ $SKIP_DISKO = false ]]; then
	nix run github:nix-community/disko/latest \
	-- --mode destroy,format,mount --flake "git+$REPO/?ref=$BRANCH#disko" --argstr disk "$DISK" --yes-wipe-all-disks
fi

# Stops the script if the user has chosen to skip the installation.
if [[ $SKIP_INSTALL = true ]]; then
    echo "Skipping NixOS installation as per user request."
    exit 0
fi

# Installs NixOS using the configuration.
nixos-install --no-root-passwd --flake "git+$REPO/?ref=$BRANCH#$OUTPUT"

echo "$BRANCH" > /mnt/etc/branch

# Prompts user that the installation and reboots in 10 seconds if not cancelled.
trap 'echo "Reboot cancelled"; exit 0' SIGINT

echo "Installation Complete... Rebooting in 10 seconds"
echo "Press Ctrl+C to cancel reboot, or press Enter to reboot immediately."

seconds=10
while (( seconds > 0 )); do
	printf "\rRebooting in %d seconds... " "$seconds"
	if read -t 1 -r; then
		break
	fi
	((seconds--))
done
printf "\n"

echo "Rebooting now..."
reboot
