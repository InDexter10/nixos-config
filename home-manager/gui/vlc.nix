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
      name = "vlc";
      package = pkgs.vlc;
      desktopName = "VLC";
      genericName = "Medya Oynatıcı";
      icon = "vlc";
      startupWMClass = "vlc";
      categories = [
        "AudioVideo"
        "Player"
        "Video"
        "Audio"
      ];
      mimeTypes = [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/mpeg"
        "video/x-msvideo"
        "audio/mpeg"
        "audio/flac"
        "audio/x-wav"
        "audio/ogg"
      ];

      # VLC 3.x (Qt5) native Wayland'da kararsız → XWayland (xcb) deterministik
      # yol. Daha az soket istersen display="wayland" + QT_QPA_PLATFORM="wayland"
      # deneyebilirsin; VA-API zaten display sunucusundan bağımsız çalışır.
      display = "x11";
      net = false; # yalnız yerel oynatma — medya ayrıştırıcı dışarı bağlanamaz
      gpu = true; # Intel UHD 600 → iHD VA-API donanım kod çözme
      audio = true; # PipeWire/Pulse
      isolatedConfig = true;

      # Tek yazılabilir-olmayan dosya yüzeyi: oynatma için salt-okunur yeterli.
      roDirs = [ "${home}/Movies" ];

      extraEnv = {
        QT_QPA_PLATFORM = "xcb";
      };
    })
  ];
}
