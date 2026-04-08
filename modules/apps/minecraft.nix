{ config, pkgs, nixpkgs-old, ... }:

# Sets up the older version of nixpkgs, as the newer version of prism launcher has issues
let
  old = import nixpkgs-old {
    system = pkgs.system or "x86_64-linux";
    config.allowUnfree = true;
  };
  prismdir = "${config.home.homeDirectory}/.local/share/PrismLauncher";
in

{
  home = {

    # Installs the packages needed for minecaft, and the script.
    packages = [
      old.prismlauncher
      pkgs.jdk25

      pkgs.zenity
      pkgs.kdotool
    ];

    # Copies the prism launcher config.
    activation.copyPrismConfig = ''
      mkdir -p ${prismdir}
      cp --no-preserve=mode,ownership ${../../resources/minecraft/prismlauncher.cfg} ${prismdir}/prismlauncher.cfg
    '';

    # Copies the TAP-Lab instance to the prism launcher instances directory.
    activation.copyPrismInstance = ''
      mkdir -p ${prismdir}/instances
      rm -rf ${prismdir}/instances/taplab
      cp -rT --no-preserve=mode,ownership ${../../resources/minecraft/taplab} ${prismdir}/instances/taplab
    '';

    # Copies the script to launch minecraft.
    activation.copyOfflineScript = ''
      mkdir -p ${prismdir}
      install -m 755 ${../../scripts/minecraft.sh} ${prismdir}/minecraft.sh
    '';

    # Copies the icon for the script.
    activation.copyGrassIcon = ''
      mkdir -p ~/.local/share/icons
      install -m 644 ${../../resources/icons/grass.png} ~/.local/share/icons/grass.png
    '';

    # Creates a desktop entry for the script.
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