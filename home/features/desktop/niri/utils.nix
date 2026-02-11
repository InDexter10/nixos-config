{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pavucontrol
    brightnessctl

    wl-clipboard
    grim
    slurp
    swaybg
    libnotify

    xwayland-satellite
  ];

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

      image = "/home/dx/Pictures/bb.jpg";

      scaling = "fill";

      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
  };
  # --- MAKO  ---
  services.mako = {
    enable = true; # 'enable' dışarıda kalmaya devam eder!

    # YENİ YAPI: Görsel ayarlar 'settings' içinde olmalı
    settings = {
      font = "JetBrainsMono Nerd Font 12";
      width = 300;
      height = 100;
      margin = "10";
      padding = "15";

      # İsim değişikliklerine dikkat (camelCase -> kebab-case)
      border-size = 2;
      border-radius = 5;

      default-timeout = 5000;
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
