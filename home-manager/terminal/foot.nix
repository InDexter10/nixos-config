{ ... }:

{
  programs.foot = {
    enable = true;

    server.enable = false;

    settings = {
      main = {
        font = "JetBrains Mono:size=11, Symbols Nerd Font Mono:size=11";

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
    };
  };
}
