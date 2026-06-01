# rofi.nix - drun baslatici, labwc ile uyumlu (Gruvbox Material / notr koyu)
{ config, pkgs, ... }:

let
  # Rasi'de renk/anahtar kelime gibi degerleri TIRNAKSIZ yazmak icin gerekir.
  inherit (config.lib.formats.rasi) mkLiteral;

  # ----------------------------- PALET ---------------------------------
  # Tek ozellestirme noktasi: tum renkler buradan gelir.
  # Not: zemin bilerek notr-koyu (#1d2021 "hard") secildi; gruvbox'un
  #      sicak/sarimsi zemin tonu KULLANILMADI.
  bg       = "#1d2021"; # ana arka plan (notr koyu)
  bgAlt    = "#282828"; # arama cubugu icin hafif kontrast yuzey
  fg       = "#d4be98"; # ana metin (gruvbox material krem)
  fgDim    = "#928374"; # ikincil/soluk metin (prompt, placeholder)
  accent   = "#7daea3"; # vurgu: secili oge + kenarlik (serin mavi ton)
  accentFg = "#1d2021"; # secili oge uzerindeki metin (koyu, kontrast icin)
in
{
  programs.rofi = {
    enable = true;

    # labwc native Wayland uyumlu fork. Cagri sekli mainline ile aynidir
    # (rc.xml'deki "rofi -show drun" dogru; ayri bir wayland bayragi yok).
    package = pkgs.rofi-wayland;

    # Sistemde kurulu font.
    font = "JetBrainsMono Nerd Font 10";

    # --------------------------- DAVRANIS ------------------------------
    # rofi "configuration {}" blogu. Yeni mod eklemek istersen modi'ye ekle.
    extraConfig = {
      modi = "drun"; # yalnizca uygulama baslatici
      show-icons = true; # drun'da uygulama ikonlari
      icon-theme = "Papirus"; # sistemdeki ile ayni (koyu icin "Papirus-Dark")
      drun-display-format = "{name}"; # sadece uygulama adini goster
      terminal = "alacritty"; # terminal gerektiren .desktop girdileri icin
    };

    # --------------------------- GORUNUM -------------------------------
    # rasi temasi. Olculeri (genislik/satir/bosluk) burada degistir.
    theme = {
      "*" = {
        background-color = mkLiteral bg;
        text-color = mkLiteral fg;
      };

      # Pencere: ust-orta, %50 genislik, keskin koseler (labwc cornerRadius=0 ile uyumlu).
      "window" = {
        location = mkLiteral "north"; # ekranin ust kenarina yasla
        anchor = mkLiteral "north";
        y-offset = mkLiteral "0px"; # ust kenardan bosluk istersen artir (or. 8px)
        width = mkLiteral "50%";
        border = mkLiteral "2px";
        border-color = mkLiteral accent;
        border-radius = mkLiteral "0px";
        background-color = mkLiteral bg;
      };

      "mainbox" = {
        padding = mkLiteral "8px";
        spacing = mkLiteral "8px";
        children = map mkLiteral [ "inputbar" "listview" ];
      };

      # Arama satiri
      "inputbar" = {
        background-color = mkLiteral bgAlt;
        padding = mkLiteral "8px";
        spacing = mkLiteral "8px";
        children = map mkLiteral [ "prompt" "entry" ];
      };
      "prompt" = {
        text-color = mkLiteral accent;
      };
      "entry" = {
        text-color = mkLiteral fg;
        placeholder = "Ara..."; # bos arama kutusu metni
        placeholder-color = mkLiteral fgDim;
      };

      # Liste: 10 satir, tek sutun, kaydirma cubugu yok.
      "listview" = {
        lines = 10; # gosterilecek satir sayisi
        columns = 1;
        scrollbar = false;
        fixed-height = true; # az sonuc olsa da yuksekligi sabit tut
        spacing = mkLiteral "2px";
      };

      # Satirlar
      "element" = {
        padding = mkLiteral "6px";
        spacing = mkLiteral "8px";
        border-radius = mkLiteral "0px";
      };
      "element selected" = {
        background-color = mkLiteral accent;
        text-color = mkLiteral accentFg;
      };
      "element-icon" = {
        size = mkLiteral "1.1em";
        background-color = mkLiteral "transparent";
      };
      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit"; # secili satirda dogru rengi devral
      };
    };
  };
}
