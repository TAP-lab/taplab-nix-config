{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;
    panels = [
      {
        location = "bottom";
        height = 48;
        widgets = [
          {
            kickoff = {
              icon = "taplab";
            };
          }

          {
            iconTasks = {
              launchers = [
                "applications:org.wezfurlong.wezterm.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:microsoft-edge.desktop"
                "applications:Minecraft.desktop"
                "applications:org.prismlauncher.PrismLauncher.desktop"
                "applications:OrcaSlicer.desktop"
                "applications:org.inkscape.Inkscape.desktop"
                "applications:arduino-ide.desktop"
                "applications:code.desktop"
              ];
            };
          }

          "org.kde.plasma.marginsseparator"

          {
            systemTray = { };
          }

          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
              time.format = "12h";
            };
          }
        ];
      }
    ];

    kscreenlocker = {
      autoLock = false;
      lockOnResume = false;
      timeout = 0;
    };

    shortcuts = {
      ksmserver ={
        "Lock Session" = [];
      };
    };

    configFile."touchpadrc"."General" = {
      DisableWhileTyping = false;
    };
  };

  xdg.configFile."kwalletrc".text = ''
    [Wallet]
    Enabled=false
  '';

  home.file.".local/share/icons/taplab.svg".source = ../../resources/icons/taplab.svg;
}