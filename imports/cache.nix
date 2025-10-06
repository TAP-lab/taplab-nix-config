{ config, ... }:

{
  nix.settings.substituters = [ "http://192.168.1.180:5000" ];
  nix.settings.trusted-substituters = [ "http://192.168.1.180:5000" ];
  nix.settings.trusted-public-keys = [ "local-cache:hCuO1qKsO9DuwvGqG180WyTIXPq6Gv36GWUBeux0CrA=" ];
}