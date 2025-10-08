{ config, pkgs, ... }:

{
    # Disables automatic screen locking as this requires a password to unlock
    xdg.configFile."kscreenlockerrc".text = ''
        [Daemon]
        Autolock=false
        LockOnResume=false
        Timeout=0
    '';

    # Disables the kde wallet system as it is not needed and just gets in the way of most users
    xdg.configFile."kwalletrc".text = ''
        [Wallet]
        Close When Idle=false
        Close on Screensaver=false
        Enabled=false
        Idle Timeout=10
        Launch Manager=false
        Leave Manager Open=false
        Leave Open=true
        Prompt on Open=false
        Use One Wallet=true

        [org.freedesktop.secrets]
        apiEnabled=true
    '';

    xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc".text = ''
        [Containments][2][Applets][5][Configuration][General]
        launchers=file:///nix/store/zv32lw82xiwcg2kcaf465yqb80bw76bz-user-environment/share/applications/org.wezfurlong.wezterm.desktop,preferred://filemanager,file:///nix/store/5gqf746i9ga4n8xvjbcw6fp6kwycfslg-system-path/share/applications/org.kde.discover.desktop,applications:systemsettings.desktop,preferred://browser,file:///home/taplab/.local/share/applications/Minecraft.desktop,file:///nix/store/5gqf746i9ga4n8xvjbcw6fp6kwycfslg-system-path/share/applications/OrcaSlicer.desktop,file:///nix/store/5gqf746i9ga4n8xvjbcw6fp6kwycfslg-system-path/share/applications/org.inkscape.Inkscape.desktop,file:///nix/store/5gqf746i9ga4n8xvjbcw6fp6kwycfslg-system-path/share/applications/arduino-ide.desktop,file:///nix/store/5gqf746i9ga4n8xvjbcw6fp6kwycfslg-system-path/share/applications/code.desktop
    '';
}