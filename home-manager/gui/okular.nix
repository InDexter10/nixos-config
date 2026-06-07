{
  pkgs,
  lib,
  config,
  ...
}:

let
  mkSandboxedApp = import ../lib/mk-sandboxed-app.nix { inherit pkgs lib config; };
  home = config.home.homeDirectory;
in
{
  home.packages = [
    (mkSandboxedApp {
      name = "okular";
      package = pkgs.kdePackages.okular; # KF6 (26.05). KF5'te ise pkgs.okular.
      desktopName = "Okular";
      genericName = "Belge Görüntüleyici";
      icon = "okular";
      startupWMClass = "org.kde.okular";
      categories = [
        "Office"
        "Viewer"
        "Graphics"
      ];
      mimeTypes = [
        "application/pdf"
        "application/epub+zip"
        "application/x-cbz"
        "application/x-cbr"
        "image/vnd.djvu"
        "application/postscript"
        "application/oxps"
      ];

      display = "wayland"; # Qt6 → native Wayland (X11 soketi yok, daha izole)
      net = false; # PDF içi uzak kaynak/izleme pikseli çağrılamaz (mahremiyet)
      gpu = false;
      isolatedConfig = true;

      # Native dosya seçici bu üç klasörde gezinebilir; başka hiçbir yeri görmez.
      # rw: Okular PDF üzerine not/annotation kaydeder.
      rwDirs = [
        "${home}/Downloads"
        "${home}/Documents"
        "${home}/Books"
        "${home}/Pictures"

      ];

      extraEnv = {
        QT_QPA_PLATFORM = "wayland";
      };
    })
  ];
}
