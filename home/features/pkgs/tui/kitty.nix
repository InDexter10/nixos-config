{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    # ==========================================
    # 1. FONT (Sıfır Yük, Doğal İşleme)
    # ==========================================
    font = {
      # symlinkJoin gibi işlemci yoran hileler yok, doğrudan paketi çağırıyoruz
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
      size = 11; # Jilet keskinliği için tam sayı
    };

    settings = {
      # ==========================================
      # 2. WAYLAND VE MEKANİK PERFORMANS
      # ==========================================
      linux_display_server = "wayland";
      wayland_titlebar_color = "background";
      update_check_interval = 0;
      sync_to_monitor = "yes";

      # Görsel ve işitsel tüm uyarıları (bloat) kapat
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";

      # ==========================================
      # 3. PENCERE VE ÇIKIŞ DAVRANIŞI
      # ==========================================
      # Çıkarken kesinlikle "Emin misin?" diye sormaz, anında kapanır.
      confirm_os_window_close = 0;

      remember_window_size = "no";
      initial_window_width = "100c";
      initial_window_height = "30c";
      window_padding_width = 4;

      # ==========================================
      # 4. KOPYALAMA VE PANO YÖNETİMİ
      # ==========================================
      # Fareyle seçilen an clipboard'a kopyalar
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";
      clipboard_control = "write-clipboard write-primary read-clipboard-ask read-primary-ask";

      # ==========================================
      # 5. GÖRSEL TEMİZLİK (İmleç ve Şeffaflık)
      # ==========================================
      # Şeffaflık ve blur kapalı. Harfler Labwc ile çakışmadan tam netlikte çizilir.
      background_opacity = "1.0";

      # İmleç izi (hayalet efekt) kapalı. CPU/GPU gecikmesi yaratmaz.
      cursor_trail = 0;
      cursor_blink_interval = 0;
      cursor_shape = "block";

      # ==========================================
      # 6. HEX STEEL NATIVE TEMA
      # ==========================================
      background = "#1d1e1b";
      foreground = "#c3c3bd";

      cursor = "#d4d987";
      cursor_text_color = "#0e0e0d";

      selection_background = "#4a9aa6";
      selection_foreground = "#080a0b";

      color0 = "#1d1e1b";
      color8 = "#5b5555";
      color1 = "#d85c60";
      color9 = "#ff4000";
      color2 = "#d4d987";
      color10 = "#c9d400";
      color3 = "#f78c5e";
      color11 = "#f69c3c";
      color4 = "#6e8789";
      color12 = "#4a9aa6";
      color5 = "#f23672";
      color13 = "#f23672";
      color6 = "#9bc1bb";
      color14 = "#42baff";
      color7 = "#b5c5c5";
      color15 = "#c3c3bd";
    };

    # İsteğe Bağlı Ek Kısayollar
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
    };
  };
}
