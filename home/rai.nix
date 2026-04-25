{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./global

    ./features/desktop/labwc
    ./features/desktop/common

    ./features/pkgs/gui
    ./features/pkgs/gui/uyap
    ./features/pkgs/gui/keepass

    ./features/pkgs/flatpakApps

  ];

  home.username = "rai";
  home.homeDirectory = "/home/rai";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

}
