{ config, ... }:

let
  cacheServer = "http://192.168.1.182:5000";
  cachePublicKey = "local-cache:lF8a6CjzBqT9J38ERYQIUcaEn/Gb5TQ/nuwq9KjTLIA="; 
in

{
  nix.settings.substituters = [ cacheServer ];
  nix.settings.trusted-substituters = [ cacheServer ];
  nix.settings.trusted-public-keys = [ cachePublicKey ];
}