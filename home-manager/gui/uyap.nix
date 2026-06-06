{
  pkgs,
  config,
  ...
}:

let
  uyapDir = ".config/uyap";

  ukiDir = ".uki";

  javaPkg = pkgs.temurin-bin-11;

  uyap-launcher = pkgs.writeShellScriptBin "uyap-editor" ''
    set -e

    # Bind kaynaklarının var olmasını garanti et (--bind eksik kaynakta patlar).
    mkdir -p "$HOME/${ukiDir}"
    mkdir -p "$HOME/${uyapDir}/UYAPEditor"
    mkdir -p "$HOME/.java"
    mkdir -p "$HOME/Documents"
    mkdir -p "$HOME/Downloads"

    # X11 yetkilendirme dosyası. labwc, XWayland üzerinden X11 soketi sağlar.
    XAUTH=''${XAUTHORITY:-$HOME/.Xauthority}
    if [ ! -f "$XAUTH" ]; then
      touch "$HOME/.Xauthority"
      XAUTH="$HOME/.Xauthority"
    fi

    exec ${pkgs.bubblewrap}/bin/bwrap \
      --ro-bind /nix/store /nix/store \
      --ro-bind /sys /sys \
      --ro-bind /etc/fonts /etc/fonts \
      --ro-bind-try /etc/static/fonts /etc/static/fonts \
      --ro-bind /etc/ssl/certs /etc/ssl/certs \
      --ro-bind-try /etc/static/ssl /etc/static/ssl \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --ro-bind /etc/passwd /etc/passwd \
      --ro-bind /etc/group /etc/group \
      --ro-bind-try /run/current-system/sw/share/X11/fonts /run/current-system/sw/share/X11/fonts \
      --ro-bind-try /run/current-system/sw/share/fonts /run/current-system/sw/share/fonts \
      --ro-bind-try /var/cache/fontconfig /var/cache/fontconfig \
      --ro-bind-try "$HOME/.nix-profile/share/fonts" "$HOME/.nix-profile/share/fonts" \
      --ro-bind-try "$HOME/.local/share/fonts" "$HOME/.local/share/fonts" \
      --dev /dev \
      --proc /proc \
      --tmpfs /tmp \
      --bind /tmp/.X11-unix /tmp/.X11-unix \
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
      --setenv _JAVA_OPTIONS "-Duser.language=tr -Duser.region=TR -Dawt.useSystemAAFontSettings=lcd -Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel -Dswing.crossplatformlaf=javax.swing.plaf.metal.MetalLookAndFeel" \
      ${javaPkg}/bin/java \
        -Xmx2048m \
        -Duser.home="${config.home.homeDirectory}" \
        -cp ".:*" \
        tr.com.havelsan.uyap.system.editor.common.WPAppManager \
        "getNewWPInstance" "EDITOR_TYPE_DOCUMENT" "$@"
  '';

  # --- Masaüstü kısayolu ---
  uyap-desktop = pkgs.makeDesktopItem {
    name = "uyap-editor";
    desktopName = "UYAP Doküman Editörü";
    exec = "${uyap-launcher}/bin/uyap-editor %F";
    icon = "uyap-editor";
    categories = [
      "Office"
      "WordProcessor"
    ];
    # Yalnız .udf; application/xml KASITLI olarak yok (tüm XML'lere
    # UYAP'ı eşlememek için).
    mimeTypes = [ "application/udf" ];
  };

  # --- MIME tipi tanımı (pure, store içinde) ---
  uyap-mime = pkgs.writeTextDir "share/mime/packages/udf.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/udf">
        <comment>UYAP Doküman Formatı</comment>
        <glob pattern="*.udf"/>
      </mime-type>
    </mime-info>
  '';
in
{
  home.packages = with pkgs; [
    uyap-launcher
    uyap-desktop
    uyap-mime
    shared-mime-info
  ];

  # Masaüstü girişinin ikonu (hicolor temasından "uyap-editor" adıyla çözülür).
  # Kaynak, .deb'den ~/.config/uyap/icons altına kopyalanan store-dışı ikondur.
  home.file.".local/share/icons/hicolor/128x128/apps/uyap-editor.png".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${uyapDir}/icons/hicolor/128x128/apps/uyap-editor.png";

}
