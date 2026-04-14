{ pkgs, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.wezterm}/bin/wezterm";
        layer = "overlay";
        width = 55;
        lines = 10; # gösterilecek satır sayısı
        tabs = 4;
        horizontal-pad = 20;
        vertical-pad = 12;
        inner-pad = 6;
        prompt = "  "; # nerd font ikon
        font = "JetBrainsMono Nerd Font:size=11";
        anchor = "center"; # ekran ortası
        image-size-ratio = 0.5; # ikon boyut oranı
      };

      # ── Hex Steel Teması ──────────────────────────────────────
      colors = {
        background = "1a1d23ff"; # derin çelik karanlık
        text = "c8cdd6ff"; # soğuk açık gri
        match = "5b9bd5ff"; # çelik mavi (eşleşen harf)
        selection = "2a3f5fff"; # seçili satır arkaplanı
        selection-text = "e8ecf1ff"; # seçili yazı
        selection-match = "7eb8f7ff"; # seçili satırdaki eşleşen harf
        border = "3d7ac8ff"; # çelik mavi kenarlık
      };

      border = {
        width = 2;
        radius = 8;
      };
    };
  };
}
