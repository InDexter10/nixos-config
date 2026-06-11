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

      "image/jpeg" = [ "gwenview.desktop" ];
      "image/png" = [ "gwenview.desktop" ];
      "image/webp" = [ "gwenview.desktop" ];
      "image/gif" = [ "gwenview.desktop" ];
      "image/bmp" = [ "gwenview.desktop" ];
      "image/svg+xml" = [ "gwenview.desktop" ];
      "image/tiff" = [ "okular.desktop" ];

      "application/pdf" = [ "okular.desktop" ];
      "application/epub+zip" = [ ".okular.desktop" ];

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

  };
}
