# Taplab NixOS Config

This NixOS configuration is made to be used with the TAPLab laptops, with all of the necessary apps and settings pre-configured.

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
    sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nixos-config/main/install.sh)
    ```
7. The script should automatically install NixOS and the configuration. It will automatically reboot when finished.
8. In case of any issues, you can refer to the [Full Instructions](#full-instructions) and the [Technical Explanation](#technical-explanation) sections below.

# Usage Guide

- Most things should be set up after the installation, wifi currently needs to be set up manually but this is easy to do in KDE Plasma.
- In order to update the system, you can use the `updatenix` command in the terminal. This will update the system with the latest stable version of this configuration.
    - The `updatenix` command can be run with an argument to specify a branch, for example `updatenix testing` will switch the system to the `testing` branch. 
    - `updatenix` always updates the system to the latest Nix version.
    - Rebooting after updating is recommended if a large update was performed.
- In order to play Minecraft on the TAPLab server (for Friday sessions), simply run the `Minecraft` app from the KDE menu. Enter your username, and press enter. A prism launcher window will briefly open but should automatically close and the game will launch.
- All other apps can be found in the KDE menu and should work as expected.
- If any extra apps are required, they can be installed locally through the KDE Discover app using Flathub. Please note that apps installed this way will not be present on other laptops, and should not be expected to persist.
- The system is set up to automatically log into the `taplab` user account without needing a password. The account still has a sudo password, for performing admin tasks (e.g updating the system). For the current testing version the password is `taplab` (this should be changed to a more secure password once this is fully rolled out).


# Full Instructions

1. Download the NixOS Minimal ISO from [NixOS Downloads](https://nixos.org/download.html).
2. Create a bootable USB drive using the NixOS ISO. You can use tools like Rufus (Windows) or `dd` (Linux/Mac).
3. Boot the laptop to the USB by pressing F9 during startup and select the USB drive.
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
    sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nixos-config/main/install.sh)
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

### Installation Script
### `install.sh`
The installation script is a bash script that automates the installation of NixOS and the TAPLab configuration.
This is a commented version of the installation script:

```bash
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

rm /mnt/etc/nixos/configuration.nix                                                                                     # Removes the existing configuration file
rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' * /mnt/etc/nixos/         # Copies the configuration files to /mnt/etc/nixos

nixos-install --no-root-passwd      # Installs NixOS without setting a root password to allow for unattended installation

reboot      # Reboots the system
```

#### Notes about the installation script:

- Do not use any branch other than `main` if you want to ensure a working system. I use `testing` to push my changes to in order to test them so it very well may be broken.
- The script assumes that the target disk is `/dev/sda` by default. As far as I have seen this is always the case on the TAPLab laptops, however i have added the `--disk` flag if this is not the case.
- Pretty much as soon as the script is run it will wipe the target disk, so ensure there isn't anything you want to keep on it.
- The script uses a BIOS boot setup, as despite the laptops supposedly supporting UEFI, I have had absolutely no success getting it to work.
- The script automatically allocates 8GB of swap space, which is the correct amount for the spec of the laptops. You may want to adjust this if you are using a different machine.
- No root password is set during installation in order to avoid the user needing to enter it during installation. If a root password is required, it can be set after installation using sudo.


### Update Script
### `update.sh`
The update script is a bash script that automates updating the system to the latest version of this configuration.
This is a commented version of the update script:
```bash
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
    git pull --rebase origin "$BRANCH"                                                                                              # Pulls the latest changes from the target branch
    sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' "$CONFIG_DIR/" /etc/nixos/   # Copies the configuration files to /etc/nixos
    sudo nixos-rebuild switch --upgrade                                                                                             # Rebuilds and updates the system with the latest configuration
    echo
    echo
    echo "Update complete!"
    echo "Please reboot if drivers/kernel were updated."
else        # If the config directory is not present
    echo "Repo not found, cloning to $CONFIG_DIR..."
    git clone --branch "$BRANCH" "$REPO_URL" "$CONFIG_DIR"      # Clones the configuration repository
    cd "$CONFIG_DIR"                                            # Changes to the config directory
    sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' "$CONFIG_DIR/" /etc/nixos/       # Copies the configuration files to /etc/nixos
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


### Minecraft Offline Script
### `resources/offline.sh`
This is a custom bash script that allows users to easily set their Minecraft username and launch the game in offline mode on the TAPLab server.

