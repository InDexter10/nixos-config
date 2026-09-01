{ config, ... }:

let
  p = import ../../theme/palette.nix;

  # swaylock diyez kabul etmez: "#rrggbb" -> "rrggbb"
  h = c: builtins.substring 1 6 c;
in
{
  programs.swaylock = {
    enable = true;

    settings = {
      image = "${config.home.homeDirectory}/${p.wallpaperFile}";
      scaling = "fill";
      color = h p.bg; # gorsel yuklenemezse

      # Duvar kagidini karartip halkayi one cikarir; ayrica omuz surfune
      # karsi ekran icerigini gizler.
      effect-blur = "7x3";
      effect-vignette = "0.4:0.4";

      indicator = true;
      indicator-radius = 90;
      indicator-thickness = 8;
      indicator-caps-lock = true;
      indicator-idle-visible = false;
      disable-caps-lock-text = false;

      font = p.fontUI;
      font-size = 20;

      # Her durum ayri renk: ne oldugu bir bakista anlasilir.
      ring-color = h p.border;
      ring-ver-color = h p.accent;
      ring-wrong-color = h p.urgent;
      ring-clear-color = h p.warn;
      key-hl-color = h p.accent;
      bs-hl-color = h p.warn;

      inside-color = "00000088";
      inside-ver-color = "00000088";
      inside-wrong-color = "00000088";
      inside-clear-color = "00000088";

      line-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      line-clear-color = "00000000";

      separator-color = "00000000";

      text-color = h p.fg;
      text-ver-color = h p.accent;
      text-wrong-color = h p.urgent;
      text-clear-color = h p.warn;
      text-caps-lock-color = h p.warn;

      # Makinenin basindan ayrildiginda birinin denedigini fark ettirir.
      show-failed-attempts = true;

      ignore-empty-password = true;
    };
  };
}
