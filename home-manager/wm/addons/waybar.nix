{ pkgs, ... }:

# Panel altta. Degeri surekli degisen her modul CSS'te SABIT min-width alir;
# boylece bir sayi buyuyup kuculdugunde yanindaki moduller yerinden oynamaz.
# Ikonlar yalnizca Nerd Font'un Material Design bolumunden (U+F0000+);
# anlami tahmin gerektiren yerlerde (CPU, RAM) ikon degil duz yazi var.

let
  p = import ../../theme/palette.nix;

  twTimer = import ./tw-timer.nix { inherit pkgs; };

  # Ayri bir guc-menusu araci kurulmuyor: zaten temalandirilmis rofi dmenu
  # olarak calistiriliyor. -theme-str yalnizca bu cagri icin gecerli, rofi'nin
  # asil temasi degismez. Secenek metinleri labwc/config/menu.xml ile bilerek ayni.
  powerMenu = pkgs.writeShellScript "waybar-power-menu" ''
    secim=$(printf '%s\n' \
      "Ekrani kilitle" \
      "Askiya al" \
      "Oturumu kapat" \
      "Yeniden baslat" \
      "Bilgisayari kapat" \
      | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Guc" -no-custom \
          -theme-str 'window { width: 300px; } mainbox { children: [ inputbar, listview ]; } listview { lines: 5; }')

    case "$secim" in
      "Ekrani kilitle")    swaylock -f ;;
      "Askiya al")         systemctl suspend ;;
      "Oturumu kapat")     labwc --exit ;;
      "Yeniden baslat")    systemctl reboot ;;
      "Bilgisayari kapat") systemctl poweroff ;;
    esac
  '';
