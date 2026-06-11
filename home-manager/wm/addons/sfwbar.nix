# sfwbar.nix — labwc için KDE-Plasma esinli, pro, unbloat panel
# Hedef sürümler (teyit edildi): NixOS 26.05 · labwc 0.9.7 · sfwbar 1.0_beta17
# Kapsam: Home Manager modülü.
#
# DÜZEN (sol -> sağ):
#   [ Taskbar (gruplanmamış) ]  <esnek boşluk>
#   [ Tray ] [ Volume ] [ Backlight ] [ SysMon ] [ Clock ] [ Power ]
#
# BAR VARYANTI KARARI — KDE Plasma paneli:
#   sfwbar mimari olarak taskbar/Plasma-tarzı bir paneldir; native popup'ları
#   Plasma sistem-tepsisi gibi davranır. GNOME üst-bar (toplu status menu) ve
#   COSMIC (workspace-merkezli applet) labwc+sfwbar'da native taklit edilemez
#   (workspace protokolü yok). KDE en sadık ve tam ulaşılabilir varyant.
#
# DEĞİŞİKLİKLER (önceki sürüme göre):
#   - swayosd KALINTILARI TEMİZLENDİ. Volume scroll/mute ve backlight scroll
#     artık wpctl/brightnessctl + wob FIFO'suna yazan store-path betikleri
#     (aşağıda writeShellScript). rc.xml ile aynı FIFO'yu besler.
#   - SHOW DESKTOP KALDIRILDI. Yerine workspace göstergesi EKLENMEDİ: labwc
#     hiçbir IPC sunmaz, sfwbar pager'ı sway/i3 IPC ister → labwc'de pager
#     ÇALIŞMAZ; "go to desktop N" diyen CLI da yok. Bozuk modül eklemiyoruz.
#     Masaüstü geçişi rc.xml'deki W-1..W-4 ile yapılır.
#   - SYSTEM MONITOR DOĞRULANDI. RAM kullanımı artık çekirdek-otoriter
#     (Total − MemAvailable) — /proc/meminfo doğrudan okunuyor. Eski
#     Total−Free−Cache−Buff formülü Shmem/SReclaimable yüzünden DÜŞÜK
#     gösteriyordu. `free -h` "used" sütunuyla doğrulayabilirsin. CPU =
#     cpu.source XCpuUtilization (/proc/stat delta'sı, doğru).
#   - SESSION → özel "power" popup'ı (Lock/Suspend/Reboot/Shutdown). Eski
#     session.widget include edilmediği için inert kalıyordu; bu sürüm
#     sysmon-popup yapısının birebir aynısı (kanıtlanmış) ve tüm komutlar
#     doğrudan (Exec escaping yok).
#
# AUTOSTART (bu modülde YÖNETİLMEZ — çakışmamak için). labwc/autostart:
#   WOBSOCK="$XDG_RUNTIME_DIR/wob.fifo"; rm -f "$WOBSOCK"; mkfifo "$WOBSOCK"; tail -f "$WOBSOCK" | wob &
#   nm-applet &
#   sfwbar &
#   (swayosd-server SATIRI ARTIK YOK.)
#
# SVG DÜZELTMESİ (nixpkgs #430793): 26.05 sfwbar'ı wrapGAppsHook3 içerir ama
#   librsvg yok → SVG pixbuf loader kaydolmaz, SVG ikon/gauge boş çıkar. Sadece
#   librsvg ekleniyor. nixpkgs düzeltirse `sfwbarPkg = pkgs.sfwbar;` yap.

{ pkgs, ... }:

