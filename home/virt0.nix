{
  pkgs,
  ...
}:

{
  imports = [
    ./global

    ./features/desktop/niri
    ./features/desktop/common

    ./features/pkgs/gui
    #./features/pkgs/gui/uyap.nix

    ./features/pkgs/flatpakApps

  ];

  home.username = "virt0";
  home.homeDirectory = "/home/virt0";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

}
