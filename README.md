# Taplab NixOS Config

This NixOS configuration is made to be used with the TAP-lab laptops, with all of the necessary apps and settings pre-configured.

# Table of Contents

- [Quick Start Guide](#quick-start-guide)
- [Usage Guide](#usage-guide)
- [Full Instructions](#full-instructions)
- [Technical Explanation](#technical-explanation)


# Quick Start Guide

1. Download the NixOS Minimal ISO from [NixOS Downloads](https://nixos.org/download.html).
2. Create a bootable USB drive using the NixOS ISO.
3. Boot the laptop to the USB by pressing F9 during startup and select the USB drive.
4. Once booted into the live environment, run `sudo -i` to change to the root user.
5. Ensure the laptop is plugged into ethernet (wifi is harder to set up and will be covered in the [Full Instructions](#full-instructions)). Try `ping google.com` to check for internet connectivity.
6. To use the install script, simply run the following command:
    ```bash
    sh <(curl https://raw.githubusercontent.com/TAP-lab/taplab-nix-config/main/install.sh)
    ```
7. The script should automatically install NixOS and the configuration. It will automatically reboot when finished.
8. In case of any issues, you can refer to the [Full Instructions](#full-instructions) and the [Technical Explanation](#technical-explanation) sections below.

# Usage Guide

- Most things should be set up after the installation, wifi can be set up by running `wifi` in terminal to pull the credentials from the local server, or by setting it up manually in KDE network settings.
- In order to update the system, you can use the `updatenix` command in the terminal. This will update the system with the latest stable version of this configuration.
    - The `updatenix` command can be run with an argument to specify a branch, for example `updatenix testing` will switch the system to the `testing` branch. 
    - `updatenix` always updates the system to the latest Nix version.
    - Rebooting after updating is recommended if a large update was performed.
- In order to play Minecraft on the TAP-lab server (for Friday sessions), simply run the `Minecraft` app from the KDE menu. Enter your username, and press enter. A prism launcher window will briefly open but should automatically close and the game will launch.
- All other apps can be found in the KDE menu and should work as expected.
- If any extra apps are required, they can be installed locally through the KDE Discover app using Flathub. Please note that apps installed this way will not be present on other laptops, and should not be expected to persist.
- The system is set up to automatically log into the `taplab` user account without needing a password. The account still has a sudo password, for performing admin tasks (e.g updating the system). For the current testing version the password is `taplab` (this should be changed to a more secure password once this is fully rolled out).
- The system has 3 network shares automatically mounted, manuhiri, Hacklings , and mema. The first 2 should mount automatically provided the laptop is on the TAP-lab network. The mema share requires credentials to access, which can be pulled from the local server by running the `mema` command in terminal.
- There is a script to automatically set up Microsoft Edge to log in to the TAP-lab account. This can be run by executing the `edge` command in terminal. This also requires the laptop to be on the TAP-lab network.


# Full Instructions

1. Download the NixOS Minimal ISO from [NixOS Downloads](https://nixos.org/download.html).
2. Create a bootable USB drive using the NixOS ISO. You can use tools like Rufus (Windows) or `dd` (Linux/Mac).
3. Plug the USB into the laptop and boot from it by pressing F9 during startup and select the USB drive.
4. Once booted into the live environment, run `sudo -i` to change to the root user.
5. Preferably, plug the laptop into ethernet, if this is not possible set up wifi like so:
    - Run `systemctl start wpa_supplicant` to start the wifi service.
    - Run `wpa_cli` to enter the wpa_cli interface.
    - Run `add_network` to create a new network(ID 0).
    - Run `set_network 0 ssid "<ssid>"` replacing `<ssid>` with the name of the wifi network.
    - Run `set_network 0 psk "<password>"` replacing `<password>` with the wifi password.
    - Run `enable_network 0` to enable the network.
    - Enter CTRL+C to exit wpa_cli.
6. Check for internet connectivity by running `ping google.com`. If there is no connectivity, double check the previous steps.
7. To use the install script, simply run the following command:
    ```bash
    sh <(curl https://raw.githubusercontent.com/TAP-lab/taplab-nix-config/main/install.sh)
    ```
    - The script has 2 possible flags, `--disk` and `--branch`.
    - `--disk` can be used to specify which disk to install to, for example `--disk /dev/sda`. If not specified, the script will install to /dev/sda by default.
    - You can check what disk you want to install to by running `lsblk` and finding the correct disk (should typically be `/dev/sda` and the largest one).
    - `--branch` can be used to specify which branch of this configuration to install. By default it will install the `main` branch, but you can specify `testing` to install the testing branch instead.
8. The script should automatically install NixOS and the configuration. It will automatically reboot when finished.

#### In case of any issues, you can attempt to debug them using the [Technical Explanation](#technical-explanation) section, or Contact Callum (clamlum2@gmail.com).


# Technical Explanation

This configuration is designed to be as automated and user-friendly as possible. This section explains how the installation script and configuration work, in case you want to modify or debug them.

## Sub-sections

- [Scripts](#scripts)
- [Configuration files](#configuration-files)
- [Resources](#resources)



## Scripts
- [Installation Script (`install.sh`)](#installation-script)
- [Update Script (`update.sh`)](#update-script)
- [Minecraft Offline Script (`resources/offline.sh`)](#minecraft-offline-script)
- [Auto-update Script (`imports/autoupdate.sh`)](#auto-update-script)
- [Edge login script (`resources/edge.sh`)](#edge-login-script)
- [Mema credetials script (`resources/mema.sh`)](#mema-credetials-pull-script)
- [Wifi credetials script (`resources/wifi.sh`)](#wifi-credetials-script)

### Installation Script
### `install.sh`
The installation script is a bash script that automates the installation of NixOS and the TAP-lab configuration.
This is a commented version of the installation script:

```bash
#!/usr/bin/env bash

set -e      # Sets the script to exit on error

BRANCH="main"           # Sets the default branch to clone
DISK="/dev/sda"         # Sets the default disk to install to

while [[ $# -gt 0 ]]; do        # Parses the command line arguments
	case $1 in
		--branch)
			BRANCH="$2"         # Sets the branch to use
			shift 2
			;;
		--disk)
			DISK="$2"           # Sets the disk to install to
			shift 2
			;;
		*)
			echo "Error: Unknown argument: $1" >&2      # Prints an error message for unknown arguments
			exit 1
			;;
	esac
done

echo "Installing NixOS on disk: $DISK"
echo "Using configuration branch: $BRANCH"

parted -s $DISK -- mklabel msdos                            # Creates a new partition table
parted -s $DISK -- mkpart primary 1MB -8GB                  # Creates a new partition for NixOS
parted -s $DISK -- set 1 boot on                            # Sets the boot flag on the first partition
parted -s $DISK -- mkpart primary linux-swap -8GB 100%      # Creates a swap partition

yes | mkfs.ext4 -L nixos ${DISK}1       # Formats the first partition as ext4 and labels it "nixos"
mkswap -L swap ${DISK}2                 # Formats the second partition as swap and labels it "swap"

sleep 1         # Waits for a second to ensure that the previous operations have completed

mount /dev/disk/by-label/nixos /mnt         # Mounts the nixos partition to /mnt
swapon ${DISK}2                             # Enables the swap partition

echo "Disks successfully partitioned and formatted."

nixos-generate-config --root /mnt       # Generates the NixOS configuration files

cd /tmp                                                                             # Changes to the /tmp directory
echo "Cloning configuration repo using branch: $BRANCH"
git clone --branch "$BRANCH" https://github.com/clamlum2/taplab-nix-config.git      # Clones the configuration repository
cd taplab-nix-config                                                                # Changes to the cloned repository directory

rm /mnt/etc/nixos/configuration.nix 					        # Removes the existing configuration file
rsync -av --exclude='.git' * /mnt/etc/nixos/         	# Copies the configuration files to /mnt/etc/nixos

nixos-install --no-root-passwd      # Installs NixOS without setting a root password to allow for unattended installation

reboot      # Reboots the system
```

#### Notes about the installation script:

- Do not use any branch other than `main` if you want to ensure a working system. I use `testing` to push my changes to in order to test them so it very well may be broken.
- The script assumes that the target disk is `/dev/sda` by default. As far as I have seen this is always the case on the TAP-lab laptops, however i have added the `--disk` flag if this is not the case.
- Pretty much as soon as the script is run it will wipe the target disk, so ensure there isn't anything you want to keep on it.
- The script uses a BIOS boot setup, as despite the laptops supposedly supporting UEFI, I have had absolutely no success getting it to work.
- The script automatically allocates 8GB of swap space, which is the correct amount for the spec of the laptops. You may want to adjust this if you are using a different machine.
- No root password is set during installation in order to avoid the user needing to enter it during installation. If a root password is required, it can be set after installation using sudo.

---
### Update Script
### `update.sh`
The update script is a bash script that automates updating the system to the latest version of this configuration.
This is a commented version of the update script:
```bash
#!/usr/bin/env bash

set -e      # Sets the script to exit on error

REPO_URL="https://github.com/clamlum2/taplab-nix-config.git"        # Sets the repository URL
CONFIG_DIR="$HOME/nix-config"                                       # Sets the directory to clone the configuration to

sudo echo       # Ensures that the script has sudo access

if [ -z "$1" ]; then                                                    # Checks for a branch argument
    if [ -d "$CONFIG_DIR/.git" ]; then                                  # Checks if the config directory is already present
        BRANCH=$(git -C "$CONFIG_DIR" rev-parse --abbrev-ref HEAD)      # Sets the branch to the current branch of the config directory
    else                    # If the config directory is not present and no branch is specified
        BRANCH="main"       # Sets the branch to main if the config directory is not present
    fi
else                    # If a branch argument is provided
    BRANCH="$1"         # Sets the branch to the argument provided
fi

echo
echo "Using branch: $BRANCH"
echo

if [ -d "$CONFIG_DIR/.git" ]; then                                                          # Checks if the config directory is already present
    echo "Repo found at $CONFIG_DIR, pulling changes..."
    cd "$CONFIG_DIR"                                                                        # Changes to the config directory
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)                                       # Gets the current branch
    if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then                                             # Checks if the current branch is different from the target branch
        echo "Current branch ($CURRENT_BRANCH) is different from target branch ($BRANCH)."
        git checkout "$BRANCH"                                                              # Switches to the target branch
    fi
    git pull --rebase origin "$BRANCH"                              # Pulls the latest changes from the target branch
    sudo rsync -av --exclude='.git' "$CONFIG_DIR/" /etc/nixos/      # Copies the configuration files to /etc/nixos
    sudo nixos-rebuild switch --upgrade                             # Rebuilds and updates the system with the latest configuration
    echo
    echo "Update complete!"
    echo "Please reboot if drivers/kernel were updated."
else        # If the config directory is not present
    echo "Repo not found, cloning to $CONFIG_DIR..."
    git clone --branch "$BRANCH" "$REPO_URL" "$CONFIG_DIR"      # Clones the configuration repository
    cd "$CONFIG_DIR"                                            # Changes to the config directory
    sudo rsync -av --exclude='.git' "$CONFIG_DIR/" /etc/nixos/  # Copies the configuration files to /etc/nixos
    sudo nixos-rebuild switch --upgrade         # Rebuilds and updates the system with the latest configuration
    echo
    echo
    echo "Update complete!"
    echo "Please reboot if drivers/kernel were updated."
fi
```

#### Notes about the update script:

- The script assumes that the configuration repository will be in `~/nix-config`. If you want to use a different directory, you can change the `CONFIG_DIR` variable to your desired path.
- The script accepts an optional argument to specify which branch to use. This is specified by providing the branch name after the `updatenix` command, for example `updatenix testing` will switch to the `testing` branch.
- If no branch is specified and the config directory does not exist, it will default to using the `main` branch. If the config directory does exist, it will use the current branch of the repository.
- The `main` branch (should) always be stable and `testing` is mainly there to make it easy for me to test changes. Any other branches are also not guaranteed to work.
- The script always updates the system to the latest package versions when run.
- Rebooting after updating is recommended if a large update was performed, minor updates should apply on the fly.

---
### Minecraft Offline Script
### `scripts/offline.sh`
This is a custom bash script that allows users to easily set their Minecraft username and launch the game in offline mode on the TAP-lab server.

Here is a commented version of the offline script:
```bash
#!/usr/bin/env bash

# Ensures it is working in the correct directory
cd ~/.local/share/PrismLauncher/

# Copies accounts.json_ORIGINAL to accounts.json to reset any previous changes
cp accounts.json_ORIGINAL accounts.json

# Fixes rendering issues with zenity on Wayland by forcing X11
export GDK_BACKEND=x11

# Prompts user for a name using a Zenity GUI
input_name=$(zenity --entry --title="Enter Your Username" --text="Username:")

# If user cancels, exit
if [[ $? -ne 0 ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Replaces CHANGETHISNAME with the inputted name in accounts.json
sed -i "s/CHANGETHISNAME/$input_name/g" accounts.json

# Kills any running instance of prism launcher otherwise the game does not launch
pkill prismlauncher

# Launches game and automatically connects to the TAP-lab server
prismlauncher -l taplab -a $input_name -s SurvivalLAB.exaroton.me &

# Waits for the Prism window to appear and then closes it
while true; do                                          # Loop indefinitely
    win_id=$(kdotool getactivewindow)                   # Gets the ID of the currently active window
    win_name=$(kdotool getwindowname "$win_id")         # Gets the name of the window with that ID
    if [[ "$win_name" == *Prism* ]]; then               # Checks if the window name contains "Prism"
        # If true, it closes the window using a KDE global shortcut
        qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut "Window Close"
        break       # Exit the loop after closing the window
    fi
    sleep 0.1       # Loops the check every 0.1 seconds (10x per second)
done
```

#### Notes about the offline script:
- After the users enters their username, Prism launcher will prompt them to log in. This can simply be dismissed and the game will launch in offline mode.
- At some point I'll make a prompt that tells the user this, as I haven't found a way to automatically dismiss the login prompt.

---
### Auto-update Script
### `acripts/autoupdate.sh`
This script is called by the auto update service and is a modified version of the [`update.sh`](#update-script) script. It is designed to run as a systemd service and update the system automatically.
```bash
source /etc/profile         # Imports the PATH
REPO_URL="https://github.com/clamlum2/taplab-nix-config.git"   # Sets the repository URL
# Notifies the user that the update process is starting
sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update process starting...'
if [ -d "/home/taplab/nix-config/.git" ]; then      # Checks if the config directory is already present
    BRANCH=$(git rev-parse --abbrev-ref HEAD)       # Gets the current branch
    git pull --rebase origin "$BRANCH"              # Pulls the latest changes from the target branch
    # Copies the new configuration files
    rsync -av --exclude='.git' /home/taplab/nix-config/ /etc/nixos/
    nixos-rebuild switch --upgrade && SUCCESS=true || SUCCESS=false         # Rebuilds the system
else
    git clone --branch main "$REPO_URL" /home/taplab/nix-config             # Clones the configuration repository
    rsync -av --exclude='.git' /home/taplab/nix-config/ /etc/nixos/         # Copies the configuration files
    nixos-rebuild switch --upgrade && SUCCESS=true || SUCCESS=false         # Rebuilds the system
fi
if [ "$SUCCESS" = true ]; then      # Checks if the rebuild was successful
    # Notifies the user that the update process was successful
    sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update completed successfully!'
else
    # Notifies the user that the update process failed
    sudo -u taplab DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send 'NixOS Update' 'Update FAILED!'
fi
```

---

### Local pull scripts
The following scripts are credentials and other sensitive data from a local server. They have support for manually selecting a server to pull from using name or IP, and also automatically using the first reachable one.

The possible script names are: `edge`, `mema`, `wifi`.

Each have 3 possible arguments:
- `--server <name>`: Specifies a server name to pull from. The server is looked up in the `servers.ini` file.
- `--ip <address>`: Specifies an IP address to pull from.
- `--file <lookup file path>`: Specifies a custom lookup file instead of the default.

<br>

### Edge login script
### `scripts/edge.sh`
This script copies a pre-configured Microsoft Edge profile to the laptop to automatically log in to the TAP-lab Microsoft account.
```bash
#!/bin/bash

set -e

# Default server lookup file
LOOKUP_FILE="/etc/nixos/resources/servers.ini"

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

# Kills edge if it's running
pkill msedge || true

# Ensures the config directory exists
mkdir -p ~/.config/microsoft-edge
cd ~/.config/microsoft-edge

# Downloads the pre-configured edge profile
if curl -fsSL "$SELECTED_IP:8080/edge" -o Default.tar.xz; then
    echo "Edge profile downloaded successfully."
else
    echo "Failed to download edge profile." >&2
    exit 1
fi

# Removes the old profile
rm -rf Default

# Extracts the new profile
tar -xf Default.tar.xz 

# Cleans up the downloaded file
rm Default.tar.xz

echo "Microsoft Edge profile updated."
```

---
### Mema credetials script
### `scripts/mema.sh`
This script attempts to pull the login for the mema nas share from a local server, as these credentials are not stored within the nix config itself (for obvious security reasons).
```bash
#!/bin/bash

set -e

# Default server lookup file
LOOKUP_FILE="/etc/nixos/resources/servers.ini"

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
# Ensure the secrets directory exists
sudo mkdir -p /etc/nixos/secrets

# Downloads the mema credentials
if sudo curl -fsSL "$SELECTED_IP:8080/mema" -o /etc/nixos/secrets/mema; then
    echo "Credentials downloaded successfully."
else
    echo "Failed to download credentials." >&2
    exit 1
fi

# Makes the credentials file readable only by root
sudo chmod 600 /etc/nixos/secrets/mema
```

---
### Wifi credetials script
### `scripts/wifi.sh`
This script pulls the wifi credentials from a local server(assuming the laptops is being set up using ethernet) and sets up the wifi connection using networkmanager.
```bash
#!/bin/bash

set -e

# Default server lookup file
LOOKUP_FILE="/etc/nixos/resources/servers.ini"

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

# Creates a temporary file to store the downloaded wifi credentials
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

# Downloads the wifi credentials
if curl -fsSL "$SELECTED_IP:8080/wifi" -o "$TMPFILE"; then
    echo "WiFi credentials downloaded successfully."
else
    echo "Failed to download WiFi credentials." >&2
    exit 1
fi

# Parses the SSID and PSK from the downloaded file
SSID=$(sed -n '1p' "$TMPFILE")
PSK=$(sed -n '2p' "$TMPFILE")

if [ -z "$SSID" ] || [ -z "$PSK" ]; then
  echo "Error: Could not parse SSID or PSK from file."
  exit 2
fi

echo "Connecting to SSID: $SSID"

# Sets up the wifi connection using nmcli
nmcli device wifi connect "$SSID" password "$PSK"

echo "Connected to $SSID."

# Cleans up the temporary file
rm -f "$TMPFILE"
```


## Configuration files
- [Hardware configuration (`hardware-configuration.nix`)](#hardware-configuration)
- [Main configuration file (`configuration.nix`)](#main-configuration-file)
- [Packages file (`imports/pkgs.nix`)](#packages-file)
- [Home Manager configuration file (`home.nix`)](#home-manager-configuration-file)
- [Zsh configuration file (`imports/zsh.nix`)](#zsh-configuration-file)
- [KDE Plasma configuration file (`imports/kde.nix`)](#kde-plasma-configuration-file)
- [Prism Launcher configuration file (`imports/prism.nix`)](#prism-launcher-configuration-file)
- [Auto update service configuration file (`imports/autoupdate.nix`)](#auto-update-service-configuration-file)
- [Mounts configuration file (`imports/mounts.nix`)](#mounts-configuration-file)
- [Ghostty configuration file (`imports/ghostty.nix`)](#ghostty-configuration-file)


### Hardware configuration
### `hardware-configuration.nix`
This file is automatically generated by NixOS during installation using the `nixos-generate-config` command. It contains hardware-specific settings for the laptop, and should not be modified manually.

---
### Main configuration file
### `configuration.nix`
This is the main configuration file for the NixOS system. It controls the system configuration, including installed packages (imported from another file), services, and system settings. It also enables and imports the Home Manager module to allow for application-level configuration.

Here is a commented version of the configuration file (the main file is commented but i'll put this here for reference and more comprehensive documentation):

```nix
{ config, pkgs, ... }:

# Fetches the Home Manager module
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  };
in

{
  # Imports the hardware configuration and Home Manager configuration files
  imports =
    [
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
      ./imports/pkgs.nix
      ./imports/autoupdate.nix
      ./imports/mounts.nix
    ];

  # Enables GRUB as the boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 1;

  # Defines basic Home Manager configuration
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.taplab = import ./home.nix;

  # Defines the system version and tells it to use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "25.05";

  # Enables networking through NetworkManager.
  networking.networkmanager.enable = true;

  # Sets the hostname and domain
  networking.hostName = "nixos";
  networking.domain = "taplab.nz";
 
  # Sets the time zone to Auckland, New Zealand.
  time.timeZone = "Pacific/Auckland";

  # Sets locale to New Zealand English
  i18n.defaultLocale = "en_NZ.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # Enables the X11 windowing system. Not sure if this is actually needed for KDE Plasma - might be for xwayland
  services.xserver.enable = true;

  # Configures the keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enables the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "taplab";

  # Enables CUPS to print documents. No idea how well this works
  services.printing.enable = true;

  # Enables sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Defines the taplab user account, contains a hashed password for sudo access
  users.users.taplab = {
    isNormalUser = true;
    description = "taplab";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$6$aGlmHH1OI2haTRMb$HdvQGthHpfDfWfsrD969TcSa/doH5yfL21yZOpH19TZ1sEwfxYbTfcOnB5vGAxcovGxom7VvCJI7xGUJqv808.";
  };

  # Allows unfree packages, drivers etc.
  nixpkgs.config.allowUnfree = true;

  # Enables Flatpak
  services.flatpak.enable = true;

  # Enables OpenSSH server, for debug use but could still be useful
  services.openssh.enable = true;

  # Sets Zsh as the default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Enables Avahi for network device discovery
  services.avahi.enable = true;

  # Opens the ports nessecary for the 3D printers
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 322 990 1883 8080 8883 ];
  networking.firewall.allowedUDPPorts = [ 1990 2021 ];

  hardware.enableRedistributableFirmware = true;    #for testing with my server

  # Enables plymouth to hide some of the boot logging
  boot.plymouth.enable = true;
  boot.plymouth.theme = "spinner";

  # Configures the plymouth boot screen
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "vt.global_cursor_default=0"
  ];
}
```

#### Notes about the configuration file:
- Any changes should be done with caution as they may break the system.
- Most of this file has been automatically generated by NixOS at some point, and I have only modified the necessary parts to get the desired configuration.

---
### Packages file
### `imports/pkgs.nix`
This file contains the package configuration for the system. It defines the packages that should be installed globally.

Any packages that are to be added permanently to the system should be added here.

```nix
{ config, pkgs, ... }:

{
    environment.systemPackages = [
        pkgs.git

        # Dependencies for the minecraft script
        pkgs.zenity
        pkgs.kdotool

        # Taplab apps
        pkgs.blockbench
        pkgs.arduino-ide
        pkgs.microsoft-edge
        pkgs.vlc
        pkgs.freecad
        pkgs.krita
        pkgs.orca-slicer
        pkgs.nomacs
        pkgs.inkscape
        pkgs.p7zip
        pkgs.blender
        pkgs.vscode
        pkgs.luanti

        # For debugging
        pkgs.libsForQt5.kdbusaddons
    ];
}
```

---
### Auto update service configuration file
### `imports/autoupdate.nix`

This file defines the systemd service that automatically updates the laptops' configuration daily
```nix
{ config, pkgs, ... }:

{
    environment.systemPackages = [
        pkgs.libnotify      # For notify-send command
    ];

    # Sets up a systemd service and timer to run the autoupdate script daily
    systemd.services.nixos-update = {
        description = "Periodic NixOS system update with notification";
        serviceConfig = {
        Type = "oneshot";
        # Executes the autoupdate script
        ExecStart = "${pkgs.bash}/bin/bash /home/taplab/nix-config/scripts/autoupdate.sh";
        };
    };

    systemd.timers.nixos-update = {
        description = "Update the system daily";
        wantedBy = [ "timers.target" ];
        timerConfig = {
        OnCalendar = "daily";         # Runs the update daily (12:00 AM)
        Persistent = true;            # Runs the job as soon as possible if it was missed
        };
    };
}
```

---
### Home Manager configuration file
### `home.nix`
This file contains the Home Manager configuration for the `taplab` user. It imports the config files for various applications.


```nix
{ config, pkgs, lib, ... }:

{

  # Home Manager configuration
  home.username = "taplab";
  home.homeDirectory = "/home/taplab";
  home.stateVersion = "25.05";


  # Imports other nix files for modular configuration
  imports = [ 
    ./imports/prism.nix
    ./imports/kde.nix
    ./imports/zsh.nix
    ./imports/ghostty.nix
  ];
}
```
#### Notes about the home configuration file:
- Any new application-level configuration should be added here, preferably via a new file imported by this one.

---
### Zsh configuration file
### `imports/zsh.nix`
This file contains the Home Manager configuration for zsh, setting up the useful aliases.

```nix
{ config, pkgs, ... }:

{   
  # Installs zsh and some useful plugins
  home.packages = [
    pkgs.zsh
    pkgs.oh-my-zsh
    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting
  ];

  # Defines the zsh configuration file
  home.file.".zshrc".text = ''

    # Enable oh-my-zsh for themes and plugins
    export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"

    # Enables some zsh plugins
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # More oh-my-zsh settings
    plugins=(git)
    source $ZSH/oh-my-zsh.sh

    # Aliases to update the nix config (testing purposes)
    alias nrt="sudo rsync -av --exclude='.git' ~/nix-config/ /etc/nixos/ && sudo nixos-rebuild test";
    alias nrs="sudo rsync -av --exclude='.git' ~/nix-config/ /etc/nixos/ && sudo nixos-rebuild switch";

    # Alias to pull the lastest configuration from github and update
    alias updatenix="sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh)";

    # Custom aliases to pull credentials over LAN
    alias wifi="bash /etc/nixos/resources/wifi.sh";
    alias mema="bash /etc/nixos/resources/mema.sh";
    alias edge="bash /etc/nixos/resources/edge.sh";

    # Use a custom oh-my-zsh theme
    source ~/.oh-my-zsh/custom/themes/custom.zsh-theme
  '';

  # Defines a custom oh-my-zsh theme
  home.file.".oh-my-zsh/custom/themes/custom.zsh-theme".text = ''
    PROMPT="%F{cyan}%n@%f"
    PROMPT+="%{$fg[blue]%}%M "
    PROMPT+="%{$fg[cyan]%}%~%  "
    PROMPT+="%(?:%{$fg[green]%}%1{➜%} :%{$fg[red]%}%1{➜%} )%{$reset_color%}"

    RPROMPT='$(git_prompt_info)'

    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}git:(%{$fg[blue]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[cyan]%}) %{$fg[yellow]%}%1{✗%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[cyan]%})"
  '';
}
```

---
### KDE Plasma configuration file
### `imports/kde.nix`
This file contains the Home Manager configuration for KDE Plasma, disabling some unnecessary services and defining the taskbar.

```nix
{ config, pkgs, ... }:

{
    # Disables automatic screen locking as this requires a password to unlock
    xdg.configFile."kscreenlockerrc".text = ''
        [Daemon]
        Autolock=false
        LockOnResume=false
        Timeout=0
    '';

    # Disables the kde wallet system as it is not needed and just gets in the way of most users
    xdg.configFile."kwalletrc".text = ''
        [Wallet]
        Close When Idle=false
        Close on Screensaver=false
        Enabled=false
        Idle Timeout=10
        Launch Manager=false
        Leave Manager Open=false
        Leave Open=true
        Prompt on Open=false
        Use One Wallet=true

        [org.freedesktop.secrets]
        apiEnabled=true
    '';

    # Configures the taskbar
    xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc".text = ''
      (This file is very long and mostly irrelevant, main thing it does it define the taskbar layout)
    '';
}
```

---
### Prism Launcher configuration file
### `imports/prism.nix`

This file contains the Home Manager configuration for prism launcher, including the custom script to play on the TAP-lab server.

Here is a commented version of the prism configuration file:
```nix
{ pkgs, ... }:

{
  # Installs prism launcher and the jdk23 package
  home.packages = [
    pkgs.prismlauncher
    pkgs.jdk23
  ];

  # Ensures Prism Launcher is configured correctly, otherwise it will show the setup window when opened
  home.file.".local/share/PrismLauncher/prismlauncher.cfg".text = ''
    [General]
    ApplicationTheme=Breeze
    AutomaticJavaDownload=false
    AutomaticJavaSwitch=true
    ConfigVersion=1.2
    IconTheme=pe_colored
    JavaPath=java
    Language=en_NZ
    LastHostname=nixos
    MainWindowGeometry=@ByteArray(AdnQywADAAAAAAAAAAAAAAAAAx8AAAJXAAAAAAAAAAAAAAMfAAACVwAAAAAAAAAABVYAAAAAAAAAAAAAAx8AAAJX)
    MainWindowState="@ByteArray(AAAA/wAAAAD9AAAAAAAAAo4AAAHpAAAABAAAAAQAAAAIAAAACPwAAAADAAAAAQAAAAEAAAAeAGkAbgBzAHQAYQBuAGMAZQBUAG8AbwBsAEIAYQByAwAAAAD/////AAAAAAAAAAAAAAACAAAAAQAAABYAbQBhAGkAbgBUAG8AbwBsAEIAYQByAQAAAAD/////AAAAAAAAAAAAAAADAAAAAQAAABYAbgBlAHcAcwBUAG8AbwBsAEIAYQByAQAAAAD/////AAAAAAAAAAA=)"
    MaxMemAlloc=8192
    MinMemAlloc=4096
    StatusBarVisible=true
    ToolbarsLocked=false
    UserAskedAboutAutomaticJavaDownload=true
    WideBarVisibility_instanceToolBar="@ByteArray(111111111,BpBQWIumr+0ABXFEarV0R5nU0iY=)"
  '';

  # Copies the minecraft instance from the resources folder to the correct location
  home.activation.copyPrismInstance = ''
    mkdir -p ~/.local/share/PrismLauncher/instances
    cp -r --no-preserve=mode,ownership /etc/nixos/resources/taplab ~/.local/share/PrismLauncher/instances
  '';
  
  # Copies the accounts file to the correct location, and makes a backup of it (used for for the offline script)
  home.activation.copyAccountFile = ''
    mkdir -p ~/.local/share/PrismLauncher
    cp --no-preserve=mode,ownership /etc/nixos/resources/accounts.json ~/.local/share/PrismLauncher/accounts.json
    cp --no-preserve=mode,ownership ~/.local/share/PrismLauncher/accounts.json ~/.local/share/PrismLauncher/accounts.json_ORIGINAL
  '';

  # Copies the offline script to the correct location and makes it executable
  home.activation.copyOfflineScript = ''
    mkdir -p ~/.local/share/PrismLauncher/
    cp /etc/nixos/scripts/offline.sh ~/.local/share/PrismLauncher/offline.sh
    chmod +x ~/.local/share/PrismLauncher/offline.sh
  '';

  # Copies the grass icon for the desktop entry
  home.activation.copyGrassIcon = ''
    mkdir -p ~/.local/share/icons
    cp /etc/nixos/resources/grass.png ~/.local/share/icons/grass.png
  '';

  # Creates a desktop entry for the Minecraft script
  home.file.".local/share/applications/Minecraft.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Minecraft
    Exec=$HOME/.local/share/PrismLauncher/offline.sh
    Icon=grass
    Categories=Game;
    Comment=Use this to play Minecraft on the TAP-Lab server.
  '';
}
```

---
### Auto update service configuration file
### `imports/autoupdate.nix`
This file defines the systemd service and timer configuration for automatically updating the system daily.
```nix
{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        pkgs.libnotify      # For notify-send command
    ];

    # Sets up a systemd service and timer to run the autoupdate script daily
    systemd.services.nixos-update = {
        description = "Periodic NixOS system update with notification";
        serviceConfig = {
        Type = "oneshot";
        # Executes the autoupdate script
        ExecStart = "${pkgs.bash}/bin/bash /home/taplab/nix-config/imports/autoupdate.sh";
        };
    };

    systemd.timers.nixos-update = {
        description = "Update the system daily";
        wantedBy = [ "timers.target" ];
        timerConfig = {
        OnCalendar = "daily";         # Runs the update daily
        Persistent = true;            # Runs the job as soon as possible if it was missed
        };
    };
}
```
---
### Network mounts configuration file
### `imports/mounts.nix`
This file mounts the TAP-lab network drives automatically
````nix
{ config, pkgs, ... }:

{
  # Mounts the manuhiri share
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/nas/manuhiri" = {
    device = "//nas/manuhiri";
    fsType = "cifs";
    options = [
      "guest"
      "nofail"
      "x-systemd.automount"
      "x-systemd.mount-timeout=5"
      "soft"
      "uid=1000" 
      "gid=100"  
      "file_mode=0644"
      "dir_mode=0755"
    ];
  };

  # Mounts the Hacklings share
  fileSystems."/mnt/nas/Hacklings" = {
    device = "//nas/awheawhe/STEaM/Hacklings";
    fsType = "cifs";
    options = [
      "guest"
      "nofail"
      "x-systemd.automount"
      "x-systemd.mount-timeout=5"
      "soft"
      "uid=1000" 
      "gid=100"  
      "file_mode=0644"
      "dir_mode=0755"
    ];
  };

  # Mounts the mema share with credentials
  fileSystems."/mnt/nas/mema" = {
    device = "//nas/mema";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/secrets/mema"
      "nofail"
      "x-systemd.automount"
      "x-systemd.mount-timeout=5"
      "soft"
      "uid=1000" 
      "gid=100"  
      "file_mode=0644"
      "dir_mode=0755"
    ];
  };
}
````

---
### Ghostty configuration file
### `imports/ghostty.nix`
This file contains the configuration for my ghostty setup, mostly there for me to use while making this setup
```nix
{ config, pkgs, ... }:

# Imports the nixpkgs unstable branch to get the correct ghostty version
let
    nixpkgs-unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") { config = { allowUnfree = true; }; };
in
{
    home.packages = [
        nixpkgs-unstable.ghostty
    ];

    # Configures ghostty settings
    home.file.".config/ghostty/config".text = ''
        font-family = DejaVuSansMono
        font-size = 11
        theme = Kitty Default
        custom-shader-animation = always
        custom-shader = cursor.glsl 
        selection-foreground = cell-background
        selection-background = cell-foreground
        selection-clear-on-typing = true
        cursor-color = #ffffff
        foreground = #ffffff
        cursor-click-to-move = true
        focus-follows-mouse = false

        keybind = alt+arrow_down=goto_split:down
        keybind = alt+arrow_up=goto_split:up
        keybind = alt+arrow_left=goto_split:left
        keybind = alt+arrow_right=goto_split:right

        keybind = ctrl+alt+arrow_down=new_split:down
        keybind = ctrl+alt+arrow_up=new_split:up
        keybind = ctrl+alt+arrow_left=new_split:left
        keybind = ctrl+alt+arrow_right=new_split:right
    '';

    # Creates a custom cursor shader for a trailing effect
    home.file.".config/ghostty/cursor.glsl".text = ''
        (large shader to animate the cursor goes here, not important for documentation)
    '';
}
```

## Resources

### `resources/accounts.json`
This is a template accounts file for prism launcher, with a placeholder username that is replaced by the offline script.

It is simply a mostly empty prism launcher accounts file with an offline account called `CHANGETHISNAME`.

```json
{
    "accounts": [
        {
            "profile": {
                "capes": [
                ],
                "id": "",
                "name": "CHANGETHISNAME",
                "skin": {
                    "id": "",
                    "url": "",
                    "variant": ""
                }
            },
            "type": "Offline",
            "ygg": {
                "extra": {
                    "clientToken": "",
                    "userName": "CHANGETHISNAME"
                },
                "iat": 0,
                "token": "0"
            }
        }
    ],
    "formatVersion": 3
}
```

### Servers File
### `resources/servers.ini`
This file contains the list of local servers that the credential pull scripts can use to download the necessary files. It serves to provide a convenient way to choose the server to use without having to remember IP addresses.

It uses a simple `.ini` format with `name=address` pairs.
```ini
default=credentials.nix-config.taplab.nz

callum=192.168.1.220

# Alternate server names - cant be bothered adding support for multiple names per entry
taplab=credentials.nix-config.taplab.nz

```

---
### `resources/taplab/` folder
This folder contains various resources used by the configuration, such as the offline script, and the accounts file.

It also contains the prism launcher instance to be used. This instance is a fabric 1.21.5 instance with some performance mods installed, along with some preconfigured settings for the best performance on the laptops. 

The instance gets copied to the correct location during the activation phase of the Home Manager configuration.

### `resources/grass.png`
This is is simply the default minecraft icon, used for the desktop entry of the minecraft script.