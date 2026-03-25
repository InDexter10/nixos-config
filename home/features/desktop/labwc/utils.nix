{ pkgs, ... }:

{
  # Labwc ve SwayNC için gerekli ekstra araçlar
  home.packages = with pkgs; [
    wlopm # Monitör kapatmak için
    wlsunset # Gece ışığı motoru
    brightnessctl # Parlaklık kontrolü (Hatayı çözen paket)
    networkmanagerapplet # GUI Wi-Fi ayarları için (nm-connection-editor)
  ];

  # --- POLKIT (Yetkilendirme) ---
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

  # --- SWAYLOCK ---
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

  # --- SWAYIDLE (Labwc Uyumlu) ---
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
      {
        timeout = 1260;
        # Ters eğik çizgileri sildik, yıldızı tırnağa aldık
        command = "${pkgs.wlopm}/bin/wlopm --off '*'";
        resumeCommand = "${pkgs.wlopm}/bin/wlopm --on '*'";
      }
    ];
  };

  # --- SWAYNC (Profesyonel Kontrol Merkezi) ---

  # --- SWAYNC (Ultra VIP Control Center) ---
  services.mako = {
    enable = true;
    # Artık ayarlar 'settings' altına ve yeni isimleriyle geliyor
    settings = {
      background-color = "#0e0e0d";
      border-color = "#417e8c";
      text-color = "#c3c3bd";
      border-radius = 0;
      border-size = 2;
      font = "JetBrainsMono Nerd Font 10";
      width = 300;
      height = 100;
      margin = "10";
      padding = "15";
      default-timeout = 5000;
    };
    # Özel kurallar hala extraConfig içinde kalabilir
    extraConfig = ''
      [urgency=high]
      border-color=#d85c60
    '';
  };
  services.wlsunset = {
    enable = true;
    latitude = "39.9"; # Örnek: Ankara/Türkiye enlemi
    longitude = "32.8"; # Örnek: Boylam
    temperature = {
      day = 6500;
      night = 4000;
    };
  };
}
