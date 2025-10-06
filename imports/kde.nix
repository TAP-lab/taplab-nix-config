{ config, pkgs, ... }:

{
    # Disable automatic screen locking
    xdg.configFile."kscreenlockerrc".text = ''
        [Daemon]
        Autolock=false
        LockOnResume=false
        Timeout=0
    '';

    # Disable the kde wallet system
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
}