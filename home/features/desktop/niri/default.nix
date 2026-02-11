{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    ./fuzzel.nix
  ];
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
