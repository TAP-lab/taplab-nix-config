# Taplab NixOS Config

This NixOS configuration is made to be used with the TAP-lab laptops, with all of the necessary apps and settings pre-configured.

# Table of Contents

- [Quick Start Guide](#quick-start-guide)
- [Usage Guide](#usage-guide)
- [Full Instructions](#full-instructions)
- [Rebuild Script](#rebuild-script)


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
8. In case of any issues, you can refer to the [Full Instructions](#full-instructions), have a read through the full documentation, or contact Callum (clamlum2@gmail.com).

# Usage Guide

- Most things should be set up after the installation, wifi can be set up by running `wifi` in terminal to pull the credentials from the local server, or by setting it up manually just like you would on windows.

- In order to update the system, you can use the [Rebuild Script](#rebuild-script). This will update the system with the latest stable version of this configuration. More details about the update script can be found in the dedicated section about it.

- In order to play Minecraft on the TAP-lab server (for Friday sessions), simply run the `Minecraft` app from the taskbar. Enter your username, and press enter. A prism launcher window will briefly open but should automatically close and the game will launch.

- All other apps can be found in the start menu and should work as expected.

- The system is set up to automatically log into the `taplab` user account without needing a password. The account still has a sudo password, for performing admin tasks (e.g updating the system). The system should be fully usable without needing a password, however.

- The system has 3 network shares automatically mounted, manuhiri, Hacklings , and mema. The first 2 should mount automatically provided the laptop is on the TAP-lab network. The mema share requires credentials to access, which can be pulled from the local server by running the `mema` command in terminal.

- There is a script to automatically set up Microsoft Edge to log in to the TAP-lab account. This can be run by executing the `edge` command in terminal. This also requires the laptop to be on the TAP-lab network.


# Full Instructions

1. Download the NixOS Minimal ISO from [NixOS Downloads](https://nixos.org/download.html).
2. Create a bootable USB drive using the NixOS ISO. You can use tools like Rufus (Windows) or `dd` (Linux/Mac).
3. Plug the USB into the laptop and boot from it by pressing F9 during startup and select the USB drive.
4. Once booted into the live environment, run `sudo -i` to change to the root user.
5. Preferably, plug the laptop into ethernet, if this is not possible set up wifi like so:
    - Run `systemctl start NetworkManager` to start the wifi service.
    - Navigate to `Activate a connection` using the arrow keys and enter.
    - Select the appropriate wifi network and enter the password when prompted.
    - Exit the menu by pressing escape a few times until you are back in the terminal.
6. Check for internet connectivity by running `ping google.com`. If there is no connectivity, double check the previous steps.
7. To use the install script, simply run the following command:
    ```bash
    sh <(curl https://raw.githubusercontent.com/TAP-lab/taplab-nix-config/main/install.sh)
    ```
    - The script has many flags that can be used to customize the installation, but the defaults should work for most cases.
    - `--branch` can be used to specify which branch of the config repo to use. The default is `main` and should be used unless you want to test out a specific branch.
    - `--disk` can be used to specify which disk to install to. The default is `/dev/sda` and should be correct when installing on any of the TAP-lab laptops, however make sure to double check if the computer has anything you want to keep on it.
    - `--hostname` can be used to specify the hostname to use for the nix flake. This is currently only `nixos` and should not be changed.
    - `swap` defines the swap size in GB, the default is 8 which is the correct amount for the TAP-lab laptops. Setting this to 0 will disable swap.
    - `--skip-install` can be used to skip the installation step, allowing for further configuration before installing. This should not be necessary for normal use.
    - `--help` can be used to show a brief help message describing these flags.

8. The script should automatically install NixOS and the configuration. It will automatically reboot when finished.

#### In case of any issues, please Contact Callum (clamlum2@gmail.com).


# Rebuild Script

The rebuild script is a shell script that can be used to execute the nixos rebuild command, with some custom parameters. The main use case for this script is to update the system with the latest version of the configuration. This can be done by running `nrs -u` in the terminal.
The script has some other flags that are mainly used for testing and development.
- `--action` can be used to specify which nixos-rebuild action to use. The default is `test`, which will build the new configuration, however it will not switch to it, meaning any changes will be lost after rebooting. This is mainly used to rapidly test out changes to the configuration during development. The `switch` action will build the new configuration and switch to it immediately, meaning the changes will persist after rebooting.
- These are the main 2 rebuild actions, and have custom shell aliases to run them quickly, `nrt` for `test` and `nrs` for `switch`.
- `--branch` can be used to specify which branch of the config repo to use. The default is `main`.
- `--hostname` can be used to specify the hostname to use for the nix flake. The script will automatically use the current hostname, so this is only necessary if you want to use a different flake output.
- `--upgrade` pulls the latest changes from the config repo before rebuilding. If the config repo does not exist, it will be cloned from GitHub. This is the recommended way to update the system, as it ensures you are using the latest version of the configuration.
- All of these flags can be used in short form, by prefixing the first letter with a single dash, for example `-a` for `--action`.
- The valid single-letter flags are `-a`, `-b`, `-h`, and `-u`.

Alongside the rebuild script there is the `ncg` (nix-collect-garbage) shell alias. This clears all old versions of the system out, freeing up disk space. This should be run after any big updates, as keeping old generations around can take up a lot of disk space.