let
  # 26.05 derlemesi wrapGAppsHook3 içerdiğinden YALNIZCA librsvg ekleniyor (unbloat).
  sfwbarPkg = pkgs.sfwbar.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.librsvg ];
  });

  # ── OSD betikleri: değeri değiştir + yeni yüzdeyi wob FIFO'suna yaz ──────────
  # Tüm ikililer store-path ile çağrılır (PATH'ten bağımsız → güvenilir, kur-unut).
  # FIFO, autostart'taki `tail -f $WOBSOCK | wob` tarafından okunur.
  mkVol = sign: pkgs.writeShellScript "wob-vol-${if sign == "+" then "up" else "down"}" ''
    ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%${sign}
    ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ \
      | ${pkgs.gawk}/bin/awk '{print int($2*100)}' > "$XDG_RUNTIME_DIR/wob.fifo"
  '';
  volUp = mkVol "+";
  volDn = mkVol "-";

  volMute = pkgs.writeShellScript "wob-vol-mute" ''
    ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    v=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if echo "$v" | ${pkgs.gnugrep}/bin/grep -q MUTED; then
      echo 0 > "$XDG_RUNTIME_DIR/wob.fifo"
    else
      echo "$v" | ${pkgs.gawk}/bin/awk '{print int($2*100)}' > "$XDG_RUNTIME_DIR/wob.fifo"
    fi
  '';

  mkBri = sign: pkgs.writeShellScript "wob-bri-${if sign == "+" then "up" else "down"}" ''
    ${pkgs.brightnessctl}/bin/brightnessctl -q set 5%${sign}
    ${pkgs.brightnessctl}/bin/brightnessctl -m \
      | ${pkgs.coreutils}/bin/cut -d, -f4 | ${pkgs.coreutils}/bin/tr -d % > "$XDG_RUNTIME_DIR/wob.fifo"
  '';
  briUp = mkBri "+";
  briDn = mkBri "-";
