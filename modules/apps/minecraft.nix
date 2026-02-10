{ config, pkgs, nixpkgs-old, ... }:

let
  old = import nixpkgs-old {
    system = pkgs.system or "x86_64-linux";
    config.allowUnfree = true;
  };
in

{
  home = {
    packages = [
      old.prismlauncher
      pkgs.jdk25

      pkgs.zenity
      pkgs.kdotool
    ];

    file.".local/share/PrismLauncher/prismlauncher.cfg".source = ../../resources/minecraft/prismlauncher.cfg;

    activation.copyPrismInstance = ''
      mkdir -p ~/.local/share/PrismLauncher/instances
      cp -r --no-preserve=mode,ownership ~/nix-config/resources/minecraft/taplab ~/.local/share/PrismLauncher/instances
    '';

    activation.copyAccounts = ''
      mkdir -p ~/.local/share/PrismLauncher/accounts
      cp ~/nix-config/resources/minecraft/accounts.json ~/.local/share/PrismLauncher/accounts.json
      cp ~/.local/share/PrismLauncher/accounts.json ~/.local/share/PrismLauncher/accounts.json_ORIGINAL
    '';

    activation.copyOfflineScript = ''
      mkdir -p ~/.local/share/PrismLauncher/
      cp ~/nix-config/scripts/minecraft.sh ~/.local/share/PrismLauncher/minecraft.sh
      chmod +x ~/.local/share/PrismLauncher/minecraft.sh
    '';

    activation.copyGrassIcon = ''
      mkdir -p ~/.local/share/icons
      cp ~/nix-config/resources/minecraft/grass.png ~/.local/share/icons/grass.png
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