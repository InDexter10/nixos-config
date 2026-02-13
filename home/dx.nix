{
  pkgs,
  ...
}:

{
  imports = [
    ./global

    ./features/desktop/niri
    ./features/desktop/common

    ./features/pkgs/flatpakApps
    ./features/pkgs/gui
  ];

  home.username = "dx";
  home.homeDirectory = "/home/dx";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

}
