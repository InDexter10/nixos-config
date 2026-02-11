{ pkgs, ... }:

{
  # Fortress Workstation - GNOME/Adwaita Standard (Approved)

  colors = {
    base = "#1e1e1e";
    text = "#ffffff";
    accent = "#3584e4";
  };

  fonts = {
    sansSerif = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
    };
    serif = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
    };
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };

  cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  icons = {
    package = pkgs.papirus-icon-theme;
    name = "Papirus-Dark";
  };

  theme = {
    gtk = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    qt = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
    };
  };
}
