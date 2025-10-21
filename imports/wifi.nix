{ config, pkgs, ... }:

let
  wifiResult = builtins.tryEval (import /etc/nixos/fetch/wifi-details.nix);
in
{
  networking.wireless.enable = true;
  networking.wireless.networks =
    if wifiResult.success then {
      "${wifiResult.value.ssid}" = {
        psk = wifiResult.value.psk;
      };
    } else {};
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "wlo1" ];
}