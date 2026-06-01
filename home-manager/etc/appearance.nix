# appearance.nix - sistem geneli gorunum: Breeze-Dark (GTK + Qt + ikon + imlec)
{ pkgs, ... }:

{
  # ---------------------------- GTK (GTK2/3/4) ----------------------------
  gtk = {
    enable = true;

    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };

    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };

    # UI fontu (Breeze/KDE varsayilani). Asil font paketi sistem katmaninda
    # kurulu olmali (asagidaki nota bak); burada sadece isimle referans veriyoruz.
    font = {
      name = "Arial";
      size = 10;
    };

    # GTK3 ve GTK4 uygulamalarini koyu varyanta yonlendir.
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # ------------------------------ Qt (Qt5/Qt6) ----------------------------
  qt = {
    enable = true;

    # Breeze widget stili. Paketi (kdePackages.breeze) modul otomatik ekler;
    # QT_STYLE_OVERRIDE=breeze ortam degiskenini de kendisi ayarlar.
    style.name = "breeze";

    # Qt'yi GTK ayarlarina baglar (koyu palet, font, dosya secici).
    # Ekstra paket CEKMEZ (gtk3 eklentisi qtbase ile gelir). KDE-disi Qt
    # uygulamalarinin ( or. VLC) koyu olmasini saglar.
    # Not: "kde" secersek guvenilir ama systemsettings + plasma-integration
    # ceker (bloat); o yuzden gtk3 tercih edildi.
    platformTheme.name = "gtk3";
  };

  # ----------------------------- Fare imleci ------------------------------
  # Tek opsiyon; GTK, XWayland (x11) ve Wayland (XCURSOR_*) icin birden ayarlar.
  home.pointerCursor = {
    name = "Vanilla-DMZ"; # beyaz DMZ (koyu zeminde daha gorunur). Siyah icin: "Vanilla-DMZ-AA"
    package = pkgs.vanilla-dmz;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ----------------- KDE/Qt uygulamalarinin koyu renk semasi --------------
  # Dolphin, Gwenview, Okular vb. rengi KColorScheme uzerinden kdeglobals'tan
  # okur. "BreezeDark" semasi kdePackages.breeze ile gelir.
  # Dosya deklaratif (salt-okunur) yazilir; bilincli olarak deterministiktir.
  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark

    [Icons]
    Theme=breeze-dark

    [KDE]
    widgetStyle=Breeze
  '';

  # --------- libadwaita/GTK4 ve modern uygulamalarin koyu moda gecisi -----
  # Bunlar ozel temayi yok sayar; "prefer-dark" tercihini okurlar.
  # (Sistemde programs.dconf.enable acik olmali.)
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Breeze-Dark";
    icon-theme = "breeze-dark";
    cursor-theme = "Vanilla-DMZ";
  };
}
