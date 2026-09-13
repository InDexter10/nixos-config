{ config, pkgs, ... }:

let
  p = import ../../theme/palette.nix;
  inherit (config.lib.formats.rasi) mkLiteral;

  hex = {
    zemin = "#121211";
    yuzey = "#1e1f1b";
    cerceve = "#5a6052";
    soluk = "#6f6d6f";
    metin = "#98acaa";
    istem = "#b1b354";
    etkin = "#6fa197";
    secimZemin = "#290019";
    secimMetin = "#c8e732";
  };
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    font = "${p.fontUI} ${toString p.fontUISize}";

    extraConfig = {
      modi = "drun,window,run";

      show-icons = true;
      icon-theme = p.iconTheme;
      drun-display-format = "{name}";
      terminal = "foot";

      display-drun = "Apps";
      display-window = "Windows";
      display-run = "Run";

      auto-select = false;
      matching = "normal";
      sort = true;
      sorting-method = "fzf";

      kb-mode-next = "Right,Control+Tab";
      kb-mode-previous = "Left,Control+ISO_Left_Tab";
      kb-move-char-back = "Control+b";
      kb-move-char-forward = "Control+f";
    };

    theme = {
      "*" = {
        background-color = mkLiteral hex.zemin;
        text-color = mkLiteral hex.metin;
      };

      "window" = {
        location = mkLiteral "north";
        anchor = mkLiteral "north";
        y-offset = mkLiteral "80px";
        width = mkLiteral "620px";
        border = mkLiteral "1px";
        border-color = mkLiteral hex.cerceve;
        border-radius = mkLiteral "6px";
        background-color = mkLiteral hex.zemin;
      };

      "mainbox" = {
        padding = mkLiteral "10px";
        spacing = mkLiteral "10px";
        children = map mkLiteral [
          "inputbar"
          "mode-switcher"
          "listview"
        ];
      };

      "inputbar" = {
        background-color = mkLiteral hex.yuzey;
        border-radius = mkLiteral "4px";
        padding = mkLiteral "9px 12px";
        spacing = mkLiteral "10px";
        children = map mkLiteral [
          "prompt"
          "entry"
        ];
      };
      "prompt" = {
        text-color = mkLiteral hex.istem;
        background-color = mkLiteral "transparent";
      };
      "entry" = {
        text-color = mkLiteral hex.metin;
        background-color = mkLiteral "transparent";
        placeholder = "Search";
        placeholder-color = mkLiteral hex.soluk;
        cursor = mkLiteral "text";
      };

      "mode-switcher" = {
        spacing = mkLiteral "6px";
        background-color = mkLiteral "transparent";
      };
      "button" = {
        padding = mkLiteral "6px";
        border-radius = mkLiteral "4px";
        background-color = mkLiteral hex.yuzey;
        text-color = mkLiteral hex.metin;
        cursor = mkLiteral "pointer";
      };
      "button selected" = {
        background-color = mkLiteral hex.secimZemin;
        text-color = mkLiteral hex.secimMetin;
      };

      "listview" = {
        lines = 10;
        columns = 1;
        scrollbar = false;
        fixed-height = false;
        spacing = mkLiteral "2px";
        background-color = mkLiteral "transparent";
      };

      "element" = {
        padding = mkLiteral "7px 10px";
        spacing = mkLiteral "10px";
        border-radius = mkLiteral "4px";
        background-color = mkLiteral "transparent";
        cursor = mkLiteral "pointer";
      };
      "element normal active" = {
        text-color = mkLiteral hex.etkin;
      };
      "element selected" = {
        background-color = mkLiteral hex.secimZemin;
        text-color = mkLiteral hex.secimMetin;
      };
      "element selected active" = {
        background-color = mkLiteral hex.secimZemin;
        text-color = mkLiteral hex.secimMetin;
      };
      "element-icon" = {
        size = mkLiteral "1.15em";
        background-color = mkLiteral "transparent";
        vertical-align = mkLiteral "0.5";
      };
      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };

      "message" = {
        padding = mkLiteral "8px";
        background-color = mkLiteral hex.yuzey;
        border-radius = mkLiteral "4px";
      };
      "textbox" = {
        text-color = mkLiteral hex.soluk;
        background-color = mkLiteral "transparent";
      };
    };
  };
}
