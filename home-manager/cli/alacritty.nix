{ ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        opacity = .98;
        padding = {
          x = 8;
          y = 8;
        };
        dynamic_padding = true;
      };

      scrolling.history = 50000;

      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 11.0;
      };

      selection.save_to_clipboard = true;

      mouse.hide_when_typing = true;
    };
  };
}
