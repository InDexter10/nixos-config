{ ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        opacity = 0.9; # istenen şeffaflık (compositor gerektirir)
        padding = {
          x = 8;
          y = 8;
        }; # kenar boşluğu (varsayılan 0)
        dynamic_padding = true; # artık boşluğu içerik etrafında eşit dağıt
      };

      # Geniş scrollback — power use (varsayılan 10000, üst sınır 100000).
      scrolling.history = 50000;

      # Yalnızca normal aile tanımlanır; bold/italic/bold_italic dokümana göre
      # otomatik olarak bu aileye düşer.
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 11.0;
      };

      # Seçimle otomatik panoya kopyalama.
      selection.save_to_clipboard = true;

      # Yazarken imleci gizle.
      mouse.hide_when_typing = true;
    };
  };
}