in
{
  # Yalnizca bir waybar modulunun tikla-ac hedefi olan araclar burada.
  # pavucontrol: uygulama bazli ses ve aygit secimi (wpctl yalnizca
  # varsayilan aygiti yonetir).
  # tw-timer: paneldeki sayac; terminalden de cagrilabilsin diye pakette.
  home.packages = [
    pkgs.pavucontrol
    twTimer
  ];

  programs.waybar = {
    enable = true;

    # labwc-session.target'a bagli. Kazanci: cokerse yeniden baslar, oturum
    # kapaninca temiz sonlanir, yapilandirma degisince SIGUSR2 ile yenilenir.
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "bottom";
      height = 34;
      spacing = 2;

      modules-left = [
        "ext/workspaces"
        "wlr/taskbar"
      ];

      modules-center = [ "custom/timer" ];

      modules-right = [
        "wireplumber"
        "backlight"
        "privacy"
        "tray"
        "idle_inhibitor"
        "cpu"
        "memory"
        "network"
        "clock"
        "custom/power"
      ];

      # Isimler labwc/config/rc.xml icindeki <desktops> listesinden gelir.
      "ext/workspaces" = {
        format = "{name}";
        sort-by-id = true;
        all-outputs = true;
        on-click = "activate";
      };

      # Yalnizca simge: baslik metni hem yer yiyor hem (ozellikle tarayicida)
      # sayfa degistikce genisligi oynatiyordu.
      # sort-by-app-id = false: ayni uygulamanin her penceresi ayri dugme.
      "wlr/taskbar" = {
        format = "{icon}";
        icon-theme = p.iconTheme;
        icon-size = 20;
        tooltip-format = "{name}\n{title}";
        sort-by-app-id = false;
        active-first = false;
        on-click = "minimize-raise";
        on-click-middle = "close";
        on-click-right = "maximize";
        all-outputs = false;
      };

      # Mikrofon dinleniyorsa veya ekran paylasiliyorsa gorunur; aksi halde
      # yer kaplamaz.
      privacy = {
        icon-size = 16;
        icon-spacing = 6;
        transition-duration = 200;
        modules = [
          {
            type = "screenshare";
            tooltip = true;
            tooltip-icon-size = 20;
          }
          {
            type = "audio-in";
            tooltip = true;
            tooltip-icon-size = 20;
          }
        ];
      };

      tray = {
        icon-size = 18;
        spacing = 8;
        show-passive-items = false;
      };

      # Video izlerken 15 dakikalik otomatik kilidi gecici olarak durdurur
      # (labwc zwp_idle_inhibit_manager_v1 destekliyor).
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰈈";
          deactivated = "󰈉";
        };
        tooltip-format-activated = "Otomatik kilit KAPALI";
        tooltip-format-deactivated = "Otomatik kilit acik (15 dk)";
      };

      cpu = {
        interval = 3;
        format = "CPU {usage}%";
        states = {
          warning = 70;
          critical = 90;
        };
        on-click = "alacritty --title htop -e htop --sort-key PERCENT_CPU";
      };

      # Panelde gercek deger (GiB), balonda tam dokum; renk esikleri yuzdeye gore.
      memory = {
        interval = 5;
        format = "RAM {used:0.1f}G";
        tooltip-format = "Kullanilan  {used:0.1f} / {total:0.1f} GiB   (%{percentage})\nBos         {avail:0.1f} GiB\nzram        {swapUsed:0.1f} / {swapTotal:0.1f} GiB";
        states = {
          warning = 75;
          critical = 90;
        };
        on-click = "alacritty --title htop -e htop --sort-key PERCENT_MEM";
      };

      # max-volume 100: donanimi asan yazilimsal yukseltme bozulmaya yol acar.
      # format-muted sadece ikon - "sessiz" yazisi kutu genisligini oynatirdi.
      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
        max-volume = 100;
        scroll-step = 5;
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
        tooltip-format = "{node_name}\nTekerlek: seviye   Tik: sustur   Sag tik: karistirici";
      };

      # Deger yazma isi logind'in SetBrightness cagrisiyla yapilir; sysfs'e
      # dogrudan yazma izni veren udev kurali gerekmez.
      # min-brightness 5: tekerlekle ekranin tamamen kararmasi onlenir.
      backlight = {
        device = "intel_backlight";
        interval = 2;
        format = "{icon} {percent}%";
        format-icons = [
          "󰃞"
          "󰃟"
          "󰃠"
        ];
        scroll-step = 5.0;
        min-brightness = 5.0;
        tooltip-format = "Parlaklik {percent}%\nTekerlek ile ayarlanir";
      };

      # Panelde yalnizca ikon: SSID uzunlugu degistikce panel oynamasin.
      # Arayuz otomatik secilir (varsayilan rotayi tasiyan), kablo takilinca
      # da dogru calisir.
      network = {
        interval = 5;
        family = "ipv4";
        format-wifi = "{icon}";
        format-ethernet = "󰈀";
        format-linked = "󰈀";
        format-disconnected = "󰤭";
        format-disabled = "󰤭";
        format-icons = [
          "󰤟"
          "󰤢"
          "󰤥"
          "󰤨"
        ];
        tooltip-format-wifi = "{essid}   {signalStrength}%\n{ifname}   {ipaddr}/{cidr}\nAg gecidi  {gwaddr}\nIndirme    {bandwidthDownBytes}\nGonderme   {bandwidthUpBytes}";
        tooltip-format-ethernet = "{ifname}   {ipaddr}/{cidr}\nAg gecidi  {gwaddr}\nIndirme    {bandwidthDownBytes}\nGonderme   {bandwidthUpBytes}";
        tooltip-format-disconnected = "Baglanti yok";
        tooltip-format-disabled = "Kablosuz kapali (rfkill)";
        on-click = "alacritty --title nmtui -e nmtui-connect";
        on-click-right = "alacritty --title nmtui -e nmtui";
      };

      # Tarih SAYIYLA: yerel ayar en_US oldugu icin ay adlari Ingilizce
      # gelirdi ve genislik her ay degisirdi.
      clock = {
        interval = 30;
        format = "{:%d.%m.%Y  %H:%M}";
        tooltip-format = "<span size='large'>{:%d.%m.%Y}</span>\n<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          on-scroll = 1;
          format = {
            months = "<span color='${p.fg}'><b>{}</b></span>";
            days = "<span color='${p.fgDim}'>{}</span>";
            weekdays = "<span color='${p.accent}'><b>{}</b></span>";
            today = "<span color='${p.accent}'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      # Gorev sayaci. "interval" ve "signal" BILEREK yok: betik kendi dongusunu
      # dondurur, waybar saniyede bir surec acmaz. Sayac calismiyorken dongu de
      # uyur (bkz. tw-timer.sh). restart-interval yalnizca cokme sigortasi.
      # Tekerlek adimi burada; betikte karsiligi yok.
      "custom/timer" = {
        exec = "${twTimer}/bin/tw-timer feed";
        return-type = "json";
        restart-interval = 5;
        on-click = "${twTimer}/bin/tw-timer pick";
        on-click-right = "${twTimer}/bin/tw-timer stop";
        on-scroll-up = "${twTimer}/bin/tw-timer extend +5";
        on-scroll-down = "${twTimer}/bin/tw-timer extend -5";
      };

      # Kapatma/yeniden baslatma kisayola bagli DEGIL; yalnizca buradan ve
      # masaustu sag tik menusunden erisilir.
      "custom/power" = {
        format = "󰐥";
        tooltip = true;
        tooltip-format = "Guc secenekleri";
        on-click = "${powerMenu}";
      };
    };

    style = ''
      * {
        /* Metin Inter ile cizilir; ikinci sira YALNIZCA ikon kod noktalari
           icindir (bkz. palette.nix fontIcon). */
        font-family: "${p.fontUI}", "${p.fontIcon}";
        font-size: ${toString p.fontUISize}pt;
        border: none;
        border-radius: 0;
        box-shadow: none;
        text-shadow: none;
        min-height: 0;
      }

      window#waybar {
        background-color: ${p.elevated};
        color: ${p.fg};
        border-top: 1px solid ${p.border};
      }

      tooltip {
        background-color: ${p.elevated};
        border: 1px solid ${p.border};
        border-radius: 4px;
      }
      tooltip label {
        color: ${p.fg};
        padding: 4px 6px;
      }

      #workspaces {
        margin-left: 4px;
      }
      #workspaces button {
        padding: 0 12px;
        margin: 5px 2px;
        color: ${p.fgDim};
        background-color: transparent;
        border-radius: 3px;
        transition: background-color 120ms linear, color 120ms linear;
      }
      #workspaces button:hover {
        background-color: ${p.hover};
        color: ${p.fg};
      }
      #workspaces button.active {
        background-color: ${p.accent};
        color: ${p.accentFg};
      }
      #workspaces button.urgent {
        background-color: ${p.urgent};
        color: ${p.fg};
      }

      #taskbar {
        margin-left: 8px;
      }
      #taskbar button {
        min-width: 24px;
        padding: 0 8px;
        margin: 5px 2px;
        color: ${p.fgDim};
        background-color: ${p.base};
        border-radius: 3px;
        transition: background-color 120ms linear, color 120ms linear;
      }
      #taskbar button:hover {
        background-color: ${p.hover};
        color: ${p.fg};
      }
      /* Odaktaki pencere: alt kenarda vurgu cizgisi. */
      #taskbar button.active {
        background-color: ${p.hover};
        color: ${p.fg};
        box-shadow: inset 0 -2px ${p.accent};
      }
      #taskbar button.minimized {
        background-color: transparent;
        color: ${p.fgDim};
      }

      #privacy,
      #tray,
      #idle_inhibitor,
      #cpu,
      #memory,
      #wireplumber,
      #backlight,
      #network,
      #clock,
      #custom-timer,
      #custom-power {
        padding: 0 9px;
        margin: 5px 1px;
        color: ${p.fg};
        background-color: transparent;
        border-radius: 3px;
      }

      /* Panelin oynamasini engelleyen kisim: icerik kisalinca kutu daralmaz. */
      #cpu        { min-width: 64px; }
      #memory     { min-width: 72px; }
      #wireplumber{ min-width: 60px; }
      #backlight  { min-width: 60px; }
      #network    { min-width: 22px; }
      #clock      { min-width: 118px; }

      /* Ortadaki modul, saniye degistikce gorev adini oynatmasin diye SABIT
         GENISLIKTE rakam kullanir (tnum). Ad zaten betikte kirpiliyor. */
      #custom-timer {
        font-feature-settings: "tnum";
      }
      #custom-timer.bos      { color: ${p.fgDim}; }
      #custom-timer.serbest  { color: ${p.accent}; }
      #custom-timer.uyari    { color: ${p.warn}; }
      #custom-timer.mesai    { color: ${p.urgent}; }

      #idle_inhibitor:hover,
      #custom-timer:hover,
      #cpu:hover,
      #memory:hover,
      #wireplumber:hover,
      #backlight:hover,
      #network:hover,
      #clock:hover,
      #custom-power:hover {
        background-color: ${p.hover};
      }

      #cpu.warning,
      #memory.warning {
        color: ${p.warn};
      }
      #cpu.critical,
      #memory.critical {
        color: ${p.urgent};
      }

      #wireplumber.muted {
        color: ${p.fgDim};
      }

      #network.disconnected,
      #network.disabled {
        color: ${p.urgent};
      }

      #idle_inhibitor.activated {
        color: ${p.warn};
      }

      #privacy {
        color: ${p.urgent};
        padding: 0 6px;
      }

      #custom-power {
        color: ${p.fgDim};
        margin-right: 4px;
      }
      #custom-power:hover {
        color: ${p.urgent};
      }

      /* GTK3'te ":empty" desteklenmez; waybar bos tepsiyi zaten gizler. */
      #tray > .needs-attention {
        background-color: ${p.urgent};
        border-radius: 3px;
      }
    '';
  };
}
