{ config, pkgs, ... }:

{
  home.file.".bashrc".text = ''
    # Enable bash completion if available
    if [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi

    # User specific aliases and functions
    alias updatenix='sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh)';

    # Add custom bin directory to PATH
    export PATH="$HOME/bin:$PATH"
  '';
}