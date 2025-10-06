{ config, ... }:

{
  nix.settings.substituters = [ "http://192.168.1.15:5000" ];
  nix.settings.trusted-substituters = [ "http://192.168.1.15:5000" ];
  nix.settings.trusted-public-keys = [ "local-cache:bTcHjFnTSNI0DZbDgx7sslss0784KUoQybZgUOTUbTc=" ];
}