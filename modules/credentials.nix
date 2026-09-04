{ pkgs, ... }:
let
  autoSetupScript = pkgs.writeShellApplication {
    name = "credentials-setup";
    runtimeInputs = with pkgs; [
      openssh
      curl
    ];
    text = builtins.readFile ../scripts/credentials/auto-setup.sh;
  };
  edgeScript = pkgs.writeShellApplication {
    name = "edge-setup";
    runtimeInputs = with pkgs; [
      openssh
      curl
    ];
    text = builtins.readFile ../scripts/credentials/edge.sh;
  };
  memaScript = pkgs.writeShellApplication {
    name = "mema-setup";
    runtimeInputs = with pkgs; [
      openssh
      curl
    ];
    text = builtins.readFile ../scripts/credentials/mema.sh;
  };
  minecraftAccountScript = pkgs.writeShellApplication {
    name = "minecraft-setup";
    runtimeInputs = with pkgs; [
      openssh
      curl
    ];
    text = builtins.readFile ../scripts/credentials/minecraft-account.sh;
  };
  orcaslicerScript = pkgs.writeShellApplication {
    name = "orcaslicer-setup";
    runtimeInputs = with pkgs; [
      openssh
      curl
    ];
    text = builtins.readFile ../scripts/credentials/orcaslicer.sh;
  };
  wifiScript = pkgs.writeShellApplication {
    name = "wifi-setup";
    runtimeInputs = with pkgs; [
      openssh
      curl
    ];
    text = builtins.readFile ../scripts/credentials/wifi.sh;
  };

in
{
  environment = {
    systemPackages = [
      autoSetupScript
      edgeScript
      memaScript
      minecraftAccountScript
      orcaslicerScript
      wifiScript
    ];
    etc."servers.ini".source = ../resources/servers.ini;
  };
}
