{ pkgs, ... }:

{
  home.packages = with pkgs; [ xdg-utils ];

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {

      "image/jpeg" = [ "org.kde.gwenview.desktop" ];
      "image/png" = [ "org.kde.gwenview.desktop" ];
      "image/webp" = [ "org.kde.gwenview.desktop" ];
      "image/gif" = [ "org.kde.gwenview.desktop" ];
      "image/bmp" = [ "org.kde.gwenview.desktop" ];
      "image/svg+xml" = [ "org.kde.gwenview.desktop" ];
      "image/tiff" = [ "org.kde.gwenview.desktop" ];

      "application/pdf" = [ "org.kde.okular.desktop" ];
      "application/epub+zip" = [ "org.kde.okular.desktop" ];

      "video/mp4" = [ "org.videolan.VLC.desktop" ];
      "video/x-matroska" = [ "org.videolan.VLC.desktop" ]; # .mkv
      "video/webm" = [ "org.videolan.VLC.desktop" ];
      "video/avi" = [ "org.videolan.VLC.desktop" ];
      "video/quicktime" = [ "org.videolan.VLC.desktop" ]; # .mov
      "audio/mpeg" = [ "org.videolan.VLC.desktop" ]; # .mp3 (İstersen)

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
