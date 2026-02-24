#!/usr/bin/env bash

set -euo pipefail

DISK="/dev/sda"
HOSTNAME="nixos"
BRANCH="main"
SWAP_SIZE="8"
SKIP_INSTALL=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [--disk <disk>] [--branch <branch>] [--hostname <hostname>] [--swap <size>] [--help]

Options:
    --branch    Specify the configuration branch to use (default: main)
    --disk      Specify the target disk for installation (e.g., /dev/sda)
    --hostname  Specify the hostname for the new installation (default: nixos)
    --swap      Specify the swap size in gigabytes (e.g., 4 for 4GB, defaults to no swap)
    --skip-install  Skip the NixOS installation step (for further customization)
  -h, --help   Show this help
EOF
}

wait_for_path() {
    local path="$1"
    local timeout_s="${2:-10}"
    local start
    start="$(date +%s)"

    while [[ ! -e "$path" ]]; do
        if (( $(date +%s) - start >= timeout_s )); then
            echo "Timed out waiting for $path to appear" >&2
            return 1
        fi
        sleep 0.1
    done
}

mount_with_retries() {
    local source="$1"
    local target="$2"
    local timeout_s="${3:-10}"
    local start
    start="$(date +%s)"

    while true; do
        if mount "$source" "$target" 2>/dev/null; then
            return 0
        fi

        if (( $(date +%s) - start >= timeout_s )); then
            echo "Timed out mounting $source on $target" >&2
            mount "$source" "$target"
            return 1
        fi
        sleep 0.2
    done
}


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
        -h|--hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        -s|--swap)
            SWAP_SIZE="$2"
            shift 2
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

if [[ -z "$DISK" ]]; then
    echo "Error: --disk argument is required."
    usage
    exit 1
fi

echo "Installing NixOS on disk: $DISK"
echo "Using hostname: $HOSTNAME"
echo "Using configuration branch: $BRANCH"

echo "Partitioning disk $DISK"

umount -R /mnt || true
swapoff -a || true

parted -s $DISK -- mklabel msdos

if [[ "$SWAP_SIZE" != "0" ]]; then
    echo "Swap enabled: ${SWAP_SIZE}GiB"

    parted -s "$DISK" -- mkpart primary 1MiB -"${SWAP_SIZE}GiB"

    parted -s "$DISK" -- mkpart primary linux-swap -"${SWAP_SIZE}GiB" 100%
else
    echo "Swap disabled"

    parted -s "$DISK" -- mkpart primary 1MiB 100%
fi

parted -s $DISK -- set 1 boot on

mkfs.ext4 -FL nixos "${DISK}1"

if [[ "$SWAP_SIZE" != "0" ]]; then
    mkswap -L swap "${DISK}2"
fi

echo "Disk partitioning complete."

sync
partprobe "$DISK" || true
blockdev --rereadpt "$DISK" || true
udevadm settle --timeout=10 || true

wait_for_path /dev/disk/by-label/nixos 10
mount_with_retries /dev/disk/by-label/nixos /mnt 10

if [[ "$SWAP_SIZE" != "0" ]]; then
    swapon "${DISK}2"
fi

mkdir -p /mnt/etc/nixos

git clone --branch "$BRANCH" https://github.com/TAP-lab/taplab-nix-config.git /mnt/etc/nixos

nixos-generate-config --root /mnt

if [[ $SKIP_INSTALL = true ]]; then
    echo "Skipping NixOS installation as per user request."
    exit 0
fi

nixos-install --no-root-passwd --flake /mnt/etc/nixos#"$HOSTNAME"

git clone --branch "$BRANCH" /mnt/home/taplab/nix-config

chown -R 1000:1000 /mnt/home/taplab/nix-config

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