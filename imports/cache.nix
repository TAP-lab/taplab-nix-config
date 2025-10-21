{ config, pkgs, ... }:

let
  cacheServer = "192.168.1.220";
  cachePublicKey = "local-cache:cjQnJ60NunD/sRVXLSrLSAhmxCQa1Iuo2HHI7rpFfPc="; 
in

{
  nix.settings.substituters = [ "http://${cacheServer}:5000" ];
  nix.settings.trusted-public-keys = [ cachePublicKey ];

  environment.systemPackages = with pkgs; [
    pkgs.sshpass
  ];
}