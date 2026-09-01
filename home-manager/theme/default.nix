{ ... }:

# Masaustu gorunumu. cli/, gui/ ve wm/ ile ayni duzeyde durur cunku ucunu de
# etkiler.
#   palette.nix  tek kaynak: renkler, tipografi, imlec, tema kimlikleri
#   gtk.nix      GTK2/3/4 + ikon + imlec + dconf  (belirleyici olan bu)
#   qt.nix       kdeglobals; Qt/KDE (pratikte Flatpak) GTK'ya ayak uydurur
#
# labwc, waybar, rofi, mako ve swaylock da palette.nix'ten beslenir.
# Fontlarin KURULUMU system/modules/fonts.nix icinde.
{
  imports = [
    ./gtk.nix
    ./qt.nix
  ];
}
