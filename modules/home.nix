{ config, pkgs, lib, ... }:

{
  # Sets up the home manager configuration for the taplab user.
  home.username = "taplab";
  home.homeDirectory = "/home/taplab";
  home.stateVersion = "25.11";

  # Enables the nix command, and flakes.
  home.file.".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Sets up some GTK configuration, mainly to set up the bookmarks for the file manager.
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  home.file."/.config/gtk-3.0/bookmarks".text = ''
    file:///mnt/nas/Hacklings Hacklings
    file:///mnt/nas/Inventors-Guild Inventors Guild
    file:///mnt/nas/manuhiri manuhiri
    file:///mnt/nas/mema mema
  '';

  home.file."/.config/gtk-4.0/bookmarks".text = ''
    file:///mnt/nas/Hacklings Hacklings
    file:///mnt/nas/Inventors-Guild Inventors Guild
    file:///mnt/nas/manuhiri manuhiri
    file:///mnt/nas/mema mema
  '';
}
