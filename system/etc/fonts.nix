{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "corefonts";

  fonts = {
    packages = with pkgs; [
      corefonts # Times New Roman + Arial (Windows web fontlari)
      nerd-fonts.jetbrains-mono # monospace + ikon glyph'leri (terminal, rofi, mako)
    ];

    fontconfig.defaultFonts = {
      serif = [ "Times New Roman" ];
      sansSerif = [ "Arial" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}
