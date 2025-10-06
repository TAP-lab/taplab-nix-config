{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        pkgs.git

        # for the minecraft script
        pkgs.zenity

        # i use kitty on my pc and ssh tends to break if the host doesn't have it
        pkgs.kitty

        # taplab apps
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