{ config, pkgs, lib, ... }:

{

  # Home Manager configuration
  home.username = "taplab";
  home.homeDirectory = "/home/taplab";
  home.stateVersion = "25.05";


  # Imports other nix files for modular configuration
  imports = [
    ./imports/prism.nix
    ./imports/kde.nix
    ./imports/zsh.nix
    ./imports/ghostty.nix
  ];

  # GTK Icon Theme Configuration
  home.packages = [
    pkgs.adwaita-icon-theme
    pkgs.kdePackages.breeze
  ];

  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # home.sessionVariables = {
  #   XCURSOR_THEME = "breeze_cursors";
  #   XCURSOR_SIZE  = "24";
  # };

  # dconf.settings = {
  #   "org/cinnamon/desktop/interface" = {
  #     "cursor-theme" = "breeze_cursors";
  #     "cursor-size"  = 24;
  #   };
  # };

  gtk.iconTheme = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };

  # GTK Bookmarks Configuration
  home.file."/.config/gtk-3.0/bookmarks".text = ''
    file:///mnt/nas/Hacklings Hacklings
    file:///mnt/nas/manuhiri manuhiri
    file:///mnt/nas/mema mema
  '';

  home.file."/.config/gtk-4.0/bookmarks".text = ''
    file:///mnt/nas/Hacklings Hacklings
    file:///mnt/nas/manuhiri manuhiri
    file:///mnt/nas/mema mema
  '';
}