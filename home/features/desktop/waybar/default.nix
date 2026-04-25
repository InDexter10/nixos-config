{ pkgs, ... }:

let
  tw = pkgs.writeShellApplication {
    name = "tw";
    runtimeInputs = with pkgs; [
      timewarrior
      libnotify # notify-send
      pulseaudio # paplay
      procps # pkill
      coreutils # date, sleep, mkdir, touch, cat, head, sed
    ];
    text = builtins.readFile ./tw;
  };
in
{
  home.packages = [
    pkgs.waybar
    tw
  ];

  xdg.configFile."waybar/config".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
  # waybar/tw artık gerekmiyor — pakete dönüştü
}
