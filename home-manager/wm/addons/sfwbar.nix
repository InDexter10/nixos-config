# sfwbar.nix — labwc icin KDE-Plasma esinli, premium, unbloat panel
# Hedef surumler (teyit): NixOS 26.05 · labwc 0.9.7 · sfwbar 1.0_beta17
# Kapsam: Home Manager modulu.
#
# DUZEN (sol -> sag):
#   [ Taskbar (gruplanmamis) ]  <esnek bosluk>
#   [ Tray ] [ Volume ] [ Backlight ] [ SysMon ] [ Clock ] [ Power ]
#
# ── BU SURUMDEKI DEGISIKLIKLER ───────────────────────────────────────────────
#
# 1) TUM GORUNUR METIN INGILIZCE. (Yorumlar Turkce calisma notu; ekrana cikmaz.)
#
# 2) CPU DOGRULANDI/DUZELTILDI. Shipped cpu.source'taki XCpuUtilization'in PAYI
#    yalnizca `user` zamanini sayiyordu (nice+system disarida) -> htop'tan DUSUK.
#    Artik kendi /proc/stat taramamiz: busy = user+nice+system+irq+softirq,
#    total = busy+idle+iowait. htop "toplam" ile uyumlu. cpu.source KALDIRILDI.
#
# 3) SES/PARLAKLIK 3'ER ADIM.
#    - Parlaklik: backlight.widget'in `step` Var'i = 3 (native logind D-Bus).
#    - Ses: layout dugmesinde dogrudan VolumeCtl (+3/-3), 0-100 ARASI KILITLI
#      (yazilim amplifikasyonu yok; rc.xml'deki `-l 1` niyetiyle ayni).
#
# 4) SES MODULUNE TIK -> "volctl" popup'i: HOPARLOR + MIKROFON. Her ikisi de
#    ikon ile susturulup acilabilir, seviye cubugu tiklayinca ayarlanir. Native
#    XVolumeWindow mikrofonu gostermedigi icin kendi kompakt popup'imiz var.
#    (volume.widget / volume-popup.widget KALDIRILDI; sadece module("pulsectl").)
#
# 5) SAAT yalnizca saati gosterir (tek satir). Tarih zaten tiklayinca XCal'de.
#
# 6) TAKVIM (XCal) acik kalmasi duzeltildi (AutoClose) + premium stillendi;
#    paletteki eksik @theme_border_color / @border renkleri eklendi.
#
# 7) PANEL YUKSELTI HISSI: ust kenar acik, alt kenar koyu (kabartma) -> panel
#    icerigin "ustunde" durur. layer="top" (pencerelerin ustu). Tam-ekranin da
#    ustunde olsun istersen layer="overlay" yap (videoyu kapatir, dikkat).
#
# 8) SYSTEM MONITOR: CPU/RAM/Disk icin doluluk cubuklari + Disk() ile disk.
#
# AUTOSTART (bu modulde YONETILMEZ). labwc/autostart — wob YALNIZCA medya tuslari
# icin OSD (panel scroll'u native, wob beslemez). rc.xml DEGISMEDI:
#   WOBSOCK="$XDG_RUNTIME_DIR/wob.fifo"; rm -f "$WOBSOCK"; mkfifo "$WOBSOCK"; tail -f "$WOBSOCK" | wob &
#   nm-applet &
#   sfwbar &
#
# SVG (nixpkgs #430793): backlight ikonu SVG ciziyor -> librsvg gerekli.
# nixpkgs duzeltirse `sfwbarPkg = pkgs.sfwbar;` yap.

{ pkgs, ... }:

let
  # 26.05 derlemesi wrapGAppsHook3 icerdiginden YALNIZCA librsvg (unbloat).
  # libpulseaudio + pipewire derlemede var -> native ses (pulsectl) calisir.
  sfwbarPkg = pkgs.sfwbar.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.librsvg ];
  });
