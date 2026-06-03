{
  config,
  pkgs,
  lib,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };

  wpctl = "${pkgs.wireplumber}/bin/wpctl";

  ironbarConfig = {
    position = "top";
    height = 34; # COSMIC üst paneli ~32-36px
    anchor_to_edges = true; # kenardan kenara tam genişlik

    # --- SOL: workspaces + taskbar (icon-only) ----------------------------
    start = [
      {
        type = "workspaces";
        all_monitors = false;
        sort = "index";
      }

      {
        type = "launcher";
        show_names = false; # COSMIC-temiz: yalnızca ikon
        show_icons = true;
        icon_size = 20;
        reversed = false;
        favorites = [
          # Sık kullandıklarını app_id ile ekleyebilirsin:
          # "firefox" "org.kde.okular" "vlc"
        ];
      }

      {
        type = "sys_info";
        format = [
          "CPU {cpu_percent}%"
          "RAM {memory_percent}%"
        ];
        interval = 5;
      }
    ];

    center = [
      {
        type = "clock";
        format = "%a %d %b   %H:%M";
        format_popup = "%H:%M:%S";
      }
    ];

    end = [
      {
        type = "network_manager";
      }

      {
        type = "volume";
        format = "{icon} {percentage}%";
        max_volume = 100;
        on_scroll_up = "${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
        on_scroll_down = "${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-";
        icons = {
          volume_high = "󰕾";
          volume_medium = "󰖀";
          volume_low = "󰕿";
          muted = "󰝟";
        };
      }

      {
        type = "brightness";
      }

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
    /* =======================================================================
       Modern / COSMIC-benzeri tema — sade, yuvarlatılmış, hafif translucency.
       ironbar 0.18.0 (GTK4). Sınıflar modül adının kebab-case hâlidir:
       .workspaces .launcher .clock .volume .brightness .network-manager .tray
       ======================================================================= */

    @define-color accent      #6aa0ff;     /* COSMIC-vari yumuşak mavi vurgu */
    @define-color fg          #e8e8ea;
    @define-color fg-muted    #b8b8be;

    /* ---- Genel tipografi ---- */
    * {
      font-family: "Inter", "Noto Sans", "Noto Sans Nerd Font", sans-serif;
      font-size: 13px;
      font-weight: 500;
      transition: background-color 150ms ease, color 150ms ease;
    }

    /* ---- Bar gövdesi: koyu translucency, sert çizgi YOK (temiz kenar) ---- */
    .background {
      background-color: rgba(22, 22, 25, 0.72);
      color: @fg;
    }

    /* ---- Bölge kutuları arası nefes alanı ---- */
    .start  { margin-left: 4px; }
    .end    { margin-right: 6px; }

    /* ---- Modül butonları: şeffaf, hover'da yuvarlak pill ---- */
    button,
    .volume,
    .brightness,
    .network-manager,
    .clock {
      background-color: transparent;
      border: none;
      border-radius: 9px;
      padding: 0 9px;
      margin: 4px 2px;
      min-height: 0;
      color: @fg;
    }
    button:hover,
    .volume:hover,
    .brightness:hover,
    .network-manager:hover {
      background-color: rgba(255, 255, 255, 0.09);
    }

    /* ---- Saat: orta odak, biraz daha belirgin ---- */
    .clock {
      font-weight: 600;
      letter-spacing: 0.3px;
    }

    /* ---- Workspaces: aktif olan vurgu rengiyle ---- */
    .workspaces button {
      border-radius: 9px;
      margin: 4px 2px;
      padding: 0 8px;
      color: @fg-muted;
    }
    .workspaces button.focused,
    .workspaces button:checked {
      background-color: alpha(@accent, 0.20);
      color: @fg;
    }
    .workspaces button.urgent {
      background-color: rgba(235, 110, 90, 0.30);
      color: @fg;
    }

    /* ---- Taskbar (launcher): kompakt ikonlar ---- */
    .launcher button {
      padding: 0 5px;
      margin: 4px 1px;
    }
    .launcher button.focused {
      background-color: rgba(255, 255, 255, 0.10);
    }

    /* ---- Sağ küme: ikonlar nefes alsın, hizalı dursun ---- */
    .network-manager,
    .volume,
    .brightness {
      color: @fg;
    }

    /* ---- Tray ikonları ---- */
    .tray button {
      padding: 0 5px;
      margin: 4px 1px;
    }

    /* ---- Popover'lar (takvim, ses slider'ı, ağ listesi): kart görünümü ---- */
    .popup {
      background-color: rgba(28, 28, 31, 0.97);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 14px;
      padding: 12px;
      color: @fg;
    }
    .popup button:hover {
      background-color: rgba(255, 255, 255, 0.10);
    }
  '';
}
