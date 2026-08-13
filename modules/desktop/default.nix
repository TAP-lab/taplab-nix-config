{
  imports = [
    ./kde.nix
  ];

  home-manager.users.taplab.imports = [
    ./plasma-manager.nix
    ./gtk.nix
  ];
}
