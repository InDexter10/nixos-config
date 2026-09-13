{ pkgs }:

pkgs.writeShellApplication {
  name = "osd";

  runtimeInputs = with pkgs; [
    wireplumber
    brightnessctl
    gawk
  ];

  text = ''
    FIFO="''${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR tanimsiz}/wob.fifo"

    goster() {
      [[ -p $FIFO ]] || return 0
      printf '%s\n' "$1" 1<>"$FIFO" 2>/dev/null || true
    }

    # Sessizken seviye degil 0 gosterilir. int() asagi keser ve 0.29 * 100
    # kayan noktada 28.999... eder; yuvarlama icin +0.5 sart.
    ses_goster() {
      local ham
      ham=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
      case $ham in
        *MUTED*) goster 0 ;;
        *) goster "$(awk '{ print int($2 * 100 + 0.5) }' <<<"$ham")" ;;
      esac
    }

    parlaklik_goster() {
      goster "$(brightnessctl -m | awk -F, '{ sub(/%/, "", $4); print $4 }')"
    }

    case "''${1:-}" in
      # -l 1: donanimi asan yazilimsal yukseltme bozulmaya yol acar.
      vol-up)    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ; ses_goster ;;
      vol-down)  wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%- ; ses_goster ;;
      vol-mute)  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle     ; ses_goster ;;

      # Mikrofonun gostergesi yok: durumu waybar'daki "privacy" modulu tasir.
      mic-mute)  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;

      bright-up)   brightnessctl -q set 5%+ ; parlaklik_goster ;;
      bright-down) brightnessctl -q set 5%- ; parlaklik_goster ;;

      *)
        printf 'kullanim: osd vol-up|vol-down|vol-mute|mic-mute|bright-up|bright-down\n' >&2
        exit 2
        ;;
    esac
  '';
}
