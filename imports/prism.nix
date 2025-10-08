{ pkgs, ... }:

# Defines the path to the java binary
let
  javaPath = "${pkgs.jdk23}/bin/java";
in {
  # Installs prism launcher and the jdk23 package
  home.packages = [
    pkgs.prismlauncher
    pkgs.jdk23
  ];

  # Ensures Prism Launcher is configured correctly, otherwise it will show the setup window when opened
  home.file.".local/share/PrismLauncher/prismlauncher.cfg".text = ''
    [General]
    ApplicationTheme=Breeze
    AutomaticJavaDownload=false
    AutomaticJavaSwitch=true
    ConfigVersion=1.2
    IconTheme=pe_colored
    JavaPath=java
    Language=en_NZ
    LastHostname=nixos
    MainWindowGeometry=@ByteArray(AdnQywADAAAAAAAAAAAAAAAAAx8AAAJXAAAAAAAAAAAAAAMfAAACVwAAAAAAAAAABVYAAAAAAAAAAAAAAx8AAAJX)
    MainWindowState="@ByteArray(AAAA/wAAAAD9AAAAAAAAAo4AAAHpAAAABAAAAAQAAAAIAAAACPwAAAADAAAAAQAAAAEAAAAeAGkAbgBzAHQAYQBuAGMAZQBUAG8AbwBsAEIAYQByAwAAAAD/////AAAAAAAAAAAAAAACAAAAAQAAABYAbQBhAGkAbgBUAG8AbwBsAEIAYQByAQAAAAD/////AAAAAAAAAAAAAAADAAAAAQAAABYAbgBlAHcAcwBUAG8AbwBsAEIAYQByAQAAAAD/////AAAAAAAAAAA=)"
    MaxMemAlloc=8192
    MinMemAlloc=4096
    StatusBarVisible=true
    ToolbarsLocked=false
    UserAskedAboutAutomaticJavaDownload=true
    WideBarVisibility_instanceToolBar="@ByteArray(111111111,BpBQWIumr+0ABXFEarV0R5nU0iY=)"
  '';

  # Copies the minecraft instance from the resources folder to the correct location
  home.activation.copyPrismInstance = ''
    mkdir -p ~/.local/share/PrismLauncher/instances
    cp -r --no-preserve=mode,ownership /etc/nixos/resources/taplab ~/.local/share/PrismLauncher/instances
  '';
  
  # Copies the accounts file to the correct location, and makes a backup of it (used for for the offline script)
  home.activation.copyAccountFile = ''
    mkdir -p ~/.local/share/PrismLauncher
    cp --no-preserve=mode,ownership /etc/nixos/resources/accounts.json ~/.local/share/PrismLauncher/accounts.json
    cp --no-preserve=mode,ownership ~/.local/share/PrismLauncher/accounts.json ~/.local/share/PrismLauncher/accounts.json_ORIGINAL
  '';

  # Copies the offline script to the correct location and makes it executable
  home.activation.copyOfflineScript = ''
    mkdir -p ~/.local/share/PrismLauncher/
    cp /etc/nixos/resources/offline.sh ~/.local/share/PrismLauncher/offline.sh
    chmod +x ~/.local/share/PrismLauncher/offline.sh
  '';

  # Copies the grass icon for the desktop entry
  home.activation.copyGrassIcon = ''
    mkdir -p ~/.local/share/icons
    cp /etc/nixos/resources/grass.png ~/.local/share/icons/grass.png
  '';

  # Creates a desktop entry for the Minecraft script
  home.file.".local/share/applications/Minecraft.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Minecraft
    Exec=$HOME/.local/share/PrismLauncher/offline.sh
    Icon=grass
    Categories=Game;
    Comment=Use this to play Minecraft on the TAP-Lab server.
  '';
}