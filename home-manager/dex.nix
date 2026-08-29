{ config, ... }:

{
  imports = [
    ./cli
    ./gui
    ./wm

  ];

  home.username = "dex";
  home.homeDirectory = "/home/dex";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # home-manager CLI konfigi sabit olarak ~/.config/home-manager altinda arar.
  # Bu symlink sayesinde `--flake` vermeden sadece `home-manager switch` yeter.
  xdg.configFile."home-manager".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixconf";

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
    projects = null;

    extraConfig = {
      XDG_BOOKS_DIR = "$HOME/Books";
      XDG_Movies_DIR = "$HOME/Movies";

    };
  };

}
