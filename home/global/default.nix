{ inputs, pkgs, ... }:

{
  imports = [
    ../features/pkgs/cli
    ../features/pkgs/tui

  ];

  xdg.userDirs = {
    enable = true;
    createDirectories = true; # Klasör yoksa Nix oluşturur, varsa dokunmaz.

    # Aktif kullanmak istediklerin
    download = "$HOME/Downloads";
    ##videos   = "$HOME/Downloads/Torrents"; # Özel path tanımın
    documents = "$HOME/Documents"; # 's' takısına dikkat
    pictures = "$HOME/Pictures";

    # "Sistemimde kuş uçmasın" dediklerin (null)
    desktop = null;
    music = null;
    templates = null;
    publicShare = null;

    # Eğer buraya girmeyen ekstra bir klasörün varsa (Örn: Projeler)
    extraConfig = {
      XDG_MOVIES_DIR = "$HOME/Movies";
      XDG_BOOKS_DIR = "$HOME/Books";
    };
  };

}
