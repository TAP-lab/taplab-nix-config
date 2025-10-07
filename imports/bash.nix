{ config, pkgs, ... }:

{
  # Configuration for bash shell
  home.file.".bashrc".text = ''
    # Defines updatenix alias
    alias updatenix='sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh)';
  '';
}