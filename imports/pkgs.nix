{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        pkgs.git
        pkgs.avahi

        # Dependencies for the minecraft script
        pkgs.zenity
        pkgs.kdotool

        # Taplab apps
        pkgs.blockbench
        pkgs.arduino-ide
        pkgs.chromium
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
    ];
}