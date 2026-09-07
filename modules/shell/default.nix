let
  shellImports = [
    ./zsh.nix
    ./themes/taplab-theme.nix
  ];
in
{
  home-manager.users = {
    taplab.imports = shellImports;

    root.imports = shellImports;
  };
}
