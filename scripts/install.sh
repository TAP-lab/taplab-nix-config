#!/usr/bin/env bash

set -euo pipefail

# Sets the default values for the installation, which can be overridden by command line arguments.
DISK="/dev/sda"
OUTPUT="nixos"
BRANCH="main"
SKIP_DISKO=false
SKIP_INSTALL=false
REPO="https://github.com/tap-lab/taplab-nix-config"

# Displays a help message.
usage() {
    cat <<EOF
Usage: $(basename "$0") [--disk <disk>] [--branch <branch>] [--output <output>] [--help]

Options:
    --branch        Specify the configuration branch to use (default: main)
    --disk          Specify the target disk for installation (e.g., /dev/sda)
    --output        Specify the output to use for the flake (default: nixos)
    --skip-disko    Skip the disk partitioning step
    --skip-install  Skip the NixOS installation step (for further customization)
    -h, --help      Show this help
EOF
}

# Parses the arguments passed to the script and sets the corresponding variables.
while [[ $# -gt 0 ]]; do
	case $1 in
		-b|--branch)
			BRANCH="$2"
			shift 2
			;;
		-d|--disk)
			DISK="$2"
			shift 2
			;;
		-o|--output)
			OUTPUT="$2"
			shift 2
			;;
		-p|--skip-disko)
			SKIP_DISKO=true
			shift 1
			;;
		-i|--skip-install)
			SKIP_INSTALL=true
			shift 1
			;;
		--help)
			usage
			exit 0
			;;
		*)
			echo "Error: Unknown argument: $1"
			usage
			exit 1
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
	-- --mode destroy,format,mount --flake "$REPO/?ref=$BRANCH#disko" --argstr disk "$DISK" --yes-wipe-all-disks
fi

# Stops the script if the user has chosen to skip the installation.
if [[ $SKIP_INSTALL = true ]]; then
    echo "Skipping NixOS installation as per user request."
    exit 0
fi

# Installs NixOS using the configuration.
nixos-install --no-root-passwd --flake "$REPO/?ref=$BRANCH#$OUTPUT"

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
