{ config, pkgs, ... }:

# Fetches the Home Manager module
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  };
in

{
  # Imports the hardware configuration and Home Manager configuration files
  imports =
    [
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
      ./imports/pkgs.nix
      ./imports/autoupdate.nix
      ./imports/mounts.nix
    ];

  # Enables GRUB as the boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Defines basic Home Manager configuration
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.taplab = import ./home.nix;

  # Defines the system version and tells it to use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "25.05";

  # Enables networking through NetworkManager.
  networking.hostName = "nixos";
  networking.domain = "taplab.nz";
  networking.networkmanager.enable = true;

  # Sets the time zone to Auckland, New Zealand.
  time.timeZone = "Pacific/Auckland";

  # Sets locale to New Zealand English
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

  # Enables the X11 windowing system. Not sure if this is actually needed for KDE Plasma - might be for xwayland
  services.xserver.enable = true;

  # Configures the keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enables the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "taplab";

  # Enables CUPS to print documents. No idea how well this works
  services.printing.enable = true;

  # Enables sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Defines the taplab user account, contains a hashed password for sudo access
  users.users.taplab = {
    isNormalUser = true;
    description = "taplab";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$6$aGlmHH1OI2haTRMb$HdvQGthHpfDfWfsrD969TcSa/doH5yfL21yZOpH19TZ1sEwfxYbTfcOnB5vGAxcovGxom7VvCJI7xGUJqv808.";
  };

  # Allows unfree packages, drivers etc.
  nixpkgs.config.allowUnfree = true;

  # Enables Flatpak
  services.flatpak.enable = true;

  # Enables OpenSSH server, for debug use but could still be useful
  services.openssh.enable = true;

  # Sets Zsh as the default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  services.avahi.enable = true;
}