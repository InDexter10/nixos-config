{ pkgs, ... }:

{
  home.packages = with pkgs; [ xdg-utils ];

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {

      "image/jpeg" = [ "org.xfce.ristretto" ];
      "image/png" = [ "org.xfce.ristretto" ];
      "image/webp" = [ "org.xfce.ristretto" ];
      "image/gif" = [ "org.xfce.ristretto" ];
      "image/bmp" = [ "org.xfce.ristretto" ];
      "image/svg+xml" = [ "org.xfce.ristretto" ];
      "image/tiff" = [ "org.xfce.ristretto" ];

      "application/pdf" = [ "org.kde.okular.desktop" ];
      "application/epub+zip" = [ "org.kde.okular.desktop" ];

      "application/x-udf" = [ "uyap-editor" ];

      "video/mp4" = [ "org.videolan.VLC" ];
      "video/x-matroska" = [ "org.videolan.VLC" ];
      "video/webm" = [ "org.videolan.VLC" ];
      "video/avi" = [ "org.videolan.VLC" ];
      "video/quicktime" = [ "org.videolan.VLC" ];
      "audio/mpeg" = [ "org.videolan.VLC" ];

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
