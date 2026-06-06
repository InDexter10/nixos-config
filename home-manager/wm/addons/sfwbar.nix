# sfwbar.nix — labwc için profesyonel, KDE-panel görünümlü, bloat'sız panel
# Hedef sürümler (teyit edildi): NixOS 26.05 · labwc 0.9.7 · sfwbar 1.0_beta17
# Kapsam: Home Manager modülü.   home.nix:  imports = [ ./sfwbar.nix ];
#
# DÜZEN (sol -> sağ):
#   [ ShowDesktop ] [ Taskbar (gruplanmamış) ]  <esnek boşluk>
#   [ Tray ] [ Volume ] [ Backlight ] [ SysMon ] [ Clock ] [ Session ]
#
# TASARIM KARARI — neden tek "kontrol merkezi popup'ı" değil:
#   sfwbar'ın doğrulanmış/upstream modeli her modülün panelde durup KENDİ popup'ını
#   açmasıdır (KDE sistem-tepsisi mantığı). Volume/Backlight tıklayınca GERÇEK
#   sürüklenebilir slider'lı popup açar; Session güç menüsü açar. Tek birleşik
#   popup'ı elle kurmak slider iç-mantığını yeniden yazmayı gerektirir = deneysel.
#
# AUTOCLOSE (madde 5): native popup'lar varsayılan olarak dışarı-tıkla-kapat
#   yapmaz; SfwbarInit içinde Config(...) ile AutoClose=true enjekte ediliyor.
#   (Doküman: "AutoClose -> popup, pencere dışına tıklanınca kapanır".)
#
# SVG DÜZELTMESİ (varsayılan AÇIK — nixpkgs #430793):
#   26.05'teki sfwbar wrapGAppsHook3 İÇERİR ama librsvg YOK -> SVG pixbuf loader
#   kaydolmaz, backlight gauge'ı / SVG ikonlar boş çıkar. Aşağıda SADECE librsvg
#   ekleniyor. nixpkgs düzeltirse `sfwbarPkg = pkgs.sfwbar;` yap.
#
# BAĞIMLILIKLAR / NOTLAR (autostart bu modülde YÖNETİLMEZ — çakışmamak için):
#   ~/.config/labwc/autostart içine:
#     swayosd-server &        # ses/parlaklık OSD'si (volume scroll bunu kullanır)
#     nm-applet --indicator & # Wi-Fi/ağ -> sistem tepsisinde görünür
#     sfwbar &
#   - Volume scroll: swayosd-client gereklidir (zaten swayosd kullanıyorsun).
#   - Volume: PipeWire + pipewire-pulse (ya da PulseAudio) çalışır olmalı.
#   - Backlight: laptop'larda görünür; backlight yoksa modül kendini gizler.
#   - İkonlar: tam symbolic ikon teması önerilir (papirus-icon-theme / adwaita).

{ pkgs, ... }:

let
  # 26.05 derlemesi wrapGAppsHook3 içerdiğinden YALNIZCA librsvg ekleniyor (unbloat).
  sfwbarPkg = pkgs.sfwbar.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.librsvg ];
  });
