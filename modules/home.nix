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
}
