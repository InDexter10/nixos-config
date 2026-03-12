{ inputs, pkgs, ... }:

{
  imports = [
    ../features/pkgs/cli
    ../features/pkgs/tui
    ./mime.nix

  ];

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
