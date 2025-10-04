REPO_URL="https://github.com/clamlum2/taplab-nix-config.git"
CONFIG_DIR="$HOME/nix-config"

if [ -z "$1" ]; then
    if [ -d "$CONFIG_DIR/.git" ]; then
        BRANCH=$(git -C "$CONFIG_DIR" rev-parse --abbrev-ref HEAD)
    else
        BRANCH="main"
    fi
else
    BRANCH="$1"
fi

echo
echo "Using branch: $BRANCH"
echo

if [ -d "$CONFIG_DIR/.git" ]; then
    echo "Repo found at $CONFIG_DIR, pulling changes..."
    cd "$CONFIG_DIR"
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
        echo "Current branch ($CURRENT_BRANCH) is different from target branch ($BRANCH)."
        git checkout "$BRANCH"
    fi
    git pull --rebase origin "$BRANCH"
else
    echo "Repo not found, cloning to $CONFIG_DIR..."
    git clone --branch "$BRANCH" "$REPO_URL" "$CONFIG_DIR"
fi