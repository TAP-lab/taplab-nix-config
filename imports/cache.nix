{ config, pkgs,... }:

let
  cacheServer = "192.168.1.220";
  cachePublicKey = "local-cache:WrEu920wGa4xt2v2DjM0x9wf+/KLHb4+qV7tQqQJxw0="; 
in

{
  nix.settings.substituters = [ "http://${cacheServer}:5000" ];
  nix.settings.trusted-public-keys = [ cachePublicKey ];

  environment.systemPackages = with pkgs; [
    pkgs.sshpass
  ];
}