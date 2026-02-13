{ pkgs, ... }:

{

  imports = [
    ./utils.nix
    #./fuzzel.nix
    ./tofi.nix
  ];
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
