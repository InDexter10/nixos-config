{ ... }:

{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    download = "$HOME/Downloads";
    documents = "$HOME/Documents";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Movies";

    desktop = null;
    music = null;
    templates = null;
    publicShare = null;
    projects = null;

    # Anahtar BOOKS -> XDG_BOOKS_DIR; on/son ek modul tarafindan eklenir.
    extraConfig.BOOKS = "$HOME/Books";
  };
}
