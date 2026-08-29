{ pkgs, ... }:

{
  # corefonts unfree'dir; izin listesi flake.nix'teki `allowedUnfree`de tutulur.
  fonts = {
    packages = with pkgs; [
      corefonts # Times New Roman + Arial (Windows web fontlari)
      nerd-fonts.jetbrains-mono # monospace + ikon glyph'leri (terminal, rofi, mako)
      cantarell-fonts
      noto-fonts
    ];

    fontconfig.defaultFonts = {
      serif = [ "Times New Roman" ];
      sansSerif = [ "Arial" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}
