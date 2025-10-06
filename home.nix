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
    ./imports/kde.nix
  ];
}