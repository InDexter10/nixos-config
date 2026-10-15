{ config, ... }:

{
  imports = [
    ./desktop
    ./labwc
    ./packages
    ./terminal
  ];

  home.username = "dex";
  home.homeDirectory = "/home/dex";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  xdg.configFile."home-manager".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixconf";
}
