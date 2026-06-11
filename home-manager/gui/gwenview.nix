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
      name = "gwenview";
      package = pkgs.kdePackages.gwenview; # KF6 (26.05). KF5'te ise pkgs.gwenview.
      desktopName = "Gwenview";
      genericName = "Görüntü Görüntüleyici";
      icon = "gwenview";
      startupWMClass = "gwenview";
      categories = [
        "Graphics"
        "Viewer"
        "Photography"
      ];
      mimeTypes = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/tiff"
        "image/bmp"
        "image/svg+xml"
        "image/x-xcf"
      ];

      display = "wayland"; # Qt6 → native Wayland (X11 soketi yok, daha izole)
      net = false; # görüntü çözücü dışarı bağlanamaz
      gpu = false;
      isolatedConfig = true;

      # Native dosya seçici bu üç klasörde gezinebilir; başka hiçbir yeri görmez.
      # rw: Gwenview döndürme/silme/kaydetme yapar.
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
