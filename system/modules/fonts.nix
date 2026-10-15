{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = false;

    packages = with pkgs; [
      inter
      noto-fonts
      nerd-fonts.symbols-only
      jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [
          "JetBrains Mono"
          "Symbols Nerd Font Mono"
          "Noto Sans Mono"
        ];
        emoji = [ ];
      };

      subpixel.rgba = "rgb";
    };
  };
}
