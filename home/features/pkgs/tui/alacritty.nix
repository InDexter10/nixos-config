{ pkgs, ... }:

{

  programs.alacritty = {
    enable = true;

    settings = {
      env = {
        TERM = "xterm-256color";
      };

      window = {
        padding = {
          x = 12;
          y = 12;
        };

        dynamic_padding = true;

        opacity = 0.90;

        title = "Alacritty";

        decorations = "none";
      };

      scrolling = {
        history = 5000;
        multiplier = 3;
      };

      font = {
        size = 11.0;

        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };

        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };

        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
      };

      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>";

        save_to_clipboard = true;
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        unfocused_hollow = true;
      };

    };
  };
}