in
{
  home.packages = [ sfwbarPkg ];

  xdg.configFile."sfwbar/sfwbar.config".text = ''
    #Api2

    # Panel kalinligi (CSS bunu min-height olarak kullanir).
    Set ThicknessHint = "40px";

    # Ses arka ucu (pulsectl): Volume()/VolumeCtl()/VolumeInfo() ve "volume"
    # trigger'ini saglar. WirePlumber/pipewire-pulse ile konusur.
    module("pulsectl")

    # Taskbar ogesi sag-tik menusu (ilk-parti, hafif).
    include("winops.widget")

    # Acilis: native popup'lara "disari tikla -> kapan" davranisi ekle.
    # XCal  = clock.widget'in actigi takvim popup'i (eskiden listede yoktu).
    # BacklightPopup = backlight.widget'in native slider popup'i.
    function("SfwbarInit") {
      Config("PopUp 'BacklightPopup' { AutoClose = true }")
      Config("PopUp 'XCal'           { AutoClose = true }")
    }

    # ── /proc kaynaklari (Api2: scanner{} sarmalayici YOK, duz File) ────────────

    # CPU: tum /proc/stat alanlarini tek geciste oku (delta tutarli olsun diye).
    # ^cpu  satiri = toplam (cpu0/cpu1... satirlari "cpu " ile eslesmez).
    File("/proc/stat") {
      CpuUser = RegEx("^cpu [\t ]*([0-9]+)")
      CpuNice = RegEx("^cpu [\t ]*[0-9]+ ([0-9]+)")
      CpuSys  = RegEx("^cpu [\t ]*(?:[0-9]+ ){2}([0-9]+)")
      CpuIdle = RegEx("^cpu [\t ]*(?:[0-9]+ ){3}([0-9]+)")
      CpuIow  = RegEx("^cpu [\t ]*(?:[0-9]+ ){4}([0-9]+)")
      CpuIrq  = RegEx("^cpu [\t ]*(?:[0-9]+ ){5}([0-9]+)")
      CpuSirq = RegEx("^cpu [\t ]*(?:[0-9]+ ){6}([0-9]+)")
    }

    # RAM: cekirdek MemAvailable -> used = Total - Available (free "used" ile ayni).
    File("/proc/meminfo") {
      MemTotal = RegEx("MemTotal:[\t ]+([0-9]+)")
      MemAvail = RegEx("MemAvailable:[\t ]+([0-9]+)")
    }
    File("/proc/loadavg") {
      Load1  = RegEx("^([0-9.]+)")
      Load5  = RegEx("^[0-9.]+ ([0-9.]+)")
      Load15 = RegEx("^[0-9.]+ [0-9.]+ ([0-9.]+)")
    }

    # CPU toplam kullanim (htop ile uyumlu): busy/total, delta tabanli.
    # NOT: ilk olcumde "acilis-itibariyle ortalama" gosterir, 2. olcumde oturur.
    Set CpuBusy = (CpuUser-CpuUser.pval) + (CpuNice-CpuNice.pval) +
                  (CpuSys-CpuSys.pval) + (CpuIrq-CpuIrq.pval) + (CpuSirq-CpuSirq.pval)
    Set CpuAll  = CpuBusy + (CpuIdle-CpuIdle.pval) + (CpuIow-CpuIow.pval)
    Set CpuUtil = If(CpuAll > 0, CpuBusy / CpuAll, 0)

    # ── System Monitor popup'i: CPU · RAM · Disk · Load ─────────────────────────
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
          label { style = "sysmon_val"; interval = 1000; value = Str(CpuUtil*100, 0) + "%" }
        }
        scale { style = "sysmon_bar"; interval = 1000; value = CpuUtil }

        grid {
          style = "sysmon_row"
          css   = "* { -GtkWidget-direction: right; }"
          label { value = "RAM"; style = "sysmon_key" }
          label {
            style    = "sysmon_val"
            interval = 2000
            # kiB -> GiB: /1048576 ; $ YOK -> sade ad = sayisal (.val)
            value    = Str((MemTotal-MemAvail)/1048576, 1) + " / " +
                       Str(MemTotal/1048576, 1) + " GiB   " +
                       Str((MemTotal-MemAvail)/MemTotal*100, 0) + "%"
          }
        }
        scale { style = "sysmon_bar"; interval = 2000; value = (MemTotal-MemAvail)/MemTotal }

        grid {
          style = "sysmon_row"
          css   = "* { -GtkWidget-direction: right; }"
          label { value = "Disk"; style = "sysmon_key" }
          label {
            style    = "sysmon_val"
            interval = 5000
            value    = Str(Disk("/","%used")*100, 0) + "%   " +
                       Str(Disk("/","avail")/1073741824, 1) + " GiB free"
          }
        }
        scale { style = "sysmon_bar"; interval = 5000; value = Disk("/","%used") }

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

    # ── Sound popup'i: Speaker + Microphone (her ikisi susturulabilir) ──────────
    PopUp "volctl" {
      AutoClose = true
      grid {
        style = "volctl_box"
        css   = "* { -GtkWidget-direction: bottom; }"

        label { value = "Sound"; style = "volctl_title" }

        # Speaker
        grid {
          style = "volctl_row"
          css   = "* { -GtkWidget-direction: right; }"
          button {
            style   = "volctl_icon"
            trigger = "volume"
            value   = If(Volume("sink-mute"), "audio-volume-muted",
                       Lookup(Volume("sink-volume"),
                         66, "audio-volume-high",
                         33, "audio-volume-medium",
                          0, "audio-volume-low", "audio-volume-low"))
            tooltip = "Mute / unmute speaker"
            action  = VolumeCtl("sink-mute toggle")
          }
          scale {
            style    = "volctl_scale"
            trigger  = "volume"
            value    = Volume("sink-volume")/100
            action[1] = VolumeCtl("sink-volume " + Str(GtkEvent("dir")*100))
          }
          label {
            style   = "volctl_pct"
            trigger = "volume"
            value   = If(Volume("sink-mute"), "off", Str(Volume("sink-volume"),0) + "%")
          }
        }

        # Microphone (tek guvenli ikon; susturulunca kirmizi + "off")
        grid {
          style = "volctl_row"
          css   = "* { -GtkWidget-direction: right; }"
          button {
            style   = If(Volume("source-mute"), "volctl_icon_muted", "volctl_icon")
            trigger = "volume"
            value   = "audio-input-microphone"
            tooltip = "Mute / unmute microphone"
            action  = VolumeCtl("source-mute toggle")
          }
          scale {
            style    = "volctl_scale"
            trigger  = "volume"
            value    = Volume("source-volume")/100
            action[1] = VolumeCtl("source-volume " + Str(GtkEvent("dir")*100))
          }
          label {
            style   = "volctl_pct"
            trigger = "volume"
            value   = If(Volume("source-mute"), "off", Str(Volume("source-volume"),0) + "%")
          }
        }
      }
    }

    # ── Power popup'i: Lock · Suspend · Reboot · Shutdown ───────────────────────
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

    # ── Panel duzeni ────────────────────────────────────────────────────────────
    layout "sfwbar" {
      layer          = "top"      # pencerelerin ustu. Tam-ekran ustu icin "overlay".
      bar_id         = "bar-0"
      mirror         = "*"        # tum ciktilar; tek monitor icin sil + 'monitor' ac
      exclusive_zone = "auto"     # panel yer ayirir (KDE davranisi)
      # monitor      = "DP-1"

      # ── Taskbar (EN SOL): gruplanmamis, acilis sirasi, odak alt-cizgisi ──
      taskbar {
        rows     = 1
        icons    = true
        labels   = false
        group    = false
        sort     = false
        tooltips = true
        action[RightClick]  = Menu("winops")
        action[MiddleClick] = Close()
      }

      # ── Esnek bosluk: sistem alanini saga iter ──
      label { css = "* { -GtkWidget-hexpand: true; }" }

      # ── Sistem tepsisi (SNI): nm-applet (Wi-Fi), vb. ──
      tray { rows = 1 }

      # ── Volume (ozel): ikon seviyeye gore; scroll 3'er ve 0-100 kilitli;
      #    sol-tik -> Sound popup (hoparlor+mikrofon); sag-tik -> mute;
      #    orta-tik -> mikrofon mute. Hicbir script/wob yok. ──
      button {
        class   = "module"
        trigger = "volume"
        value   = If(Volume("sink-mute"), "audio-volume-muted",
                   Lookup(Volume("sink-volume"),
                     66, "audio-volume-high",
                     33, "audio-volume-medium",
                      0, "audio-volume-low", "audio-volume-low"))
        tooltip = "Volume: " + Str(Volume("sink-volume"),0) + "%" +
                  If(Volume("sink-mute"), " (muted)", "") +
                  "\nMic: " + If(Volume("source-mute"), "muted", Str(Volume("source-volume"),0) + "%")
        action[LeftClick]   = PopUp("volctl")
        action[RightClick]  = VolumeCtl("sink-mute toggle")
        action[MiddleClick] = VolumeCtl("source-mute toggle")
        action[ScrollUp]    = VolumeCtl("sink-volume " + Str(Min(Volume("sink-volume")+3, 100)))
        action[ScrollDown]  = VolumeCtl("sink-volume " + Str(Max(Volume("sink-volume")-3, 0)))
      }

      # ── Backlight: native (logind D-Bus). Scroll = step% (3). Tik = slider. ──
      widget "backlight.widget" {
        step           = 3;
        max_brightness = 100;
        min_brightness = 5;
      }

      # ── System Monitor dugmesi (saatin SOLUNDA) ──
      button {
        style    = "sysmon_btn"
        class    = "module"
        value    = "utilities-system-monitor"
        interval = 2000
        tooltip  = "CPU " + Str(CpuUtil*100,0) + "%    " +
                   "RAM " + Str((MemTotal-MemAvail)/MemTotal*100,0) + "%"
        action   = PopUp("sysmon")
      }

      # ── Clock: yalnizca saat. Tik -> XCal (tarih/takvim). ──
      widget "clock.widget" {
        time_format           = "%H:%M";
        tooltip_format        = "%A, %d %B %Y";
        week_starts_on_sunday = 0;
      }

      # ── Power (EN SAG): tik -> power popup ──
      button {
        style   = "power_btn"
        class   = "module"
        value   = "system-shutdown"
        tooltip = "Power"
        action  = PopUp("power")
      }
    }

    #CSS

    /* ── Breeze-Dark esinli palet. Native popup'lar bu @ renklerini kullanir. */
    @define-color theme_bg_color   #232629;
    @define-color theme_fg_color   #fcfcfc;
    @define-color theme_text_color #fcfcfc;
    @define-color borders          rgba(255,255,255,0.12);
    @define-color accent           #3daee9;
    @define-color hover_bg         rgba(61,174,233,0.15);
    @define-color active_bg        rgba(61,174,233,0.25);
    @define-color muted_red        #da4453;

    /* cal.widget'in bekledigi ama palette olmayan renkler (takvim eksik ciziliyordu) */
    @define-color theme_border_color @accent;
    @define-color border             @borders;

    /* ── Panel govdesi: kabartma (ust acik / alt koyu) -> "yukselti" hissi ── */
    window#sfwbar {
      -GtkWidget-direction: bottom;
      background-color: @theme_bg_color;
      color: @theme_fg_color;
      min-height: 40px;
      border-bottom: 1px solid rgba(0,0,0,0.55);
      box-shadow: inset 0 1px 0 rgba(255,255,255,0.06);
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

    /* sink/backlight yoksa "hidden" stiline duser -> bos kutu gorunmesin. */
    #hidden { -GtkWidget-visible: false; }

    /* ── Taskbar: her pencere ayri, belirgin odak alt-cizgisi ── */
    button#taskbar_item {
      padding: 0 8px;
      margin: 2px 2px;
      border-radius: 4px;
      border-bottom: 3px solid transparent;
      transition: background-color 150ms ease, border-color 150ms ease;
    }
    button#taskbar_item image { min-width: 22px; min-height: 22px; }
    button#taskbar_item:hover  { background-color: @hover_bg; }
    button#taskbar_item.focused {
      background-color: @active_bg;
      border-bottom: 3px solid @accent;
    }

    /* ── Moduller: Volume · Backlight · SysMon · Power (class="module") ── */
    .module {
      padding: 0 7px;
      margin: 0 1px;
      border-radius: 4px;
      -GtkWidget-valign: center;
      transition: background-color 150ms ease;
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
      transition: background-color 150ms ease;
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
      font-size: 12px;
      font-weight: 500;
      -GtkWidget-valign: center;
      -GtkLabel-align: 0.5;
    }

    /* ── Ortak popup kart hissi (sysmon / power / volctl) ── */
    window#sysmon, window#power, window#volctl { background: rgba(0,0,0,0); }
    grid#sysmon_box, grid#power_box, grid#volctl_box {
      margin: 14px;
      border-radius: 12px;
      border: 1px solid @borders;
      background-color: @theme_bg_color;
      box-shadow: 0 6px 20px rgba(0,0,0,0.50);
    }

    /* ── System Monitor popup'i ── */
    grid#sysmon_box { padding: 16px 18px; min-width: 260px; }
    label#sysmon_title {
      font-size: 13px; font-weight: bold; padding-bottom: 12px; -GtkLabel-align: 0;
    }
    grid#sysmon_row { padding: 2px 0; }
    label#sysmon_key {
      font-size: 12px; color: alpha(@theme_fg_color, 0.65);
      min-width: 56px; -GtkLabel-align: 0;
    }
    label#sysmon_val {
      font-size: 12px; -GtkWidget-hexpand: true; -GtkLabel-align: 1;
    }
    label#sysmon_sep { min-height: 10px; }
    #sysmon_bar { margin: 1px 0 8px 0; -GtkWidget-hexpand: true; }
    #sysmon_bar trough {
      min-height: 6px; border-radius: 3px;
      background-color: alpha(@theme_fg_color, 0.12); border: none;
    }
    #sysmon_bar progress {
      min-height: 6px; border-radius: 3px; background-color: @accent;
    }

    /* ── Sound popup'i ── */
    grid#volctl_box { padding: 14px 16px; min-width: 270px; }
    label#volctl_title {
      font-size: 13px; font-weight: bold; padding-bottom: 10px; -GtkLabel-align: 0;
    }
    grid#volctl_row { padding: 5px 0; }
    button#volctl_icon, button#volctl_icon_muted {
      padding: 5px; margin-right: 8px; border-radius: 6px;
      transition: background-color 150ms ease;
    }
    button#volctl_icon image, button#volctl_icon_muted image { min-width: 20px; min-height: 20px; }
    button#volctl_icon:hover, button#volctl_icon_muted:hover { background-color: @hover_bg; }
    button#volctl_icon_muted { color: @muted_red; }
    button#volctl_icon_muted image { color: @muted_red; }
    #volctl_scale {
      margin-right: 10px; -GtkWidget-hexpand: true; -GtkWidget-valign: center;
    }
    #volctl_scale trough {
      min-height: 8px; border-radius: 4px;
      background-color: alpha(@theme_fg_color, 0.12); border: none;
    }
    #volctl_scale progress {
      min-height: 8px; border-radius: 4px; background-color: @accent;
    }
    label#volctl_pct {
      font-size: 12px; min-width: 38px; -GtkLabel-align: 1;
      color: alpha(@theme_fg_color, 0.8);
    }

    /* ── Power popup'i ── */
    grid#power_box { padding: 12px 14px; }
    button#power_item {
      padding: 10px; margin: 0 3px; border-radius: 8px;
      transition: background-color 150ms ease;
    }
    button#power_item image { min-width: 28px; min-height: 28px; }
    button#power_item:hover { background-color: @hover_bg; }

    /* ── Takvim popup'i (cal.widget) — premium (id+id ile cal CSS'ini eziyoruz) ── */
    window#XCal { background: rgba(0,0,0,0); }
    grid#cal_popup_grid {
      margin: 14px; padding: 14px 16px; border-radius: 12px;
      border: 1px solid @borders; background-color: @theme_bg_color;
      box-shadow: 0 6px 20px rgba(0,0,0,0.50);
    }
    label#cal_clock { font-size: 30px; font-weight: 600; color: @theme_fg_color; }
    label#cal_clock_date {
      color: alpha(@theme_fg_color, 0.6);
      margin-bottom: 10px; border-bottom: 1px dashed @borders;
    }
    label#cal_date { font-weight: 600; }
    image#cal_arrow {
      min-width: 16px; min-height: 16px; -GtkWidget-valign: center;
      transition: color 150ms ease;
    }
    image#cal_arrow:hover { color: @accent; }
    grid#cal_popup_grid label#cal_cell_days {
      color: alpha(@theme_fg_color, 0.5); font-size: 10px; font-weight: 700;
      min-width: 30px; min-height: 26px;
    }
    grid#cal_popup_grid label#cal_cell_cur_weekday,
    grid#cal_popup_grid label#cal_cell_cur_weekend,
    grid#cal_popup_grid label#cal_cell_today,
    grid#cal_popup_grid label#cal_cell_other {
      min-width: 30px; min-height: 30px; border-radius: 6px;
      border: 1px solid rgba(0,0,0,0);
    }
    grid#cal_popup_grid label#cal_cell_cur_weekend { color: alpha(@theme_fg_color, 0.55); }
    grid#cal_popup_grid label#cal_cell_other       { color: alpha(@theme_fg_color, 0.30); }
    grid#cal_popup_grid label#cal_cell_today {
      background-color: @accent; color: #ffffff; border: 1px solid @accent;
    }

    /* ── Menu / tooltip — Breeze hissi ── */
    menu {
      background-color: @theme_bg_color; border: 1px solid @borders; padding: 4px;
    }
    menuitem { color: @theme_fg_color; padding: 4px 10px; border-radius: 4px; }
    menuitem:hover { background-color: @accent; color: white; }

    tooltip {
      background-color: @theme_bg_color; color: @theme_fg_color;
      border: 1px solid @borders;
    }
  '';
}
