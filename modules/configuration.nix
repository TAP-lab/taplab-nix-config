{ pkgs, ... }:

{
  # Enables the GRUB bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];
  boot.loader.grub.efiSupport = false;

  # Specifies the kernal to use.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enables NetworkManager.
  networking.networkmanager.enable = true;

  # Enables the OpenSSH server for remote access.
  services.openssh.enable = true;

  # Sets the system state version - this should not be changed.
  system.stateVersion = "25.11";

  # Sets the hostname and domain for the system.
  networking.hostName = "nixos";
  networking.domain = "taplab.nz";

  # Sets the network-facing hostname from the number in /etc/taplab-laptop-number, if it exists. This is used to identify the device on the network (e.g. via DHCP/SSH) without changing its local hostname from nixos
  systemd.services.set-network-hostname = {
    wantedBy = [ "multi-user.target" ];
    before = [ "network-pre.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ -f /etc/taplab-laptop-number ]; then
        ${pkgs.systemd}/bin/hostnamectl set-hostname --transient "nixos-$(cat /etc/taplab-laptop-number)"
      fi
    '';
  };

  # Configures timezone and locale settings for New Zealand.
  time.timeZone = "Pacific/Auckland";

  i18n.defaultLocale = "en_NZ.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # Enables zsh.
  programs.zsh.enable = true;

  # Prevents the modification of user accounts outside of NixOS configuration.
  users.mutableUsers = false;

  # Sets up the taplab user account.
  users.users.taplab = {
    isNormalUser = true;
    description = "taplab";
    extraGroups = [
      "networkmanager"
      "dialout"
    ];
    shell = pkgs.zsh;
  };

  # Sets up the root user account with a hashed password.
  users.users.root = {
    shell = pkgs.zsh;
    hashedPassword = "$6$0qyksVNkFXpXLynw$PgzzPOc55e9eB.vxA6.oxKHe5nrmrBgo0zdltvLGM1T3gqF2sCTG3MF5BZ1UNK1/lxpaVYUmM3G4h0plt4Sy01";
  };

  # Enables the plymouth boot screen to hide some of the boot messages.
  boot = {
    plymouth = {
      enable = true;
      theme = "spinner";
    };

    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "vt.global_cursor_default=0"
    ];
  };

  # Enables the CUPS printing system.
  services.printing.enable = true;

  # Enable the U2F PAM module and set the key file. Make U2F optional with a fallback to password.
  security.pam.u2f = {
    enable = true;
    control = "sufficient";
    settings.authfile = "/etc/Yubico/u2f_keys";
  };

  # Copy the U2F key file to the appropriate location with correct permissions.
  environment.etc."Yubico/u2f_keys" = {
    source = ../resources/security/u2f_keys;
    user = "root";
    group = "root";
    mode = "0600";
  };

  # Enable U2F and set up cue
  security.pam.services.login.u2fAuth = true;
  security.pam.u2f.settings.cue = true;
  environment.systemPackages = with pkgs; [
    pam_u2f
  ];
}
