# Renk ve tipografi icin TEK KAYNAK. Buradaki bir degeri degistirmek GTK,
# Qt, rofi, mako ve kilit ekranini birlikte degistirir.
#
# labwc HARIC: rc.xml, themerc-override ve autostart duz dosya oldugu icin
# nix degeri goremezler; oradaki karsiliklar ELLE guncellenir.
# Kapsam disi (kendi temalari var): alacritty, yazi, helix.
#
# Duz veri dosyasi, home-manager modulu DEGIL:
#   let p = import ../theme/palette.nix; in ...

rec {
  # Notr grafit tonlari; en koyu yuzey bile %17 aciklikta, yani ekran
  # "kapali" degil "gri" okunuyor.
  base = "#2b2d2e"; # liste, metin alani, giris kutusu
  bg = "#37393a"; # ana pencere arka plani
  elevated = "#414446"; # baslik cubugu, panel, kart, menu
  hover = "#4a4d4f";
  border = "#55585a";

  fg = "#e6e8e8";
  fgDim = "#a6abac";

  accent = "#4d9ee0";
  accentFg = "#0f1112"; # vurgu uzerindeki metin
  urgent = "#e05252";
  warn = "#e0a030";
  ok = "#4caf76";

  # Arayuz fontu ile belge fontu farkli seylerdir; ayrimin tamami
  # system/modules/fonts.nix icinde.
  fontUI = "Inter";
  fontUISize = 10;
  fontMono = "JetBrains Mono"; # ikonSUZ surum

  # YALNIZCA glyph kapsami icin, font yiginda ikinci sirada. Panelin
  # ag/ses/parlaklik ikonlari Nerd Font'un ozel kullanim alanindadir ve
  # hicbir normal fontta bulunmaz; harf ve rakamlar yine Inter ile cizilir.
  fontIcon = "JetBrainsMono Nerd Font";

  cursorName = "Vanilla-DMZ";
  cursorSize = 24;

  # Ev dizinine gore GORELI. YALNIZCA swaylock buradan okur; swaybg'nin yolu
  # wm/labwc/config/autostart icinde duz yazili ve ELLE eslenir.
  wallpaperFile = "Pictures/aa.jpg";

  # adw-gtk3: GTK3 ile GTK4 AYNI renk degisken adlarini kullanir
  # (window_bg_color, accent_color...), bu yuzden tek override bloku her
  # ikisini de boyar.
  gtkTheme = "adw-gtk3-dark";

  # breeze-dark, KDE calisma zamaninin (org.kde.Platform) ICINDE hazir
  # bulunan tek tema. Papirus-Dark host'ta kaliyordu ama Flatpak sandbox'i
  # /nix/store'u goremedigi icin okular onu bulamayip ACIK "breeze"e
  # dusuyordu - koyu zeminde koyu ikonlar. Gorsel kayip yok: Papirus zaten
  # "Inherits=breeze-dark" der.
  iconTheme = "breeze-dark";

  # KDE renk semalari ondalik "R,G,B" ister; ikinci bir renk listesi
  # tutmamak icin hex'ten turetiliyor. hex KUCUK harf olmali.
  toRgb =
    hex:
    let
      d =
        c:
        {
          "0" = 0;
          "1" = 1;
          "2" = 2;
          "3" = 3;
          "4" = 4;
          "5" = 5;
          "6" = 6;
          "7" = 7;
          "8" = 8;
          "9" = 9;
          "a" = 10;
          "b" = 11;
          "c" = 12;
          "d" = 13;
          "e" = 14;
          "f" = 15;
        }
        .${c};
      pair = i: (d (builtins.substring i 1 hex)) * 16 + (d (builtins.substring (i + 1) 1 hex));
    in
    "${toString (pair 1)},${toString (pair 3)},${toString (pair 5)}";
}
