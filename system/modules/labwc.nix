{ pkgs, ... }:

{
  # programs.labwc modulu xdg.portal.enable, xdg.portal.extraPortals (gtk) ve
  # programs.dconf.enable'i zaten kendisi yapiyor.
  #
  # Paket unstable'dan: stable 26.05'te labwc 0.9.7, unstable'da 0.20.2.
  # Buradaki rc.xml 0.20 ozelliklerini kullaniyor. Bedeli, closure'da ikinci
  # bir nixpkgs agacindan gelen wlroots/mesa ve labwc'nin stable'in backport
  # akisinda olmamasi - guvenlik guncellemesi flake update ile gelir.
  programs.labwc = {
    enable = true;
    package = pkgs.unstable.labwc;
  };

  xdg.portal = {
    # Ekran goruntusu ve ekran paylasimi yalnizca wlr portalinden gelir;
    # gtk portali bunlari yapamaz ama dosya seciciyi o saglar.
    #
    # XDG_CURRENT_DESKTOP=labwc:wlroots oldugu icin bu dosya "wlroots"
    # olanindan ONCE eslesir; eskiden burada [ "gtk" ] yaziyordu ve
    # xdg-desktop-portal wlr'a ancak kullanimdan kaldirilmis "UseIn"
    # anahtariyla dusuyordu. Sira onemli: once wlr, olmayan arayuzler icin gtk.
    config.labwc.default = [
      "wlr"
      "gtk"
    ];
  };

  environment.sessionVariables = {
    # Su an tum GUI uygulamalari Flatpak oldugu icin fiilen etkisiz; ileride
    # native bir uygulama eklenirse XWayland'e dusmesini onler.
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
}
