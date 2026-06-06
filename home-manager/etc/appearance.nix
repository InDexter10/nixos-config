{ pkgs, ... }:

{
  # ---------------------------- GTK (GTK2/3/4) ----------------------------
  gtk = {
    enable = true;

    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };

    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };

    font = {
      name = "Arial";
      size = 10;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # ------------------------------ Qt (Qt5/Qt6) ----------------------------
  qt = {
    enable = true;

    style.name = "breeze";

    platformTheme.name = "gtk3";
  };

  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark

    [Icons]
    Theme=breeze-dark

    [KDE]
    widgetStyle=Breeze
  '';

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Materia-dark";
    icon-theme = "breeze-dark";
    cursor-theme = "Vanilla-DMZ";
  };
}
