{ pkgs, ... }:

{

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # --- SWAYLOCK  ---
  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";

      image = "/home/virt0/Pictures/bb.jpg";

      scaling = "fill";

      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
  };
  # --- SWAYİDLE ---
  services.swayidle = {
    enable = true;

    systemdTarget = "graphical-session.target";

    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }

      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];

    timeouts = [
      {
        timeout = 1200;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }

      # Monitörü Kapat
      {
        timeout = 1260;
        command = "niri msg action power-off-monitors";

        resumeCommand = "niri msg action power-on-monitors";
      }
    ];
  };
}
