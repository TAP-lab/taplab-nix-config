{ config, ... }:

{
  nix.settings.substituters = [ "http://192.168.1.15:5000" ];
  nix.settings.trusted-substituters = [ "http://192.168.1.15:5000" ];
  nix.settings.trusted-public-keys = [ "local-cache:5O2Wic2bmKaczr9t6eppTnoBJ+W/4FHXEyZ0PkQG4xk=" ];
}