Here is a commented version of the offline script:
```bash
# Ensures it is working in the correct directory
cd ~/.local/share/PrismLauncher/

# Copies accounts.json_ORIGINAL to accounts.json to reset any previous changes
cp accounts.json_ORIGINAL accounts.json

# Fixes rendering issues with zenity on Wayland by forcing X11
export GDK_BACKEND=x11

# Prompts user for a name using a Zenity GUI
input_name=$(zenity --entry --title="Enter Your Username" --text="Username:")

# Replaces CHANGETHISNAME with the inputted name in accounts.json
sed -i "s/CHANGETHISNAME/$input_name/g" accounts.json

# Kills any running instance of prism launcher otherwise the game does not launch
pkill prismlauncher

# Launches game and automatically connects to the TAPLab server
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


## Configuration files

### `hardware-configuration.nix`
This file is automatically generated by NixOS during installation using the `nixos-generate-config` command. It contains hardware-specific settings for the laptop, and should not be modified manually.

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
    ];

  # Enables GRUB as the boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Defines basic Home Manager configuration
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.taplab = import ./home.nix;

  # Defines the system version and tells it to use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "25.05";

  # Enables networking through NetworkManager.
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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

  # Enables Zsh as default shell - could be changed back to bash for final build but I like zsh
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Enables Flatpak
  services.flatpak.enable = true;

  # Enables OpenSSH server, for debug use but could still be useful
  services.openssh.enable = true;
}
```

#### Notes about the configuration file:
- Any changes should be done with caution as they may break the system.
- Most of this file has been automatically generated by NixOS at some point, and I have only modified the necessary parts to get the desired configuration.

### `imports/pkgs.nix`
This file contains the package configuration for the system. It defines the packages that should be installed globally.

Any packages that are to be added permanently to the system should be added here.

```nix
{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        pkgs.git

        # Dependencies for the minecraft script
        pkgs.zenity
        pkgs.kdotool

        # I use kitty on my pc and ssh tends to break if the host doesn't have it
        pkgs.kitty

        # Taplab apps
        pkgs.blockbench
        pkgs.arduino-ide
        pkgs.chromium
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
    ];
}
```

### `home.nix`
This file contains the Home Manager configuration for the `taplab` user. It imports the config files for zsh and prism launcher.


```nix
{ config, pkgs, lib, ... }:

{

  # Home Manager configuration
  home.username = "taplab";
  home.homeDirectory = "/home/taplab";
  home.stateVersion = "25.05";


  # Imports other nix files for modular configuration
  imports = [ 
    ./imports/zsh.nix
    ./imports/prism.nix
  ];
}

```
#### Notes about the home configuration file:
- Any new application-level configuration should be added here, preferably via a new file imported by this one.

### `imports/bash.nix`
This file contains the Home Manager configuration for bash, setting up the update alias.

```nix
{ config, pkgs, ... }:

{
  # Configuration for bash shell
  home.file.".bashrc".text = ''
    # Defines updatenix alias
    alias updatenix='sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh)';
  '';
}
```


### `imports/kde.nix`
This file contains the Home Manager configuration for KDE Plasma, mostly disabling some problematic features.

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
}
```

### `imports/prism.nix`

This file contains the Home Manager configuration for prism launcher, including the custom script to play on the TAPLab server.

Here is a commented version of the prism configuration file:
```nix
{ pkgs, ... }:

# Defines the path to the java binary
let
  javaPath = "${pkgs.jdk23}/bin/java";
in {
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
    cp /etc/nixos/resources/offline.sh ~/.local/share/PrismLauncher/offline.sh
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

### resources/accounts.json
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

## Resources

### `resources/taplab/` folder
This folder contains various resources used by the configuration, such as the offline script, and the accounts file.

It also contains the prism launcher instance to be used. This instance is a fabric 1.21.5 instance with some performance mods installed, along with some preconfigured settings for the best performance on the laptops. 

The instance gets copied to the correct location during the activation phase of the Home Manager configuration.

### `resources/grass.png`
This is is simply the default minecraft icon, used for the desktop entry of the minecraft script.




## TODO / Current Progress
Things I need to do before this is fully ready. In no particular order

- Set up a proper user account with a secure password.
- Set up Microsoft Edge with automatic login to the taplab account.
- ~~Set up a local binary cache for faster installs/updates.~~  Managed to set up a good local demo, working version is in the [`cache-stable`](https://github.com/clamlum2/taplab-nix-config/tree/cache-stable) branch. Not gonna bother to make a cache server config as most of it is best done manually. Also added a shell alias to easily copy all of the new packages to the server on an update, requires a bit of manual work due to needing the server credentials but is required for security.
- Comprehensive testing across all laptops and apps to ensure everything works as expected.
- Potentially host this on a local git server for easier access.
- Set up wifi out of the box on the installed system. (would do but can't really test at home through virtual machines)
- ~~Find the best solution for hiding/notifying about the prism launcher login prompt.~~ Managed to integrate it into the script, after running the prism launcher command it will check the active window, and if it contains "Prism" in the title it will automatically close it.
- Set up auto-updates for the system.
- ~~Move shell alias to bash config and remove zsh~~
- Set up more KDE settings ~~and move to separate file.~~
- ~~Move packages to separate file for clearer configuration.nix~~
