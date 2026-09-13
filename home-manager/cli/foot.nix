{ ... }:

let
  bg = "3c3836";
  bg2 = "504945";
  fg = "ddc7a1";
  fgBright = "ebdbb2";
  yellow = "d8a657";
in
{
  programs.foot = {
    enable = true;

    server.enable = false;

    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:style=Regular:size=11";
        font-bold = "JetBrainsMono Nerd Font:style=Bold:size=11";
        font-italic = "JetBrainsMono Nerd Font:style=Italic:size=11";
        font-bold-italic = "JetBrainsMono Nerd Font:style=Bold Italic:size=11";

        pad = "8x8";

        selection-target = "both";

        initial-color-theme = "dark";
      };

      security.osc52 = "copy-enabled";

      scrollback = {
        lines = 5000;
        multiplier = "5.0";
      };

      cursor = {
        style = "block";
        blink = "yes";
      };

      mouse.hide-when-typing = "yes";

      bell.visual = "yes";

      "key-bindings" = {
        spawn-terminal = "Control+Shift+Return";

        pipe-selected = "[xargs -r -I{} foot hx {}] Control+Shift+e";
      };

      colors-dark = {
        alpha = "1.0";
        background = bg;
        foreground = fg;
        flash = yellow;

        dim-blend-towards = "white";

        selection-foreground = fg;
        selection-background = bg2;

        regular0 = "32302f";
        regular1 = "ea6962";
        regular2 = "a9b665";
        regular3 = yellow;
        regular4 = "7daea3";
        regular5 = "d3869b";
        regular6 = "89b482";
        regular7 = "d4be98";

        bright0 = bg2;
        bright1 = "f2857e";
        bright2 = "c3ce7e";
        bright3 = "ecbd6d";
        bright4 = "98c6bb";
        bright5 = "e6a0b3";
        bright6 = "a2cb9a";
        bright7 = fgBright;
      };
    };
  };
}
