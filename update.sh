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