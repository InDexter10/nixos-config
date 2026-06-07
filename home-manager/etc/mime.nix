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

      "image/jpeg" = [ "org.kde.gwenview.desktop" ];
      "image/png" = [ "org.kde.gwenview.desktop" ];
      "image/webp" = [ "org.kdegwenview.desktop" ];
      "image/gif" = [ "org.kdegwenview.desktop" ];
      "image/bmp" = [ "org.kde.gwenview.desktop" ];
      "image/svg+xml" = [ "org.kde.gwenview.desktop" ];
      "image/tiff" = [ "org.kde.okular.desktop" ];

      "application/pdf" = [ "org.kde.okular.desktop" ];
      "application/epub+zip" = [ "org.kde.okular.desktop" ];

      "application/x-udf" = [ "uyap-editor.desktop" ];
      "application/udf" = [ "uyap-editor.desktop" ];

      "video/mp4" = [ "vlc.desktop" ];
      "video/x-matroska" = [ "vlc.desktop" ];
      "video/webm" = [ "vlc.desktop" ];
      "video/avi" = [ "vlc.desktop" ];
      "video/quicktime" = [ "vlc.desktop" ];
      "audio/mpeg" = [ "vlc.desktop" ];

      "application/zip" = [ "xarchiver.desktop" ];
      "application/x-rar" = [ "xarchiver.desktop" ];
      "application/x-7z-compressed" = [ "xarchiver.desktop" ];
      "application/x-tar" = [ "xarchiver.desktop" ];
      "application/gzip" = [ "xarchiver.desktop" ];

      "text/html" = [ "firefox.desktop" ];
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
