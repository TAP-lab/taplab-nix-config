{ config, pkgs, lib, nixpkgs-unstable, ... }:

let
  unstable = import nixpkgs-unstable {
    system = pkgs.system or "x86_64-linux";
    config.allowUnfree = true;
  };
in

{
  home.username = "taplab";
  home.homeDirectory = "/home/taplab";
  home.stateVersion = "25.11";

  home.file.".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  gtk.iconTheme = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };

  home.file."/.config/gtk-3.0/bookmarks".text = ''
    file:///mnt/nas/Hacklings Hacklings
    "file:///mnt/nas/Inventors Guild" "Inventors Guild"
    file:///mnt/nas/manuhiri manuhiri
    file:///mnt/nas/mema mema
  '';

  home.file."/.config/gtk-4.0/bookmarks".text = ''
    file:///mnt/nas/Hacklings Hacklings
    "file:///mnt/nas/Inventors Guild" "Inventors Guild"
    file:///mnt/nas/manuhiri manuhiri
    file:///mnt/nas/mema mema
  '';
}
