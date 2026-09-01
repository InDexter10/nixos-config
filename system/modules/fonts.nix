{ pkgs, ... }:

# Uc ayri is, uc ayri aile:
#   ARAYUZ    -> Inter        (secimi home-manager/theme/palette.nix yapar)
#   BELGE     -> Noto Sans    (genel "sans-serif" karsiligi)
#   TERMINAL  -> JetBrainsMono Nerd Font
#
# corefonts KURULU KALIYOR: bir belge fontu ADIYLA ("Arial", "Times New
# Roman") istediginde gercek fontu alir, UYAP belgelerinin gorunumu degismez.
# Degisen yalnizca hicbir ad verilmediginde gelen genel karsilik.

{
  fonts = {
    # Varsayilan set (dejavu, liberation, gyre, unifont...) kapali: Noto'nun
    # kapsami + corefonts bu makinedeki tum belgeler icin yeterli, digerleri
    # karsiligi olmayan yuk. Bir uygulama "DejaVu Sans" isterse fontconfig
    # Noto'ya duser.
    enableDefaultPackages = false;

    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-color-emoji
      jetbrains-mono # genel monospace (ikonsuz)
      nerd-fonts.jetbrains-mono # YALNIZCA terminal; ikonlu surumu global
      # monospace yapmak kod bloklarinda beklenmedik glyph uretir
      corefonts # unfree; izin listesi flake.nix'te
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [
          "Noto Sans"
          "Noto Color Emoji"
        ];
        serif = [
          "Noto Serif"
          "Noto Color Emoji"
        ];
        monospace = [
          "JetBrains Mono"
          "Noto Sans Mono"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };

      # Varsayilandan FARKLI olan tek ayar. Panel bir LCD (eDP-1, ~106 DPI);
      # alt-piksel cizimi bu yogunlukta metni gorulur sekilde keskinlestirir.
      # Renk sacaklanmasi rahatsiz ederse: "none".
      subpixel.rgba = "rgb";
    };
  };
}
