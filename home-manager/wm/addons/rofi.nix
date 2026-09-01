{ config, pkgs, ... }:

let
  p = import ../../theme/palette.nix;
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi; # 2.0: Wayland-native

    font = "${p.fontUI} ${toString p.fontUISize}";

    extraConfig = {
      # drun uygulamalar, window ACIK PENCERELER arasi aranabilir gecis
      # (Alt-Tab'in tum masaustlerini kapsayan hali), run $PATH komutlari.
      modi = "drun,window,run";

      show-icons = true;
      icon-theme = p.iconTheme;
      drun-display-format = "{name}";
      terminal = "alacritty";

      display-drun = "Uygulama";
      display-window = "Pencere";
      display-run = "Calistir";

      auto-select = false;
      matching = "normal";
      sort = true;
      sorting-method = "fzf";

      kb-mode-next = "Control+Tab";
      kb-mode-previous = "Control+ISO_Left_Tab";
    };

    theme = {
      "*" = {
        background-color = mkLiteral p.bg;
        text-color = mkLiteral p.fg;
      };

      "window" = {
        location = mkLiteral "north";
        anchor = mkLiteral "north";
        y-offset = mkLiteral "80px"; # panel altina yapismasin
        width = mkLiteral "620px";
        border = mkLiteral "1px";
        border-color = mkLiteral p.border;
        border-radius = mkLiteral "6px";
        background-color = mkLiteral p.bg;
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
        background-color = mkLiteral p.base;
        border-radius = mkLiteral "4px";
        padding = mkLiteral "9px 12px";
        spacing = mkLiteral "10px";
        children = map mkLiteral [
          "prompt"
          "entry"
        ];
      };
      "prompt" = {
        text-color = mkLiteral p.accent;
        background-color = mkLiteral "transparent";
      };
      "entry" = {
        text-color = mkLiteral p.fg;
        background-color = mkLiteral "transparent";
        placeholder = "Ara";
        placeholder-color = mkLiteral p.fgDim;
        cursor = mkLiteral "text";
      };

      "mode-switcher" = {
        spacing = mkLiteral "6px";
        background-color = mkLiteral "transparent";
      };
      "button" = {
        padding = mkLiteral "6px";
        border-radius = mkLiteral "4px";
        background-color = mkLiteral p.base;
        text-color = mkLiteral p.fgDim;
        cursor = mkLiteral "pointer";
      };
      "button selected" = {
        background-color = mkLiteral p.accent;
        text-color = mkLiteral p.accentFg;
      };

      "listview" = {
        lines = 10;
        columns = 1;
        scrollbar = false;
        fixed-height = true;
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
        text-color = mkLiteral p.accent; # o an calisan uygulama
      };
      "element selected" = {
        background-color = mkLiteral p.accent;
        text-color = mkLiteral p.accentFg;
      };
      "element selected active" = {
        background-color = mkLiteral p.accent;
        text-color = mkLiteral p.accentFg;
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
        background-color = mkLiteral p.base;
        border-radius = mkLiteral "4px";
      };
      "textbox" = {
        text-color = mkLiteral p.fgDim;
        background-color = mkLiteral "transparent";
      };
    };
  };
}
