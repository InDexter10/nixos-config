{ ... }:

# Sistemde YEREL Qt uygulamasi yok; Qt yalnizca Flatpak icinde (okular,
# gwenview, VLC). Flatpak Qt host'un eklentilerini goremez, tek koprusu
# izin listesinde acikca verilen "xdg-config/kdeglobals:ro" dosyasidir.
# Yani bu dosyanin tek isi kdeglobals'i dogru yazmak.
#
# Host tarafinda HICBIR Qt ortam degiskeni ihrac EDILMEZ (wm/labwc/config/environment):
# QT_QPA_PLATFORMTHEME/QT_STYLE_OVERRIDE Flatpak'in icine siziyor ve
# okular/gwenview'in KDE platform temasini yuklemesini engelleyerek asagidaki
# semayi tamamen devre disi birakiyorlardi. Degisken artik yalnizca Flatpak
# tarafinda, global override blogunda veriliyor (gui/flatpakapps.nix).
#
# Yerel bir Qt uygulamasi eklenirse: kdePackages.breeze kurup
# QT_QPA_PLATFORMTHEME=kde vermek yeterli, ayni dosyayi o da okur.

let
  p = import ./palette.nix;
  c = p.toRgb;

  # 10 alanli ESKI bicim: hem Qt5 (VLC'nin 5.15 calisma zamani) hem Qt6
  # ayristirir. Plasma 6'nin yazdigi 17 alanli bicimi Qt5 ayristiramaz.
  qtFont = family: size: "${family},${toString size},-1,5,50,0,0,0,0,0";
in
{
  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=NixTheme
    Name=NixTheme
    shadeSortColumn=true

    font=${qtFont p.fontUI p.fontUISize}
    menuFont=${qtFont p.fontUI p.fontUISize}
    toolBarFont=${qtFont p.fontUI p.fontUISize}
    smallestReadableFont=${qtFont p.fontUI (p.fontUISize - 2)}
    fixed=${qtFont p.fontMono p.fontUISize}

    [Icons]
    Theme=${p.iconTheme}

    [KDE]
    widgetStyle=Breeze

    [Colors:Window]
    BackgroundNormal=${c p.bg}
    BackgroundAlternate=${c p.elevated}
    ForegroundNormal=${c p.fg}
    ForegroundInactive=${c p.fgDim}
    ForegroundActive=${c p.accent}
    ForegroundLink=${c p.accent}
    ForegroundVisited=${c p.accent}
    ForegroundNegative=${c p.urgent}
    ForegroundNeutral=${c p.warn}
    ForegroundPositive=${c p.ok}
    DecorationFocus=${c p.accent}
    DecorationHover=${c p.hover}

    [Colors:View]
    BackgroundNormal=${c p.base}
    BackgroundAlternate=${c p.bg}
    ForegroundNormal=${c p.fg}
    ForegroundInactive=${c p.fgDim}
    ForegroundActive=${c p.accent}
    ForegroundLink=${c p.accent}
    ForegroundVisited=${c p.accent}
    ForegroundNegative=${c p.urgent}
    ForegroundNeutral=${c p.warn}
    ForegroundPositive=${c p.ok}
    DecorationFocus=${c p.accent}
    DecorationHover=${c p.hover}

    [Colors:Button]
    BackgroundNormal=${c p.elevated}
    BackgroundAlternate=${c p.hover}
    ForegroundNormal=${c p.fg}
    ForegroundInactive=${c p.fgDim}
    ForegroundActive=${c p.accent}
    ForegroundLink=${c p.accent}
    ForegroundVisited=${c p.accent}
    ForegroundNegative=${c p.urgent}
    ForegroundNeutral=${c p.warn}
    ForegroundPositive=${c p.ok}
    DecorationFocus=${c p.accent}
    DecorationHover=${c p.hover}

    # Breeze 5.19'dan beri arac cubuklari ve sekme seritleri BU grubu
    # kullanir; tanimli degilse KColorScheme koyu semada uyumsuz bir tona duser.
    [Colors:Header]
    BackgroundNormal=${c p.elevated}
    BackgroundAlternate=${c p.bg}
    ForegroundNormal=${c p.fg}
    ForegroundInactive=${c p.fgDim}
    ForegroundActive=${c p.accent}
    ForegroundLink=${c p.accent}
    ForegroundVisited=${c p.accent}
    ForegroundNegative=${c p.urgent}
    ForegroundNeutral=${c p.warn}
    ForegroundPositive=${c p.ok}
    DecorationFocus=${c p.accent}
    DecorationHover=${c p.hover}

    [Colors:Header][Inactive]
    BackgroundNormal=${c p.bg}
    BackgroundAlternate=${c p.bg}
    ForegroundNormal=${c p.fgDim}
    ForegroundInactive=${c p.fgDim}

    [Colors:Selection]
    BackgroundNormal=${c p.accent}
    BackgroundAlternate=${c p.accent}
    ForegroundNormal=${c p.accentFg}
    ForegroundInactive=${c p.accentFg}
    ForegroundActive=${c p.accentFg}
    ForegroundLink=${c p.accentFg}
    ForegroundVisited=${c p.accentFg}
    ForegroundNegative=${c p.urgent}
    ForegroundNeutral=${c p.warn}
    ForegroundPositive=${c p.ok}
    DecorationFocus=${c p.accent}
    DecorationHover=${c p.hover}

    [Colors:Tooltip]
    BackgroundNormal=${c p.elevated}
    BackgroundAlternate=${c p.bg}
    ForegroundNormal=${c p.fg}
    ForegroundInactive=${c p.fgDim}
    ForegroundActive=${c p.accent}
    ForegroundLink=${c p.accent}
    DecorationFocus=${c p.accent}
    DecorationHover=${c p.hover}

    [Colors:Complementary]
    BackgroundNormal=${c p.base}
    BackgroundAlternate=${c p.bg}
    ForegroundNormal=${c p.fg}
    ForegroundInactive=${c p.fgDim}
    ForegroundActive=${c p.accent}
    ForegroundLink=${c p.accent}
    DecorationFocus=${c p.accent}
    DecorationHover=${c p.hover}

    # Bu iki blok tanimli DEGILSE KColorScheme acik tema icin ayarlanmis
    # dahili varsayilanlarini kullanir ve koyu semada pasif metin
    # okunamayacak kadar sonukleser. Degerler KDE'nin kendi
    # BreezeDark.colors dosyasindan alindi.
    [ColorEffects:Disabled]
    Color=56,56,56
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    IntensityAmount=0.1
    IntensityEffect=2

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=112,111,110
    ColorAmount=0.025
    ColorEffect=2
    ContrastAmount=0.1
    ContrastEffect=2
    Enable=false
    IntensityAmount=0
    IntensityEffect=0

    [WM]
    activeBackground=${c p.elevated}
    activeForeground=${c p.fg}
    inactiveBackground=${c p.bg}
    inactiveForeground=${c p.fgDim}
  '';
}
