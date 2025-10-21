{ config, pkgs, ... }:

let
  wifi = builtins.tryEval (import /etc/nixos/fetch/wifi-details.nix);
in
{
  networking.wireless.enable = true;
  networking.wireless.networks =
    if wifi.success then {
      "${wifi.value.ssid}" = {
        psk = wifi.value.psk;
      };
    } else {};
}