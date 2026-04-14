{ pkgs, ... }:
{
  programs.tofi = {
    enable = true;
    settings = {
      "drun-launch" = true;
      horizontal = true;
      anchor = "bottom";
      width = "100%";
      height = 32;

      font = "monospace";
      font-size = 12;
      prompt-text = "❯ ";
      outline-width = 0;
      border-width = 0;
      border-color = "#656869";
      padding-top = 6;
      padding-bottom = 6;
      padding-left = 10;
      padding-right = 10;
      result-spacing = 20; # Uygulamalar arası boşluk
      min-input-width = 100; # Yazı yazma alanının genişliği

      background-color = "#0e0e0d"; # t1 - Zemin
      text-color = "#656869"; # t4 - Pasif uygulamalar
      prompt-color = "#f78c5e"; # t11 - Turuncu imleç
      selection-color = "#f23672"; # highlight - Seçili uygulama
      selection-match-color = "f23672"; # Eşleşen harflerin rengi
    };
  };
}
