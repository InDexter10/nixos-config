{
  pkgs,
  config,
  lib,
  ...
}:

let
  uyapDir = ".config/uyap";
  ukiDir = ".uki";
  mimeXmlPath = "${config.home.homeDirectory}/${uyapDir}/mime/packages/udf.xml";
  javaPkg = pkgs.temurin-bin-11;

  # Başlatıcı Script
  uyap-launcher = pkgs.writeShellScriptBin "uyap-editor" ''
    # 1. Klasör Kontrolleri
    mkdir -p "$HOME/${ukiDir}"
    mkdir -p "$HOME/${uyapDir}/UYAPEditor"
    mkdir -p "$HOME/.java" # YENİ: Java'nın kendi sertifika ve ayar deposu

    # 2. XAuthority Tespiti
    XAUTH=''${XAUTHORITY:-$HOME/.Xauthority}
    if [ ! -f "$XAUTH" ]; then
        touch "$HOME/.Xauthority"
        XAUTH="$HOME/.Xauthority"
    fi

    # 3. Font Yollarını Dinamik Belirle
    EXTRA_BINDS=""
    if [ -d "$HOME/.nix-profile" ]; then
        EXTRA_BINDS="$EXTRA_BINDS --ro-bind $HOME/.nix-profile $HOME/.nix-profile"
    fi
    if [ -d "$HOME/.local/share/fonts" ]; then
        EXTRA_BINDS="$EXTRA_BINDS --ro-bind $HOME/.local/share/fonts $HOME/.local/share/fonts"
    fi
    if [ -d "/run/current-system/sw/share/X11/fonts" ]; then
        EXTRA_BINDS="$EXTRA_BINDS --ro-bind /run/current-system/sw/share/X11/fonts /run/current-system/sw/share/X11/fonts"
    fi

    # 4. Fortress Sandbox (İmza Modülü İçin Delindi)
    exec ${pkgs.bubblewrap}/bin/bwrap \
      --ro-bind /nix/store /nix/store \
      --ro-bind /sys /sys \
      --ro-bind /etc/fonts /etc/fonts \
      --ro-bind /etc/static/fonts /etc/static/fonts \
      --ro-bind /etc/ssl/certs /etc/ssl/certs \
      --ro-bind-try /etc/ca-certificates /etc/ca-certificates \
      --ro-bind-try /etc/pki /etc/pki \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --ro-bind /etc/passwd /etc/passwd \
      --ro-bind /etc/group /etc/group \
      $EXTRA_BINDS \
      --dev /dev \
      --proc /proc \
      --tmpfs /tmp \
      --bind /tmp/.X11-unix /tmp/.X11-unix \
      --bind-try /run/pcscd /run/pcscd \
      --bind "$XAUTH" "$XAUTH" \
      --bind "$HOME/.java" "$HOME/.java" \
      --bind "${config.home.homeDirectory}/${uyapDir}" "${config.home.homeDirectory}/${uyapDir}" \
      --bind "${config.home.homeDirectory}/${ukiDir}" "${config.home.homeDirectory}/${ukiDir}" \
      --bind "${config.home.homeDirectory}/Documents" "${config.home.homeDirectory}/Documents" \
      --bind "${config.home.homeDirectory}/Downloads" "${config.home.homeDirectory}/Downloads" \
      --chdir "${config.home.homeDirectory}/${uyapDir}/UYAPEditor" \
      --die-with-parent \
      --new-session \
      --unshare-all \
      --share-net \
      --setenv HOME "${config.home.homeDirectory}" \
      --setenv USER "${config.home.username}" \
      --setenv DISPLAY "$DISPLAY" \
      --setenv XAUTHORITY "$XAUTH" \
      --setenv LC_ALL "tr_TR.UTF-8" \
      --setenv LANG "tr_TR.UTF-8" \
      --setenv _JAVA_AWT_WM_NONREPARENTING "1" \
      --setenv AWT_TOOLKIT "XToolkit" \
      --setenv _JAVA_OPTIONS "-Duser.language=tr -Duser.region=TR -Dawt.useSystemAAFontSettings=lcd -Dsun.java2d.uiScale=1.0 -Dsun.java2d.xrender=true" \
      ${javaPkg}/bin/java \
        -Xmx2048m \
        -Duser.home="${config.home.homeDirectory}" \
        -cp ".:*" \
        tr.com.havelsan.uyap.system.editor.common.WPAppManager \
        "getNewWPInstance" "EDITOR_TYPE_DOCUMENT" "$@"
  '';
  # Desktop Kısayolu
  uyap-desktop = pkgs.makeDesktopItem {
    name = "uyap-editor";
    desktopName = "UYAP Doküman Editörü";
    exec = "${uyap-launcher}/bin/uyap-editor %F";
    icon = "uyap-editor";
    categories = [
      "Office"
      "WordProcessor"
    ];
    mimeTypes = [
      "application/udf"
      "application/xml"
    ];
  };

in
{
  home.packages = with pkgs; [
    uyap-launcher
    uyap-desktop
    shared-mime-info
    corefonts
  ];

  home.file.".local/share/icons/hicolor/128x128/apps/uyap-editor.png".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${uyapDir}/icons/hicolor/128x128/apps/uyap-editor.png";

  home.file.".local/share/mime/packages/udf.xml".source =
    config.lib.file.mkOutOfStoreSymlink mimeXmlPath;

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "application/udf" = [ "uyap-editor.desktop" ];
  };
}
