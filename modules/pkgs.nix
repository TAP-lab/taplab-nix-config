{ config, pkgs, ... }:

{
  # Allows installing unfree packages, which is required for some of the apps.
  nixpkgs.config.allowUnfree = true;

  # Installs the packages needed for the system.
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
    pkgs.libreoffice

    # Imports the custom gb-studio package.
    (pkgs.callPackage ./apps/gb-studio.nix {})
  ];
}