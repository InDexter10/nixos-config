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
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-width = 380;
      fit-to-screen = false;

      widgets = [
        "title"
        "dnd" # Rahatsız Etme
        "volume" # Ses sürgüsü
        "backlight" # Parlaklık sürgüsü
        "mpris" # Medya oynatıcı
        "buttons-grid" # Aksiyon butonları
      ];

      widget-config = {
        title = {
          text = "Kontrol Merkezi";
          clear-all-button = true;
          button-text = "Temizle";
        };
        # İkonlu ve Yüzdeli Yeni Sürgüler
        volume = {
          label = " "; # Hoparlör İkonu
          show-percents = true;
        };
        backlight = {
          label = "󰃠 "; # Güneş İkonu
        };
        buttons-grid = {
          actions = [
            {
              label = " Gece Modu";
              command = "pkill -x wlsunset || wlsunset -t 4500";
            }
            {
              label = " Wi-Fi";
              command = "nm-connection-editor"; # İlkel nmtui yerine Grafik Arayüz
            }
            {
              label = "󰜉 Yeniden Başlat";
              command = "systemctl reboot";
            }
            {
              label = "⏻ Kapat";
              command = "systemctl poweroff";
            }
          ];
        };
      };
    };

    # Mimarın Profesyonel UI/UX Dokunuşu
    style = ''
      .control-center {
        background: rgba(24, 24, 37, 0.95);
        border-radius: 16px;
        border: 1px solid rgba(255, 255, 255, 0.08);
        box-shadow: 0 0 15px rgba(0, 0, 0, 0.6);
      }

      /* Ses ve Parlaklık Modülleri (Kapsüllü Tasarım) */
      .widget-volume, .widget-backlight {
        background: rgba(49, 50, 68, 0.6);
        border-radius: 12px;
        margin: 8px 16px;
        padding: 6px 12px;
      }

      /* İkon Stilleri */
      .widget-volume label, .widget-backlight label {
        font-size: 20px;
        color: #89b4fa;
        padding-right: 12px;
      }

      /* Kalın ve Modern Sürgüler */
      scale trough {
        min-height: 12px;
        background-color: #45475a;
        border-radius: 6px;
      }
      scale highlight {
        background-color: #89b4fa;
        border-radius: 6px;
      }

      /* Buton Stilleri */
      .widget-buttons-grid>flowbox>flowboxchild>button {
        background: #313244;
        border-radius: 10px;
        min-height: 55px;
        border: 1px solid rgba(255,255,255,0.05);
      }
      .widget-buttons-grid>flowbox>flowboxchild>button:hover {
        background: #45475a;
        box-shadow: inset 0 0 5px rgba(0,0,0,0.2);
      }
    '';
  };
}
