{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = false;

    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-color-emoji
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      corefonts
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

      subpixel.rgba = "rgb";
    };
  };
}
