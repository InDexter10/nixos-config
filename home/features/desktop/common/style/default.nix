{
  pkgs,
  config,
  lib,
  ...
}:
let
  theme = import ./theme.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    theme.fonts.monospace.package
    theme.fonts.sansSerif.package
    theme.fonts.serif.package
    theme.fonts.emoji.package

    theme.theme.gtk.package
    theme.icons.package
    theme.cursor.package

    libsForQt5.qt5ct
    kdePackages.qt6ct

    qt5.qtwayland
    qt6.qtwayland

    adwaita-qt
    adwaita-qt6
  ];

  gtk = {
    enable = true;
    font = {
      name = theme.fonts.sansSerif.name;
      size = 11;
    };
    iconTheme = {
      package = theme.icons.package;
      name = theme.icons.name;
    };
    theme = {
      name = theme.theme.gtk.name;
      package = theme.theme.gtk.package;
    };
    cursorTheme = {
      package = theme.cursor.package;
      name = theme.cursor.name;
      size = theme.cursor.size;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = theme.cursor.name;
      icon-theme = theme.icons.name;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "adwaita-dark";
  };

  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    style=adwaita-dark
    icon_theme=${theme.icons.name}
    standard_dialogs=default

    [Fonts]
    general="${theme.fonts.sansSerif.name}",11,-1,5,50,0,0,0,0,0
    fixed="${theme.fonts.monospace.name}",11,-1,5,50,0,0,0,0,0

    [Interface]
    cursor_theme=${theme.cursor.name}
  '';

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    style=adwaita-dark
    icon_theme=${theme.icons.name}
    standard_dialogs=default

    [Fonts]
    general="${theme.fonts.sansSerif.name}",11,-1,5,50,0,0,0,0,0
    fixed="${theme.fonts.monospace.name}",11,-1,5,50,0,0,0,0,0

    [Interface]
    cursor_theme=${theme.cursor.name}
  '';

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";

    MOZ_ENABLE_WAYLAND = "1";
    GTK_THEME = "Adwaita-dark";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = theme.cursor.package;
    name = theme.cursor.name;
    size = theme.cursor.size;
  };
}
