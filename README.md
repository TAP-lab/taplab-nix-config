## Taplab NixOS Config

This NixOS configuration is made to be used with the TAPLab laptops, with all of the necessary apps and settings pre-configured.

## Table of Contents

- [Quick Start Guide](#quick-start-guide)
- [Full Instructions](#full-instructions)
- [Technical Explanation](#technical-explanation)


## Quick Start Guide

1. Download the NixOS Minimal ISO from [NixOS Downloads](https://nixos.org/download.html).
2. Create a bootable USB drive using the NixOS ISO.
3. Boot the laptop to the USB by pressing F9 during startup and select the USB drive.
4. Once booted into the live environment, run `sudo -i` to change to the root user.
5. Ensure the laptop is plugged into ethernet (wifi is annoying to set up). Try `ping google.com` to check for internet connectivity.
6. To use the install script, simply run the following command:
```bash
sh <(curl -L https://raw.githubusercontent.com/clamlum2/taplab-nixos-config/main/install.sh)
```
7. The script should automatically install NixOS and the configuration. It will automatically reboot when finished.
8. In the case of any issues, you can refer to the [Full Instructions](#full-instructions) and the [Technical Explanation](#technical-explanation) sections below.