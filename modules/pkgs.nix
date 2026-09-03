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

    (pkgs.mblock-mlink.overrideAttrs (old: {
      src = pkgs.fetchurl {
        url = "http://srv.it.taplab.nz/apps/linux/mlink.deb";
        sha256 = "sha256-KLxj81ZjbEvhhaz0seNB4WXX5ybeZ7/WcT1dGfdWle0=";
      };
    }))

    # Imports the custom gb-studio package.
    (pkgs.callPackage ./apps/gb-studio.nix {})
  ];
}