{ config, ... }:

let
  cacheServer = "http://192.168.1.220:5000";
  cachePublicKey = "local-cache:WrEu920wGa4xt2v2DjM0x9wf+/KLHb4+qV7tQqQJxw0="; 
in

{
  nix.settings.substituters = [ cacheServer ];
  nix.settings.trusted-public-keys = [ cachePublicKey ];
}