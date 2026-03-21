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
      # Monitörü Kapat (Labwc için wlopm)
      {
        timeout = 1260;
        command = "${pkgs.wlopm}/bin/wlopm --off \\*";
        resumeCommand = "${pkgs.wlopm}/bin/wlopm --on \\*";
      }
    ];
  };

  # --- SWAYNC (Profesyonel Kontrol Merkezi) ---

  # --- SWAYNC (Ultra VIP Control Center) ---
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      control-center-margin-top = 6; # Waybar'ın 6px gap'i ile kusursuz hizalama
      control-center-margin-bottom = 6;
      control-center-margin-right = 6;
      control-center-width = 400; # Biraz daha geniş ve ferah (Premium his)
      fit-to-screen = false;

      widgets = [
        "title"
        "dnd"
        "mpris" # Medya oynatıcıyı yukarı aldık, Noctalia tarzı odak
        "volume" # Hoparlör
        "backlight" # Parlaklık
        "buttons-grid" # Wi-fi, Mic, Night Light, Power
      ];

      widget-config = {
        title = {
          text = "Control Center";
          clear-all-button = true;
          button-text = "Clear All";
        };

        dnd = {
          text = "Do Not Disturb";
        };

        mpris = {
          image-size = 80;
          image-radius = 12;
        };

        volume = {
          label = " ";
          show-percents = true;
        };

        backlight = {
          label = "󰃠 ";
          show-percents = true;
        };

        buttons-grid = {
          actions = [
            {
              label = "  Wi-Fi";
              # SwayNC dinamik liste yapamaz, bu yüzden en hızlı GUI'yi çağırıyoruz
              command = "nm-connection-editor";
            }
            {
              label = "  Mic Mute";
              # Mikrofonu susturur/açar (SwayNC'de mic barı olmadığı için Pro çözüm)
              command = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            }
            {
              label = "  Night Shift";
              command = "pkill -x wlsunset || wlsunset -t 4500";
            }
            {
              # Tek Tuşla Kapatma (10 Saniye Gecikmeli + İptal Edilebilir)
              label = "⏻  Power (10s)";
              command = "sh -c 'notify-send \"System\" \"Shutting down in 10 seconds...\" -t 10000 -u critical && sleep 10 && systemctl poweroff'";
            }
          ];
        };
      };
    };

    # --- VIP CSS (Noctalia / macOS Estetiği) ---
    style = ''
      @define-color bg-base rgba(30, 30, 46, 0.85); /* Camsı arka plan */
      @define-color bg-surface rgba(49, 50, 68, 0.7);
      @define-color text-main #cdd6f4;
      @define-color text-muted #a6adc8;
      @define-color accent-blue #89b4fa;
      @define-color accent-red #f38ba8;

      .control-center {
        background: @bg-base;
        border-radius: 18px;
        border: 1px solid rgba(255, 255, 255, 0.08);
        box-shadow: 0px 10px 30px rgba(0, 0, 0, 0.8);
        color: @text-main;
        padding: 12px;
      }

      /* Title & DND Text */
      .widget-title {
        font-size: 18px;
        font-weight: 700;
        margin: 10px;
      }
      .widget-title>button {
        background: @bg-surface;
        color: @text-main;
        border-radius: 8px;
        padding: 4px 12px;
      }
      .widget-title>button:hover {
        background: @accent-red;
        color: #11111b;
      }

      /* MPRIS (Media Player) VIP Görünüm */
      .widget-mpris {
        background: @bg-surface;
        border-radius: 16px;
        margin: 10px;
        padding: 12px;
      }
      .widget-mpris-title { font-weight: bold; font-size: 14px; }
      .widget-mpris-subtitle { color: @text-muted; }

      /* Sliders (Kalın, Yuvarlak ve Premium) */
      .widget-volume, .widget-backlight {
        background: @bg-surface;
        border-radius: 16px;
        margin: 6px 10px;
        padding: 8px 16px;
      }
      .widget-volume label, .widget-backlight label {
        font-size: 22px;
        color: @accent-blue;
        padding-right: 14px;
      }
      scale trough {
        min-height: 14px;
        background-color: rgba(0,0,0,0.3);
        border-radius: 7px;
      }
      scale highlight {
        background-color: @accent-blue;
        border-radius: 7px;
      }

      /* Grid Butonları (Apple Control Center Tarzı Kareler) */
      .widget-buttons-grid {
        margin: 10px;
      }
      .widget-buttons-grid>flowbox>flowboxchild>button {
        background: @bg-surface;
        border-radius: 14px;
        min-height: 65px;
        font-weight: bold;
        font-size: 13px;
        border: 1px solid rgba(255,255,255,0.03);
        transition: all 0.2s ease;
      }
      .widget-buttons-grid>flowbox>flowboxchild>button:hover {
        background: @accent-blue;
        color: #11111b;
        box-shadow: 0px 4px 10px rgba(137, 180, 250, 0.4);
      }
    '';
  };

}
