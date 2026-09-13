rec {
  base = "#3c3836";
  bg = "#45403d";
  elevated = "#504945";
  hover = "#5a524c";
  border = "#665c54";

  fg = "#e6d2b0";
  fgDim = "#c7b899";

  accent = "#9ac5ba";
  accentFg = "#282828";

  focus = "#ecbd6d";
  focusCycle = "#de2910";

  urgent = "#ed7d78";
  warn = "#d8a657";
  ok = "#a9b665";

  fontUI = "Inter";
  fontUISize = 10;
  fontMono = "JetBrains Mono";

  fontIcon = "JetBrainsMono Nerd Font";

  cursorName = "Vanilla-DMZ";
  cursorSize = 24;

  wallpaperFile = "Pictures/aa.jpg";

  gtkTheme = "adw-gtk3-dark";

  iconTheme = "breeze-dark";

  toRgb =
    hex:
    let
      d =
        c:
        {
          "0" = 0;
          "1" = 1;
          "2" = 2;
          "3" = 3;
          "4" = 4;
          "5" = 5;
          "6" = 6;
          "7" = 7;
          "8" = 8;
          "9" = 9;
          "a" = 10;
          "b" = 11;
          "c" = 12;
          "d" = 13;
          "e" = 14;
          "f" = 15;
        }
        .${c};
      pair = i: (d (builtins.substring i 1 hex)) * 16 + (d (builtins.substring (i + 1) 1 hex));
    in
    "${toString (pair 1)},${toString (pair 3)},${toString (pair 5)}";
}
