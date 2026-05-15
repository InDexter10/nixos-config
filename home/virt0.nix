{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./global

    ./features/desktop/labwc
    ./features/desktop/waybar
    ./features/desktop/focus
    ./features/desktop/style

    ./features/pkgs/gui
    ./features/pkgs/gui/uyap
    ./features/pkgs/gui/keepass

    ./features/pkgs/flatpakApps

  ];

  home.username = "dx0";
  home.homeDirectory = "/home/dx0";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

}
