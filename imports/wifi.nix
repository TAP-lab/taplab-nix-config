{ config, ... }:

let
  ssid = builtins.readFile "/etc/nixos/fetch/wifi-ssid.txt";
  psk = builtins.readFile "/etc/nixos/fetch/wifi-psk.txt";
in {
  networking.networkmanager.enable = true;
  networking.networkmanager.connectionProfiles = [
    {
      connection.id = "wifi";
      connection.type = "802-11-wireless";
      802-11-wireless.ssid = ssid;
      802-11-wireless-security.psk = psk;
    }
  ];
}