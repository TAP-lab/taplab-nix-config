{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.git
    pkgs.appimage-run

    # Taplab apps
    pkgs.blockbench
    pkgs.arduino-ide
    pkgs.microsoft-edge
    pkgs.vlc
    pkgs.freecad
    pkgs.krita
    pkgs.orca-slicer
    pkgs.nomacs
    pkgs.inkscape
    pkgs.p7zip
    pkgs.blender
    pkgs.vscode
    pkgs.luanti
    pkgs.pixelorama

    (import ./apps/gb-studio.nix { inherit pkgs; icon = ../resources/icons/gb-studio.png; })
  ];
}