{ pkgs, ... }:

let
  tw-manager = pkgs.writeShellApplication {
    name = "tw-manager";
    runtimeInputs = with pkgs; [
      timewarrior
      uair
      jq
      libnotify
      rofi
    ];
    text = builtins.readFile ./tw-manager.sh;
  };

in

{

  home.packages = with pkgs; [
    waybar
    tw-manager
  ];

  xdg.configFile."waybar/config".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
  xdg.configFile."uair/uair.toml".source = ./uair.toml;

}
