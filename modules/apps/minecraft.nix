{ config, pkgs, nixpkgs-old, ... }:

let
  old = import nixpkgs-old {
    system = pkgs.system or "x86_64-linux";
    config.allowUnfree = true;
  };
  prismdir = "${config.home.homeDirectory}/.local/share/PrismLauncher";
in

{
  home = {
    packages = [
      old.prismlauncher
      pkgs.jdk25

      pkgs.zenity
      pkgs.kdotool
    ];

    activation.copyPrismConfig = ''
      mkdir -p ${prismdir}
      cp --no-preserve=mode,ownership ${../../resources/minecraft/prismlauncher.cfg} ${prismdir}/prismlauncher.cfg
    '';

    activation.copyPrismInstance = ''
      mkdir -p ${prismdir}/instances
      cp -r --no-preserve=mode,ownership ${../../resources/minecraft/taplab} ${prismdir}/instances
    '';

    activation.copyOfflineScript = ''
      mkdir -p ${prismdir}
      install -m 755 ${../../scripts/minecraft.sh} ${prismdir}/minecraft.sh
    '';

    activation.copyGrassIcon = ''
      mkdir -p ~/.local/share/icons
      install -m 644 ${../../resources/minecraft/grass.png} ~/.local/share/icons/grass.png
    '';

    file.".local/share/applications/Minecraft.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Minecraft
      Exec=~/.local/share/PrismLauncher/minecraft.sh
      Icon=grass
      Categories=Game;
      Comment=Use this to play Minecraft on the TAP-Lab server.
    '';
  };
}