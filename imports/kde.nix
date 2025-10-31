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

    # Configures the taskbar
    xdg.configFile."plasma-org.kde.plasma.desktop-appletsrc".text = ''
        [ActionPlugins][0]
        MiddleButton;NoModifier=org.kde.paste
        RightButton;NoModifier=org.kde.contextmenu

        [ActionPlugins][1]
        RightButton;NoModifier=org.kde.contextmenu

        [Containments][1]
        activityId=c3af8419-2c72-43dc-b99b-4d8402abf1b5
        formfactor=0
        immutability=1
        lastScreen=0
        location=0
        plugin=org.kde.plasma.folder
        wallpaperplugin=org.kde.image

        [Containments][1][General]
        positions={"1280x800":[]}

        [Containments][2]
        activityId=
        formfactor=2
        immutability=1
        lastScreen=0
        location=4
        plugin=org.kde.panel
        wallpaperplugin=org.kde.image

        [Containments][2][Applets][19]
        immutability=1
        plugin=org.kde.plasma.digitalclock

        [Containments][2][Applets][19][Configuration]
        popupHeight=400
        popupWidth=560

        [Containments][2][Applets][20]
        immutability=1
        plugin=org.kde.plasma.showdesktop

        [Containments][2][Applets][3]
        immutability=1
        plugin=org.kde.plasma.kickoff

        [Containments][2][Applets][3][Configuration]
        PreloadWeight=100
        popupHeight=508
        popupWidth=647

        [Containments][2][Applets][3][Configuration][General]
        favoritesPortedToKAstats=true

        [Containments][2][Applets][4]
        immutability=1
        plugin=org.kde.plasma.pager

        [Containments][2][Applets][5]
        immutability=1
        plugin=org.kde.plasma.icontasks

        [Containments][2][Applets][5][Configuration][General]
        launchers=applications:com.mitchellh.ghostty.desktop,preferred://filemanager,preferred://browser,file:///home/taplab/.local/share/applications/Minecraft.desktop,file:///nix/store/gn9ggxiqkis67jnsadvqmj6n1f3qzvd0-user-environment/share/applications/org.prismlauncher.PrismLauncher.desktop,file:///nix/store/pnjfsc7rc9vaqcwxjb6ncgvlnznh6j53-system-path/share/applications/OrcaSlicer.desktop,file:///nix/store/pnjfsc7rc9vaqcwxjb6ncgvlnznh6j53-system-path/share/applications/org.inkscape.Inkscape.desktop,file:///nix/store/pnjfsc7rc9vaqcwxjb6ncgvlnznh6j53-system-path/share/applications/arduino-ide.desktop,file:///nix/store/pnjfsc7rc9vaqcwxjb6ncgvlnznh6j53-system-path/share/applications/code.desktop

        [Containments][2][Applets][6]
        immutability=1
        plugin=org.kde.plasma.marginsseparator

        [Containments][2][Applets][7]
        immutability=1
        plugin=org.kde.plasma.systemtray

        [Containments][2][Applets][7][Configuration]
        SystrayContainmentId=8

        [Containments][2][General]
        AppletOrder=3;4;5;6;7;19;20

        [Containments][8]
        activityId=
        formfactor=2
        immutability=1
        lastScreen=-1
        location=4
        plugin=org.kde.plasma.private.systemtray
        popupHeight=432
        popupWidth=432
        wallpaperplugin=org.kde.image

        [Containments][8][Applets][10]
        immutability=1
        plugin=org.kde.plasma.cameraindicator

        [Containments][8][Applets][11]
        immutability=1
        plugin=org.kde.plasma.clipboard

        [Containments][8][Applets][12]
        immutability=1
        plugin=org.kde.plasma.devicenotifier

        [Containments][8][Applets][13]
        immutability=1
        plugin=org.kde.plasma.manage-inputmethod

        [Containments][8][Applets][14]
        immutability=1
        plugin=org.kde.plasma.printmanager

        [Containments][8][Applets][15]
        immutability=1
        plugin=org.kde.plasma.volume

        [Containments][8][Applets][15][Configuration][General]
        migrated=true

        [Containments][8][Applets][16]
        immutability=1
        plugin=org.kde.kscreen

        [Containments][8][Applets][17]
        immutability=1
        plugin=org.kde.plasma.keyboardindicator

        [Containments][8][Applets][18]
        immutability=1
        plugin=org.kde.plasma.keyboardlayout

        [Containments][8][Applets][21]
        immutability=1
        plugin=org.kde.plasma.battery

        [Containments][8][Applets][22]
        immutability=1
        plugin=org.kde.plasma.brightness

        [Containments][8][Applets][23]
        immutability=1
        plugin=org.kde.plasma.networkmanagement

        [Containments][8][Applets][9]
        immutability=1
        plugin=org.kde.plasma.notifications

        [Containments][8][General]
        extraItems=org.kde.plasma.notifications,org.kde.plasma.mediacontroller,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.volume,org.kde.kscreen,org.kde.plasma.networkmanagement,org.kde.plasma.brightness,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout
        knownItems=org.kde.plasma.notifications,org.kde.plasma.mediacontroller,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.volume,org.kde.kscreen,org.kde.plasma.networkmanagement,org.kde.plasma.brightness,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout

        [ScreenMapping]
        itemsOnDisabledScreens=
    '';
}