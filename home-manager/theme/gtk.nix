{ pkgs, ... }:

let
  p = import ./palette.nix;

  # GTK3 (adw-gtk3 uzerinden) ve GTK4 (libadwaita) ayni degisken adlarini
  # kullanir, bu yuzden tek blok her ikisini de boyar.
  colorOverrides = ''
    @define-color window_bg_color ${p.bg};
    @define-color window_fg_color ${p.fg};

    @define-color view_bg_color ${p.base};
    @define-color view_fg_color ${p.fg};

    @define-color headerbar_bg_color ${p.elevated};
    @define-color headerbar_fg_color ${p.fg};
    @define-color headerbar_border_color ${p.border};
    @define-color headerbar_backdrop_color ${p.bg};

    @define-color sidebar_bg_color ${p.elevated};
    @define-color sidebar_fg_color ${p.fg};
    @define-color sidebar_border_color ${p.border};
    @define-color sidebar_backdrop_color ${p.bg};

    @define-color card_bg_color ${p.elevated};
    @define-color card_fg_color ${p.fg};

    @define-color popover_bg_color ${p.elevated};
    @define-color popover_fg_color ${p.fg};

    @define-color dialog_bg_color ${p.elevated};
    @define-color dialog_fg_color ${p.fg};

    @define-color accent_bg_color ${p.accent};
    @define-color accent_fg_color ${p.accentFg};
    @define-color accent_color ${p.accent};

    @define-color destructive_bg_color ${p.urgent};
    @define-color destructive_color ${p.urgent};
    @define-color warning_bg_color ${p.warn};
    @define-color warning_color ${p.warn};
    @define-color success_bg_color ${p.ok};
    @define-color success_color ${p.ok};
    @define-color error_bg_color ${p.urgent};
    @define-color error_color ${p.urgent};

    @define-color borders ${p.border};

    /* GTK3 eski isimler - bazi uygulamalar hala bunlari sorar. */
    @define-color theme_bg_color ${p.bg};
    @define-color theme_fg_color ${p.fg};
    @define-color theme_base_color ${p.base};
    @define-color theme_text_color ${p.fg};
    @define-color theme_selected_bg_color ${p.accent};
    @define-color theme_selected_fg_color ${p.accentFg};
    @define-color insensitive_fg_color ${p.fgDim};
  '';
in
{
  gtk = {
    enable = true;
    colorScheme = "dark";

    font = {
      name = p.fontUI;
      size = p.fontUISize;
    };

    theme = {
      name = p.gtkTheme;
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = p.iconTheme;
      package = pkgs.kdePackages.breeze-icons;
    };

    cursorTheme = {
      name = p.cursorName;
      package = pkgs.vanilla-dmz;
      size = p.cursorSize;
    };

    # DIKKAT: bu iki dosya gui/flatpakapps.nix tarafindan sandbox'a DOSYA
    # olarak baglaniyor. Uretilmeyi birakirlarsa oradaki izin satirlari da
    # guncellenmeli, yoksa flatpak hata verir.
    gtk3.extraCss = colorOverrides;
    gtk4.extraCss = colorOverrides;
  };

  # Imlecin GTK disinda da (labwc, XWayland) gecerli olmasi icin.
  home.pointerCursor = {
    name = p.cursorName;
    package = pkgs.vanilla-dmz;
    size = p.cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  # Flatpak uygulamalari host GTK ayarlarini xdg-desktop-portal uzerinden
  # bu yoldan gorur.
  #
  # Metin CIZIM ayarlari (antialias, hinting, alt-piksel) bilerek burada YOK:
  # GTK bunlari fontconfig'ten okur, ikinci bir kaynak zamanla ayrisirdi.
  # Tek kaynak: system/modules/fonts.nix.
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = p.gtkTheme;
    icon-theme = p.iconTheme;
    cursor-theme = p.cursorName;
    cursor-size = p.cursorSize;
    font-name = "${p.fontUI} ${toString p.fontUISize}";
    monospace-font-name = "${p.fontMono} ${toString p.fontUISize}";
    document-font-name = "Noto Sans ${toString p.fontUISize}";
  };
}
