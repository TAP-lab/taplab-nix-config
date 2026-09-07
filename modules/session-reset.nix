{ pkgs, ... }:

# Automatically kill and reset the user session if the laptop has been asleep longer than 90 minutes. This should help prevent a user having thr previous user's programs open.

let
  # Midpoint brightness between TAP lab and Kotare
  resetBrightnessPercent = 75;

  # File used to store the sleep time timestamp
  suspendTimestampFile = "/run/taplab-suspend-at";

  # Reset the session if the laptop was asleep for longer than this
  suspendThresholdSeconds = 90 * 60;
in
{
  environment.systemPackages = [ pkgs.brightnessctl ];

  # Records the time the laptop went to sleep
  powerManagement.powerDownCommands = ''
    date +%s > ${suspendTimestampFile}
  '';

  # When a session is resumed after sleep, work out how long the laptop was in sleep, and force a new session if longer than our threshold
  powerManagement.resumeCommands = ''
    if [ -f ${suspendTimestampFile} ]; then
      slept_at="$(cat ${suspendTimestampFile})"
      now="$(date +%s)"
      elapsed=$((now - slept_at))

      if [ "$elapsed" -ge ${toString suspendThresholdSeconds} ]; then
        ${pkgs.brightnessctl}/bin/brightnessctl set ${toString resetBrightnessPercent}% || true
        # Restart the display manager rather than just terminating the user session.
        # loginctl terminate-user alone killed the session without reliably respawning
        # SDDM/the X server, leaving a blank screen until the laptop was power cycled.
        ${pkgs.systemd}/bin/systemctl restart display-manager.service || true
      fi

      rm -f ${suspendTimestampFile}
    fi
  '';
}
