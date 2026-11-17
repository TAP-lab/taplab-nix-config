{ pkgs, ... }:
let
  autoUpdateScript = pkgs.writeShellApplication {
    name = "nixos-auto-update";
    runtimeInputs = [
      pkgs.git
      pkgs.nix
      pkgs.nixos-rebuild
      pkgs.systemd
    ];
    text = ''
      set -euo pipefail

      REPO="https://github.com/tap-lab/taplab-nix-config"

      if [[ -f /etc/branch ]]; then
        BRANCH=$(cat /etc/branch)
      else
        BRANCH="main"
      fi

      GRUB_DEVICE="/dev/sda"
      if [[ -f /etc/grub-device ]]; then
        GRUB_DEVICE=$(cat /etc/grub-device)
      fi

      BOOT_MODE="bios"
      if [[ -f /etc/boot-mode ]]; then
        BOOT_MODE=$(cat /etc/boot-mode)
      fi

      systemd-run --no-block --collect --unit=nixos-auto-rebuild --setenv=TAPLAB_GRUB_DEVICE="$GRUB_DEVICE" --setenv=TAPLAB_BOOT_MODE="$BOOT_MODE" nixos-rebuild switch --impure --flake "$REPO/?ref=$BRANCH#$(cat /etc/hostname)"
      echo "$BRANCH" > /etc/branch
      echo "Rebuild complete"
      echo "Running garbage collection"
      nix-collect-garbage -d
      echo "Garbage collection complete"
    '';
  };
in
{
  environment.systemPackages = [ autoUpdateScript ];

  systemd.services.nixos-auto-update = {
    description = "NixOS Auto Update Service";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Delegate = "yes";
      ExecStart = "${autoUpdateScript}/bin/nixos-auto-update";
    };
  };

  systemd.timers.nixos-auto-update = {
    description = "NixOS Auto Update Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
  };
}
