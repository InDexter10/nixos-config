{ pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.alacritty}/bin/alacritty";
        layer = "overlay";
        width = 40;
      };
      colors = {
        # Adwaita Dark Renk Paleti (Manual & Deterministik)
        background = "1e1e1eff"; # Koyu Gri
        text = "ffffffff"; # Beyaz
        match = "3584e4ff"; # Adwaita Mavisi
        selection = "3584e4ff"; # Seçim Arkaplanı (Mavi)
        selection-text = "ffffffff"; # Seçim Yazısı
        border = "3584e4ff"; # Kenarlık
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}
