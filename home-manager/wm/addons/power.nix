{ pkgs }:

pkgs.writeShellApplication {
  name = "power";

  runtimeInputs = [ pkgs.rofi ];

  text = ''
    # Grafik oturum once durdurulur. Waybar, swayidle, wlsunset ve masaustu
    # portallari ekrana baglidir; ekran onlardan once giderse "Broken pipe" ile
    # duserler ve systemd onlari basarisiz sayar. Hedef graphical-session.target:
    # labwc-session ona BindsTo ile bagli, portallar da PartOf.
    #
    # Eylem gecici bir birime tasinir, cunku bu betik cagiranin cgroup'unda
    # calisir: hedefi durdurmak betigi de oldururdu. Gecici birim ayri
    # cgroup'tadir ve ortami kullanici yoneticisinden alir.
    kapanis() {
      systemd-run --user --collect --quiet \
        sh -c "systemctl --user stop graphical-session.target; $1"
    }

    # Kilitleme ve askiya alma ekrani kapatmadigi icin dogrudan calisir.
    eylem() {
      case $1 in
        lock)     swaylock -f ;;
        suspend)  systemctl suspend ;;
        logout)   kapanis "labwc --exit" ;;
        reboot)   kapanis "systemctl reboot" ;;
        poweroff) kapanis "systemctl poweroff" ;;
        *)
          printf 'bilinmeyen eylem: %s\n' "$1" >&2
          exit 2
          ;;
      esac
    }

    # Menu, tikladigi modulun hemen ustunde acilir. Secenek metinleri
    # labwc/config/menu.xml ile bilerek ayni.
    menu() {
      local secim
      secim=$(printf '%s\n' \
        "Lock screen" \
        "Suspend" \
        "Log out" \
        "Restart" \
        "Shut down" \
        | rofi -dmenu -i -p "Power" -no-custom \
            -theme-str 'window { location: south east; anchor: south east; x-offset: -4px; y-offset: -8px; width: 240px; } mainbox { children: [ inputbar, listview ]; } listview { lines: 5; fixed-height: false; }') || return 0

      case $secim in
        "Lock screen") eylem lock ;;
        "Suspend")     eylem suspend ;;
        "Log out")     eylem logout ;;
        "Restart")     eylem reboot ;;
        "Shut down")   eylem poweroff ;;
      esac
    }

    case "''${1:-}" in
      menu) menu ;;
      lock | suspend | logout | reboot | poweroff) eylem "$1" ;;
      *)
        printf 'kullanim: power menu|lock|suspend|logout|reboot|poweroff\n' >&2
        exit 2
        ;;
    esac
  '';
}
