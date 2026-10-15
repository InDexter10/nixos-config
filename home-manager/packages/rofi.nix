{ config, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;

    font = "Inter 11";
    terminal = "foot";
    location = "top";

    # Yalnizca drun; script, ssh, window ve filebrowser modlari yuklenmez.
    modes = [ "drun" ];

    extraConfig = {
      # Uygulama ve giris gecmisi (rofi3.druncache, rofi-entry-history.txt) diske yazilmaz.
      disable-history = true;
      drun-display-format = "{name}";
      matching = "fuzzy";
      sort = true;
    };

    # Renkler varsayilan temadan gelir; asagisi yalnizca yerlesim.
    theme = {
      "@import" = "default";

      window = {
        width = mkLiteral "100%";
        border = mkLiteral "0 0 1px 0";
        padding = mkLiteral "8px 12px";
        children = map mkLiteral [ "horibox" ];
      };

      horibox = {
        orientation = mkLiteral "horizontal";
        spacing = mkLiteral "12px";
        children = map mkLiteral [
          "entry"
          "listview"
        ];
      };

      # Gizli; yazilan metin filtrelemeye devam eder.
      entry.enabled = false;

      listview = {
        layout = mkLiteral "horizontal";
        spacing = mkLiteral "4px";
        lines = 100;
        scrollbar = false;
      };

      element = {
        padding = mkLiteral "0 8px";
        border-radius = mkLiteral "3px";
      };
    };
  };
}
