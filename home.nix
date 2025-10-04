{ config, pkgs, lib, ... }:

{

  # Home Manager configuration
  home.username = "taplab";
  home.homeDirectory = "/home/taplab";
  home.stateVersion = "25.05";


  # Import all nix files for modular configuration
  imports = [ 
    ./imports/zsh.nix
    ./imports/prism.nix
  ];

  # Disable automatic screen locking
  xdg.configFile."kscreenlockerrc".text = ''
    [Daemon]
    Autolock=false
    LockOnResume=false
    Timeout=0
  '';

  # Disable the kde wallet system
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
