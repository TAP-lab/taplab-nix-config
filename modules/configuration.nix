{ config, lib, pkgs, ... }:

{
  # Enables the GRUB bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

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

  # Sets up the taplab user account with a password.
  users.users.taplab = {
    isNormalUser = true;
    description = "taplab";
    extraGroups = [ "networkmanager" "wheel" "dialout"];
    hashedPassword = "$6$aGlmHH1OI2haTRMb$HdvQGthHpfDfWfsrD969TcSa/doH5yfL21yZOpH19TZ1sEwfxYbTfcOnB5vGAxcovGxom7VvCJI7xGUJqv808.";
    shell = pkgs.zsh;
  };

  users.users.root.shell = pkgs.zsh;

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
  security.pam.services.sudo.u2fAuth = true;
  security.pam.u2f.settings.cue = true;
  environment.systemPackages = with pkgs; [
    pam_u2f
  ];
}
