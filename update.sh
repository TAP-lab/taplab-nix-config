REPO_URL="https://github.com/clamlum2/taplab-nix-config.git"
CONFIG_DIR="$HOME/nix-config"
BRANCH="${1:-main}"

if [ -d "$CONFIG_DIR/.git" ]; then
    echo "Repo found at $CONFIG_DIR. Updating..."
    cd "$CONFIG_DIR" || { echo "Failed to cd to $CONFIG_DIR"; exit 1; }
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "On branch: $CURRENT_BRANCH"
    git pull origin "$CURRENT_BRANCH"
    sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' "$CONFIG_DIR/" /etc/nixos/
    sudo nixos-rebuild switch --upgrade --profile-name "config updated ($CURRENT_BRANCH) $(date '+%Y-%m-%d_%H-%M-%S')"
    sudo nix-collect-garbage -d
else
    echo "Repo not found. Cloning branch '$BRANCH' to $CONFIG_DIR..."
    git clone --branch "$BRANCH" "$REPO_URL" "$CONFIG_DIR"
    cd "$CONFIG_DIR" || { echo "Failed to cd to $CONFIG_DIR"; exit 1; }
    sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' --exclude='update.sh' "$CONFIG_DIR/" /etc/nixos/
    sudo nixos-rebuild switch --upgrade --profile-name "config updated ($BRANCH) $(date '+%Y-%m-%d_%H-%M-%S')"
    sudo nix-collect-garbage -d
fi