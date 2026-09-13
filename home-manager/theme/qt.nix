{ ... }:

let
  p = import ./palette.nix;
  c = p.toRgb;

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

    # Breeze 5.19'dan beri arac cubuklari ve sekme seritleri bu grubu kullanir;
    # tanimli degilse KColorScheme koyu semada uyumsuz bir tona duser.
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

    # Tanimli degilse KColorScheme acik tema icin ayarlanmis dahili
    # varsayilanlarini kullanir ve koyu semada pasif metin okunamaz hale gelir.
    # Degerler KDE'nin BreezeDark.colors dosyasindan.
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
