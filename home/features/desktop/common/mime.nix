{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    handlr-regex
  ];
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {

      "image/jpeg" = [ "org.xfce.ristretto.desktop" ];
      "image/png" = [ "org.xfce.ristretto.desktop" ];
      "image/webp" = [ "org.xfce.ristretto.desktop" ];
      "image/gif" = [ "org.xfce.ristretto.desktop" ];
      "image/bmp" = [ "org.xfce.ristretto.desktop" ];
      "image/svg+xml" = [ "org.xfce.ristretto" ];
      "image/tiff" = [ "org.xfce.ristretto.desktop" ];

      "application/pdf" = [ "org.kde.okular.desktop" ];
      "application/epub+zip" = [ "org.kde.okular.desktop" ];

      "application/x-udf" = [ "uyap-editor.desktop" ];
      "application/udf" = [ "uyap-editor.desktop" ];

      "video/mp4" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/x-matroska" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/webm" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/avi" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "video/quicktime" = [ "io.github.celluloid_player.Celluloid.desktop" ];
      "audio/mpeg" = [ "io.github.celluloid_player.Celluloid.desktop" ];

      "application/zip" = [ "xarchiver.desktop" ];
      "application/x-rar" = [ "xarchiver.desktop" ];
      "application/x-7z-compressed" = [ "xarchiver.desktop" ];
      "application/x-tar" = [ "xarchiver.desktop" ];
      "application/gzip" = [ "xarchiver.desktop" ];

      "text/html" = [ "com.brave.Browser.desktop" ];
      "x-scheme-handler/http" = [ "com.brave.Browser.desktop" ];
      "x-scheme-handler/https" = [ "com.brave.Browser.desktop" ];
      "x-scheme-handler/about" = [ "com.brave.Browser.desktop" ];
      "x-scheme-handler/unknown" = [ "com.brave.Browser.desktop" ];
    };

    associations.added = {
      "application/pdf" = [ "com.github.jeromerobert.pdfarranger.desktop" ];
    };
  };
}
