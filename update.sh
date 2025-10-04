# defines the repo that the configuration will be pulled from
REPO_URL="https://github.com/clamlum2/taplab-nix-config.git"

# defines the location of the nix config
CONFIG_DIR="$HOME/nix-config"

# defined the branch to use, will it from take the trailing arugment, or default to "main"
BRANCH="${1:-main}"

# checks if the nix-config repo is already present      NEED TO UPDATE, CURRENTLY POORLY IMPLEMENTED
if [ -d "$CONFIG_DIR/.git" ]; then
    echo "Repo found at $CONFIG_DIR. Updating..."
    cd "$CONFIG_DIR"

    # gets the currently downloaded branch      ALSO NEED TO UPDATE
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "On branch: $CURRENT_BRANCH"

    # updates the repo to the latest version
    git pull origin "$CURRENT_BRANCH"

    # moves the new configuration files to the nix directory
    sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' "$CONFIG_DIR/" /etc/nixos/

    # rebuilds the nix config and updates the system
    sudo nixos-rebuild switch --upgrade --profile-name "config updated ($CURRENT_BRANCH) $(date '+%Y-%m-%d_%H-%M-%S')"

    # deletes unused files
    sudo nix-collect-garbage -d
    echo
    echo
    echo "Please reboot if drivers/kernel were updated."
else
    echo "Repo not found. Cloning branch '$BRANCH' to $CONFIG_DIR..."

    # clones the repo to be used
    git clone --branch "$BRANCH" "$REPO_URL" "$CONFIG_DIR"
    cd "$CONFIG_DIR"

    # moves the new configuration files to the nix directory
    sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' "$CONFIG_DIR/" /etc/nixos/

    # rebuilds the nix config and updates the system
    sudo nixos-rebuild switch --upgrade --profile-name "config updated ($BRANCH) $(date '+%Y-%m-%d_%H-%M-%S')"
    
    # deletes unused files
    sudo nix-collect-garbage -d
    echo
    echo
    echo "Please reboot if drivers/kernel were updated."
fi

# GOING TO UPDATE WHOLE SCRIPT