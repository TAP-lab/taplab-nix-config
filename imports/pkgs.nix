{ config, pkgs, ... }:

{
    environment.systemPackages = [
        pkgs.git
        pkgs.appimage-run

        # Dependencies for the minecraft script
        pkgs.zenity
        pkgs.kdotool

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

        # For debugging
        pkgs.libsForQt5.kdbusaddons

        (import ./gb-studio.nix)
    ];
}