{ ... }:

let
  p = import ../../theme/palette.nix;
in
{
  services.mako = {
    enable = true;

    settings = {
      # Sag ustte, panelin altinda.
      anchor = "top-right";
      margin = "48,12,12,12";
      width = 380;
      height = 200; # ust sinir; icerik kadar buyur
      padding = "12,14";

      background-color = p.elevated;
      text-color = p.fg;
      border-color = p.border;
      border-size = 1;
      border-radius = 6;
      progress-color = "over ${p.accent}";
      font = "${p.fontUI} ${toString p.fontUISize}";

      default-timeout = 6000;
      max-visible = 4;
      layer = "overlay"; # tam ekran uygulamalarin da ustunde
      markup = true;
      actions = true;
      icons = true;
      max-icon-size = 40;
      group-by = "app-name";
      format = "<b>%s</b>\\n%b";
    };

    extraConfig = ''
      [grouped]
      format=<b>%s</b>\n%b
      border-color=${p.accent}

      [urgency=low]
      border-color=${p.border}
      text-color=${p.fgDim}
      default-timeout=4000

      [urgency=normal]
      border-color=${p.border}

      # Kritik: KENDILIGINDEN KAPANMAZ (disk doldu / guc kesildi gibi).
      [urgency=high]
      border-color=${p.urgent}
      text-color=${p.fg}
      default-timeout=0

      # Ceviri popup'i: uzun metin gosterdigi icin genis ve uzun omurlu.
      # Kaynak kelime vurgu renginde, ceviri normal metin renginde.
      [app-name=translate]
      background-color=${p.elevated}
      text-color=${p.fg}
      border-color=${p.accent}
      border-size=2
      border-radius=6
      width=460
      height=560
      padding=16
      default-timeout=14000
      markup=1
      format=<span foreground='${p.accent}' size='large'><b>%s</b></span>\n%b
    '';
  };
}