in
{
  home.packages = [ sfwbarPkg ];

  xdg.configFile."sfwbar/sfwbar.config".text = ''
    #Api2

    # Panel kalınlığı (CSS bunu min-height olarak kullanır).
    Set ThicknessHint = "40px";

    # Taskbar öğesi sağ-tık menüsü (ilk-parti, hafif).
    include("winops.widget")

    # CPU ölçeri: XCpuUtilization (/proc/stat delta'sı — htop ile uyumlu).
    include("cpu.source")

    # Açılış: native popup'lara "dışarı tıkla -> kapan" davranışı ekle.
    function("SfwbarInit") {
      Config("PopUp 'XVolumeWindow'  { AutoClose = true }")
      Config("PopUp 'BacklightPopup' { AutoClose = true }")
    }

    # ── DOĞRUDAN /proc kaynakları (otoriter, kendi okuduğumuz) ──────────────────
    # RAM: çekirdek MemAvailable → used = Total - Available (free "used" ile aynı).
    # Yük: /proc/loadavg 1/5/15 dk.
    scanner {
      file("/proc/meminfo") {
        $MemTotal = RegEx("MemTotal:\s+([0-9]+)")
        $MemAvail = RegEx("MemAvailable:\s+([0-9]+)")
      }
      file("/proc/loadavg") {
        $Load1  = RegEx("^([0-9.]+)")
        $Load5  = RegEx("^[0-9.]+ ([0-9.]+)")
        $Load15 = RegEx("^[0-9.]+ [0-9.]+ ([0-9.]+)")
      }
    }

    # ── Sistem Monitörü popup'ı: CPU · RAM (gerçek) · Load ──────────────────────
    PopUp "sysmon" {
      AutoClose = true
      grid {
        style = "sysmon_box"
        css   = "* { -GtkWidget-direction: bottom; }"

        label { value = "System"; style = "sysmon_title" }

        grid {
          style = "sysmon_row"
          css   = "* { -GtkWidget-direction: right; }"
          label { value = "CPU"; style = "sysmon_key" }
          label {
            style    = "sysmon_val"
            interval = 1000
            value    = Str(XCpuUtilization*100, 0) + "%"
          }
        }

        grid {
          style = "sysmon_row"
          css   = "* { -GtkWidget-direction: right; }"
          label { value = "RAM"; style = "sysmon_key" }
          label {
            style    = "sysmon_val"
            interval = 2000
            # used = Total - Available  (kiB → GiB: /1048576)
            value    = Str(($MemTotal-$MemAvail)/1048576, 1) + " / " +
                       Str($MemTotal/1048576, 1) + " GiB   " +
                       Str(($MemTotal-$MemAvail)/$MemTotal*100, 0) + "%"
          }
        }

        label { value = ""; style = "sysmon_sep" }

        grid {
          style = "sysmon_row"
          css   = "* { -GtkWidget-direction: right; }"
          label { value = "Load"; style = "sysmon_key" }
          label {
            style    = "sysmon_val"
            interval = 2000
            value    = $Load1 + "   " + $Load5 + "   " + $Load15
          }
        }
      }
    }

    # ── Güç popup'ı: Lock · Suspend · Reboot · Shutdown ─────────────────────────
    # Yatay ikon-buton sırası (KDE oturum ekranı hissi). Komutlar doğrudan.
    PopUp "power" {
      AutoClose = true
      grid {
        style = "power_box"
        css   = "* { -GtkWidget-direction: right; }"
        button { style = "power_item"; value = "system-lock-screen"; tooltip = "Lock";     action = Exec("swaylock -f") }
        button { style = "power_item"; value = "system-suspend";     tooltip = "Suspend";  action = Exec("systemctl suspend") }
        button { style = "power_item"; value = "system-reboot";      tooltip = "Reboot";   action = Exec("systemctl reboot") }
        button { style = "power_item"; value = "system-shutdown";    tooltip = "Shutdown"; action = Exec("systemctl poweroff") }
      }
    }

    # ── Panel düzeni ────────────────────────────────────────────────────────────
    # NOT: labwc'de pager/placer ÇALIŞMAZ (sway IPC ister) — bilinçli olarak yok.
    layout "sfwbar" {
      layer          = "top"
      bar_id         = "bar-0"
      mirror         = "*"        # tüm çıkışlar; tek monitör için sil + 'monitor' aç
      exclusive_zone = "auto"     # panel yer ayırır (KDE davranışı)
      # monitor      = "DP-1"

      # ── Taskbar (EN SOL): gruplanmamış, açılış sırası, odak alt-çizgisi ──
      taskbar {
        rows     = 1
        icons    = true
        labels   = false          # ikon-only; başlık tooltip'te
        group    = false          # aynı uygulamanın pencerelerini BİRLEŞTİRME
        sort     = false          # açılış sırasını koru
        tooltips = true
        action[RightClick]  = Menu("winops")
        action[MiddleClick] = Close()
      }

      # ── Esnek boşluk: sistem alanını sağa iter ──
      label { css = "* { -GtkWidget-hexpand: true; }" }

      # ── Sistem tepsisi (SNI): nm-applet (Wi-Fi), vb. ──
      tray { rows = 1 }

      # ── Volume: scroll → wpctl+wob; orta-tık → mute; tık → slider popup ──
      widget "volume.widget" {
        simple_icon         = True
        volume_thresholds   = [80, 50, 0]
        volume_icons        = ["audio-volume-high", "audio-volume-medium", "audio-volume-low"]
        volume_muted        = "audio-volume-muted"
        action[ScrollUp]    = Exec("${volUp}")
        action[ScrollDown]  = Exec("${volDn}")
        action[MiddleClick] = Exec("${volMute}")
      }

      # ── Backlight: scroll → brightnessctl+wob; tık → slider popup ──
      widget "backlight.widget" {
        step               = 5
        max_brightness     = 100
        min_brightness     = 5
        action[ScrollUp]   = Exec("${briUp}")
        action[ScrollDown] = Exec("${briDn}")
      }

      # ── Sistem Monitörü düğmesi (saatin SOLUNDA) ──
      #    interval=2000 ile XCpuUtilization + meminfo'yu sürekli besler.
      button {
        style    = "sysmon_btn"
        class    = "module"
        value    = "utilities-system-monitor"
        interval = 2000
        tooltip  = "CPU " + Str(XCpuUtilization*100,0) + "%    " +
                   "RAM " + Str(($MemTotal-$MemAvail)/$MemTotal*100,0) + "%"
        action   = PopUp("sysmon")
      }

      # ── Saat (üstte saat, altta tarih) ──
      widget "clock.widget" {
        disable               = false
        time_format           = "%H:%M\n%a %d %b"
        tooltip_format        = "%A, %d %B %Y"
        week_starts_on_sunday = false
      }

      # ── Güç (EN SAĞ): tık → power popup ──
      button {
        style   = "power_btn"
        class   = "module"
        value   = "system-shutdown"
        tooltip = "Power"
        action  = PopUp("power")
      }
    }

    #CSS

    /* ── Breeze-Dark esinli palet. Native popup'lar bu @ renklerini kullanır. */
    @define-color theme_bg_color   #232629;
    @define-color theme_fg_color   #fcfcfc;
    @define-color theme_text_color #fcfcfc;
    @define-color borders          rgba(255,255,255,0.12);
    @define-color accent           #3daee9;
    @define-color hover_bg         rgba(61,174,233,0.15);
    @define-color active_bg        rgba(61,174,233,0.25);

    /* ── Panel gövdesi ── */
    window#sfwbar {
      -GtkWidget-direction: bottom;
      background-color: @theme_bg_color;
      color: @theme_fg_color;
      min-height: 40px;
    }

    * { -GtkWidget-vexpand: true; }
    grid { padding: 0; margin: 0; }

    label {
      font-family: "Noto Sans", Sans;
      font-size: 11px;
      color: @theme_fg_color;
      text-shadow: none;
    }

    image { color: @theme_fg_color; -gtk-icon-shadow: none; }

    button {
      background: none;
      background-image: none;
      border-image: none;
      box-shadow: none;
      outline-style: none;
      border: none;
    }

    /* ── Taskbar: her pencere ayrı, belirgin odak alt-çizgisi ── */
    button#taskbar_item {
      padding: 0 8px;
      margin: 2px 2px;
      border-radius: 4px;
      border-bottom: 3px solid transparent;
    }
    button#taskbar_item image { min-width: 22px; min-height: 22px; }
    button#taskbar_item:hover  { background-color: @hover_bg; }
    button#taskbar_item.focused {
      background-color: @active_bg;
      border-bottom: 3px solid @accent;
    }

    /* ── Modüller: Volume · Backlight · SysMon · Power (class="module") ── */
    .module {
      padding: 0 7px;
      margin: 0 1px;
      border-radius: 4px;
      -GtkWidget-valign: center;
    }
    .module:hover { background-color: @hover_bg; }
    .module image { min-width: 18px; min-height: 18px; }

    /* ── Sistem tepsisi ── */
    button#tray_item {
      padding: 0 4px;
      margin: 0 1px;
      border: none;
      border-radius: 4px;
      -GtkWidget-valign: center;
    }
    button#tray_item.passive { -GtkWidget-visible: false; }
    button#tray_item:hover    { background-color: @hover_bg; }
    button#tray_item image {
      min-width: 18px; min-height: 18px;
      -GtkWidget-halign: center; -GtkWidget-valign: center;
    }

    /* ── Saat ── */
    label#clock {
      padding: 0 10px;
      font-size: 11px;
      -GtkWidget-valign: center;
      -GtkLabel-align: 0.5;
    }

    /* ── Sistem Monitörü popup'ı ── */
    window#sysmon { background: rgba(0,0,0,0); }
    grid#sysmon_box {
      margin: 5px;
      padding: 14px 16px;
      min-width: 250px;
      border-radius: 10px;
      border: 1px solid @borders;
      background-color: @theme_bg_color;
    }
    label#sysmon_title {
      font-size: 13px;
      font-weight: bold;
      padding-bottom: 10px;
      -GtkLabel-align: 0;
    }
    grid#sysmon_row { padding: 3px 0; }
    label#sysmon_key {
      font-size: 12px;
      color: alpha(@theme_fg_color, 0.65);
      min-width: 60px;
      -GtkLabel-align: 0;
    }
    label#sysmon_val {
      font-size: 12px;
      -GtkWidget-hexpand: true;
      -GtkLabel-align: 1;
    }
    label#sysmon_sep { min-height: 8px; }

    /* ── Güç popup'ı ── */
    window#power { background: rgba(0,0,0,0); }
    grid#power_box {
      margin: 5px;
      padding: 10px 12px;
      border-radius: 10px;
      border: 1px solid @borders;
      background-color: @theme_bg_color;
    }
    button#power_item {
      padding: 10px;
      margin: 0 3px;
      border-radius: 8px;
    }
    button#power_item image { min-width: 28px; min-height: 28px; }
    button#power_item:hover { background-color: @hover_bg; }

    /* ── Menü / tooltip — Breeze hissi ── */
    menu {
      background-color: @theme_bg_color;
      border: 1px solid @borders;
      padding: 4px;
    }
    menuitem { color: @theme_fg_color; padding: 4px 10px; border-radius: 4px; }
    menuitem:hover { background-color: @accent; color: white; }

    tooltip {
      background-color: @theme_bg_color;
      color: @theme_fg_color;
      border: 1px solid @borders;
    }
  '';
}
