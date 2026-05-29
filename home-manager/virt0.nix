{ inputs, pkgs, ... }:

{
  imports = [
    ./cli
    ./wm
    ./flatpakApps
  ];

  home.username = "virt0";
  home.homeDirectory = "/home/virt0";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    download = "$HOME/Downloads";
    documents = "$HOME/Documents";
    pictures = "$HOME/Pictures";

    desktop = null;
    music = null;
    templates = null;
    publicShare = null;

    extraConfig = {
      XDG_MOVIES_DIR = "$HOME/Movies";
      XDG_BOOKS_DIR = "$HOME/Books";
    };
  };

}
