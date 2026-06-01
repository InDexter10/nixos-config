{
  config,
  pkgs,
  lib,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };

  ironbarConfig = {
    position = "top";
    height = 34; # COSMIC üst paneli ~32-36px, ince ve temiz
    anchor_to_edges = true; # kenardan kenara, tam genişlik (COSMIC üst paneli)

    # --- SOL: taskbar + (workspaces, doğrulanacak) -------------------------
    start = [
      {
        type = "workspaces";
        all_monitors = false;
        sort = "index";
      }

      {
        type = "launcher";
        show_names = false; # COSMIC-temiz: sadece ikon
        show_icons = true;
        icon_size = 20;
        reversed = false;
        favorites = [
          # Sık kullandıklarını app_id ile ekle (boş bırakabilirsin):
          # "firefox" "org.kde.okular" "vlc"
        ];
      }

      {
        type = "sys_info";
        format = [
          "CPU {cpu_percent}%"
          "RAM {memory_percent}%"
          "LD {load_average:1}"
        ];
        interval = 5;
        # saniye. Sürümünde hata verirse map biçimini dene:
        # interval = { cpus = 5; memory = 5; load_average = 5; };
      }
    ];

    # --- ORTA: saat + tarih (native takvim popup'u dahili) -----------------
    center = [
      {
        type = "clock";
        # %a=gün, %d=gün-no, %b=ay, %H:%M=saat. Tıklayınca dahili takvim popup açılır.
        format = "%a %d %b   %H:%M";
        format_popup = "%H:%M:%S";
        # Gerçek takvim UYGULAMASI istersen on_click ekle (ironbar takvimi yerine):
        # on_click = "!gnome-calendar";
      }
    ];

    # --- SAĞ: kontrol (ses + parlaklık + tray) -----------------------------
    end = [
      # volume: tıklayınca native popover'da slider + cihaz seçici açılır.
      {
        type = "volume";
        format = "{percentage}%"; # temiz; Nerd Font ikonu istersen "{icon} {percentage}%"
        max_volume = 100;
        # icons = { volume_high = "󰕾"; volume_medium = "󰖀"; volume_low = "󰕿"; muted = "󰝟"; };
      }

      {
        type = "brightness";
      }

      # tray = uygulama göstergeleri (COSMIC üst-sağ köşesi gibi).
      {
        type = "tray";
        icon_size = 18;
      }
    ];
  };
in
{
  home.packages = [ pkgs.ironbar ];

  # ---------------------------------------------------------------------------
  xdg.configFile."ironbar/config.json".source =
    jsonFormat.generate "ironbar-config.json" ironbarConfig;

  xdg.configFile."ironbar/style.css".text = ''
    /* ---- Genel: temiz sans, orta kalınlık ---- */
    * {
      font-family: "Inter", "Noto Sans", sans-serif;
      font-size: 13px;
      font-weight: 500;
      /* GTK4'te yumuşak geçişler */
      transition: background-color 150ms ease;
    }

    /* ---- Bar gövdesi: koyu, hafif yarı saydam, ince alt çizgi ---- */
    .background {
      background-color: rgba(20, 20, 22, 0.85);
      color: #e6e6e6;
      border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    }

    /* ---- Modül butonları: şeffaf, hover'da hafif pill ---- */
    button {
      background-color: transparent;
      border: none;
      border-radius: 8px;
      padding: 0 8px;
      margin: 4px 3px;
      min-height: 0;
    }
    button:hover {
      background-color: rgba(255, 255, 255, 0.08);
    }

    /* ---- Saat: biraz daha belirgin (orta odak) ---- */
    .clock {
      font-weight: 600;
      letter-spacing: 0.3px;
    }

    /* ---- Workspaces: aktif olan vurgulu ---- */
    .workspaces button.focused,
    .workspaces button:checked {
      background-color: rgba(255, 255, 255, 0.14);
    }
    .workspaces button.urgent {
      background-color: rgba(235, 110, 90, 0.30);
    }

    /* ---- sys_info: gri-soft, dikkat çekmeyen ---- */
    .sys-info {
      color: #b8b8bd;
    }

    /* ---- Tray ikonları biraz nefes alsın ---- */
    .tray button {
      padding: 0 5px;
    }

    /* ---- Popover'lar (saat takvimi, ses slider'ı): kart görünümü ---- */
    .popup {
      background-color: rgba(28, 28, 30, 0.96);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 12px;
      padding: 12px;
      color: #e6e6e6;
    }
    .popup button:hover {
      background-color: rgba(255, 255, 255, 0.10);
    }
  '';
}
