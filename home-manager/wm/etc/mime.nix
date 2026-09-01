{ pkgs, ... }:

# Yalnizca KURULU uygulamalara isaret eder; hedefi olmayan bir girdi "ac"
# eylemini sessizce basarisiz kilar. Uygulama listesi gui/flatpakapps.nix
# (Flatpak) ve gui/uyap.nix icinde - biri oradan cikarsa buradaki karsiligi
# da dusmeli.

{
  home.packages = with pkgs; [
    xdg-utils
    handlr-regex
  ];
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {

      "image/jpeg" = [ "org.kde.gwenview.desktop" ];
      "image/png" = [ "org.kde.gwenview.desktop" ];
      "image/webp" = [ "org.kde.gwenview.desktop" ];
      "image/gif" = [ "org.kde.gwenview.desktop" ];
      "image/bmp" = [ "org.kde.gwenview.desktop" ];
      "image/svg+xml" = [ "org.kde.gwenview.desktop" ];
      "image/tiff" = [ "org.kde.okular.desktop" ];

      "application/pdf" = [ "org.kde.okular.desktop" ];
      "application/epub+zip" = [ "org.kde.okular.desktop" ];

      # Tur adini gui/uyap.nix'teki uyap-mime tanimlar; baska ad uretilmiyor.
      "application/udf" = [ "uyap-editor.desktop" ];

      "video/mp4" = [ "org.videolan.VLC.desktop" ];
      "video/x-matroska" = [ "org.videolan.VLC.desktop" ];
      "video/webm" = [ "org.videolan.VLC.desktop" ];
      "video/avi" = [ "org.videolan.VLC.desktop" ];
      "video/quicktime" = [ "org.videolan.VLC.desktop" ];
      "audio/mpeg" = [ "org.videolan.VLC.desktop" ];

      # Flatpak Firefox yalnizca "org.mozilla.firefox.desktop" uretir;
      # sade "firefox.desktop" bu sistemde hicbir seye karsilik gelmez.
      "text/html" = [ "org.mozilla.firefox.desktop" ];
      "x-scheme-handler/http" = [ "org.mozilla.firefox.desktop" ];
      "x-scheme-handler/https" = [ "org.mozilla.firefox.desktop" ];
      "x-scheme-handler/about" = [ "org.mozilla.firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "org.mozilla.firefox.desktop" ];
    };
  };
}