in
{
  home.packages = [ sfwbarPkg ];

  xdg.configFile."sfwbar/sfwbar.config".text = ''
    #Api2

    # Panel kalınlığı (CSS bunu @bar_thickness olarak kullanır).
    Set ThicknessHint = "40px";

    # Sabit IconTheme istersen aç (kurulu olduğundan emin ol):
    # Set IconTheme = "Papirus-Dark";

    # Taskbar öğesi sağ-tık menüsü (ilk-parti, hafif).
    include("winops.widget")

    # Sistem ölçer kaynakları: XCpuUtilization, XMem* değişkenlerini sağlar.
    include("cpu.source")
    include("memory.source")

    # Açılış: native popup'lara "dışarı tıkla -> kapan" davranışı ekle (madde 5).
    function("SfwbarInit") {
      Config("PopUp 'XVolumeWindow' { AutoClose = true }")
      Config("PopUp 'BacklightPopup' { AutoClose = true }")
      Config("PopUp 'SessionPopup'  { AutoClose = true }")
    }

    # /proc/loadavg -> 1/5/15 dakika yük ortalamaları (SysMon popup'ında kullanılır).
    scanner {
      file("/proc/loadavg") {
        $Load1  = RegEx("^([0-9.]+)")
        $Load5  = RegEx("^[0-9.]+ ([0-9.]+)")
        $Load15 = RegEx("^[0-9.]+ [0-9.]+ ([0-9.]+)")
      }
    }

    # ── Sistem Monitörü popup'ı: tıklayınca CPU · RAM · Load (madde 4) ──────────
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
            value    = Str(XMemUtilization*100, 0) + "%   " +
                       Str((XMemTotal-XMemFree-XMemCache-XMemBuff)/1048576, 1) + " / " +
                       Str(XMemTotal/1048576, 1) + " GiB"
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

    # ── Panel düzeni ───────────────────────────────────────────────────────────
    # NOT: labwc'de pager/placer ÇALIŞMAZ (sway'e özgü) — bilinçli olarak yok.
    layout "sfwbar" {
      layer          = "top"
      bar_id         = "bar-0"
      mirror         = "*"        # tüm çıkışlar; tek monitör için sil + 'monitor' aç
      exclusive_zone = "auto"     # panel yer ayırır (KDE davranışı)
      # monitor      = "DP-1"

      # ── Show Desktop (EN SOL): tıkla -> tüm pencereleri küçült/geri al (madde 7).
      #    foreign-toplevel Minimize kullanır; labwc destekler.
      include("showdesktop.widget")

      # ── Taskbar (sol): gruplanmamış, açılış sırası, odak alt-çizgisi ──
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

      # ── Volume: scroll -> swayosd (ses + OSD); tıkla -> slider'lı popup (madde 3) ──
      widget "volume.widget" {
        simple_icon        = True
        volume_thresholds  = [80, 50, 0]
        volume_icons       = ["audio-volume-high", "audio-volume-medium", "audio-volume-low"]
        volume_muted       = "audio-volume-muted"
        action[ScrollUp]   = Exec("swayosd-client --output-volume raise")
        action[ScrollDown] = Exec("swayosd-client --output-volume lower")
      }

      # ── Backlight: tıkla -> slider'lı popup; tekerle de ayarlanır (madde 2: iyi) ──
      widget "backlight.widget" {
        step           = 5
        max_brightness = 100
        min_brightness = 5
      }

      # ── Sistem Monitörü düğmesi (saatin SOLUNDA — madde 4) ──
      #    interval=2000 ile kaynakları sürekli besler -> popup değerleri anlık doğru.
      button {
        style    = "sysmon_btn"
        class    = "module"
        value    = "utilities-system-monitor"
        interval = 2000
        tooltip  = "CPU " + Str(XCpuUtilization*100,0) + "%    " +
                   "RAM " + Str(XMemUtilization*100,0) + "%"
        action   = PopUp("sysmon")
      }

      # ── Saat (üstte saat, altta tarih) ──
      widget "clock.widget" {
        disable               = false
        time_format           = "%H:%M\n%a %d %b"   # locale İngilizce değilse gün/ay adı
        tooltip_format        = "%A, %d %B %Y"      # sabit istersen: "%Y-%m-%d"
        week_starts_on_sunday = false
      }

      # ── Session: EN SAĞ (madde 1). Tıkla -> Lock/Logout/Reboot/Shutdown (onaylı) ──
      widget "session.widget" {
        # [icon, title, command] — etiketler İngilizce sabit (locale'den etkilenmez).
        session_actions = [
          ["system-suspend",     "Suspend",  "systemctl suspend"],
          ["system-lock-screen", "Lock",     "loginctl lock-session"],
          ["system-log-out",     "Logout",   "loginctl terminate-user $USER"],
          ["system-reboot",      "Reboot",   "systemctl reboot"],
          ["system-shutdown",    "Shutdown", "systemctl poweroff"]
        ]
      }
    }

    #CSS

    /* ── Breeze-Dark esinli palet. Native popup'lar bu @ renklerini kullanır,
          bu yüzden theme_* tanımları ZORUNLUDUR (yoksa popup'lar renksiz çıkar). */
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

    /* ── Modüller: ShowDesktop · Volume · Backlight · Session · SysMon (class="module") ── */
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
      min-width: 240px;
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

    /* ── Menü / tooltip — Breeze hissi (popup'lar kendi CSS'ini getirir; renkler
          yukarıdaki @theme_* / @borders tanımlarından gelir.) ── */
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
