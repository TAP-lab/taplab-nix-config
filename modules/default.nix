{
  imports = [
    ./configuration.nix
    ./pkgs.nix
    ./nas.nix
    ./auto-update.nix
    ./debug.nix
    ./credentials.nix
  ];

  home-manager.backupFileExtension = "backup";
  home-manager.users = {
    taplab = {
      imports = [ ./home.nix ];
      home.username = "taplab";
      home.homeDirectory = "/home/taplab";
    };
    root = {
      imports = [ ./home.nix ];
      home.username = "root";
      home.homeDirectory = "/root";
    };
  };
}
