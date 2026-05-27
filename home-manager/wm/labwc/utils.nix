{ pkgs, ... }:

{

  home.packages = with pkgs; [
    wlopm # Monitör kapatmak için
    wlsunset
    brightnessctl
    networkmanagerapplet
    swayidle
  ];

  # --- SWAYLOCK ---
  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      image = "/home/virt0/Pictures/bb.jpg";
      scaling = "fill";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
  };

  # ─────────────────────────────────────────────────────────
  #  utils.nix — mako yapılandırması (v3)
  # ─────────────────────────────────────────────────────────

  services.mako = {
    enable = true;
    settings = {
      background-color = "#0e0e0d";
      border-color = "#417e8c";
      text-color = "#c3c3bd";
      border-radius = 0;
      border-size = 2;
      font = "JetBrainsMono Nerd Font 10";
      width = 400;
      height = 500;
      margin = "10";
      padding = "15";
      default-timeout = 5000;
      markup = true;
      max-visible = 5;
    };
    extraConfig = ''
      [urgency=high]
      border-color=#d85c60

      # ── Çeviri popup teması ──────────────────────────────
      #
      # format açıklaması:
      #   %s = summary (orijinal kelime) → teal + kalın + büyük
      #   %b = body (Türkçe çeviri + sözlük) → koyu metin
      #
      # Böylece İngilizce ve Türkçe görsel olarak ayrılır:
      #   teal = kaynak dil (İng/Jpn/Çin/Arapça...)
      #   koyu = Türkçe çeviri
      #
      [app-name=translate]
      background-color=#faf8f5
      text-color=#2d2d2d
      border-color=#4DB6AC
      border-size=2
      border-radius=4
      font=JetBrainsMono Nerd Font 10
      width=440
      height=550
      padding=18
      default-timeout=12000
      markup=1
      format=<span foreground='#4DB6AC' size='large'><b>%s</b></span>\n%b
    '';
  };

  services.wlsunset = {
    enable = false;
    latitude = "39.9";
    longitude = "32.8";
    temperature = {
      day = 6500;
      night = 4000;
    };
  };
}
