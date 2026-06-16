{
  pkgs,
  lib,
  config,
  ...
}:

let
  mkSandboxedApp = import ../lib/sandboxing.nix { inherit pkgs lib config; };
  home = config.home.homeDirectory;
  okularPkg = pkgs.kdePackages.okular; # KF6 (26.05). KF5'te ise pkgs.okular.
in
{
  home.packages = [
    (mkSandboxedApp {
      name = "okular";
      package = okularPkg;
      desktopName = "Okular";
      genericName = "PDF Wiever";
      icon = "okular";
      startupWMClass = "okular";
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

      exec = "${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon -- ${okularPkg}/bin/okular";

      rwDirs = [
        "${home}/Downloads"
        "${home}/Documents"
        "${home}/Books"
      ];

      extraEnv = {
        QT_QPA_PLATFORM = "wayland";
      };

      extraArgs = [
        "--ro-bind-try /etc/dbus-1 /etc/dbus-1"
      ];
    })
  ];
}
