{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.tofi = {
    enable = true;
    settings = {
      # --- GÖRÜNÜM VE PENCERE ---
      width = "70%"; # Ekranı tamamen kaplaması için %100 genişlik (tam odaklanma sağlar)
      height = "70%"; # %100 yükseklik. (Ekranda sadece tofi ve arkaplan kalır)
      border-width = 0; # Çerçeveyi kaldırır, daha sert ve "temiz" bir görünüm verir
      outline-width = 0; # Seçim yaparken çıkan dış çizgiyi siler

      # --- HİZALAMA VE KONUM ---
      padding-top = "30%"; # Menüyü ekranın üstünden %30 aşağıya iter
      padding-left = "35%"; # Soldan %35 boşluk bırakıp listeyi ortalar
      padding-right = "35%"; # Sağdan da boşluk bırakarak tam merkeze sabitler

      # --- RENKLER (KALE KONSEPTİ: TAM SİYAH) ---
      background-color = "#000000F2"; # %95 mat siyah arka plan (neredeyse tamamen karanlık)
      text-color = "#888888"; # Okunabilir ama göz yormayan, dikkat dağıtmayan gri metin
      prompt-color = "#FFFFFF"; # "❯" komut işaretinin rengi (bembeyaz, dikkat çekici)
      selection-color = "#FFFFFF"; # Üzerine geldiğin/seçtiğin uygulamanın metni parlar
      selection-background = "#00000000"; # Seçili öğenin arka planını saydam bırakır (estetik için)

      # --- FONTLAR VE DAVRANIŞ ---
      font = "monospace"; # Gerçek bir terminal hissiyatı için sistemin varsayılan monospace fontu
      prompt-text = "❯ "; # Kullanıcıyı karşılayan komut istemi sembolü
      hide-cursor = true; # Fare imlecini gizler (sadece klavye ile kullanıma zorlar, hızı artırır)
      fuzzy-match = true; # "ffx" yazdığında bile "firefox"u bulmasını sağlayan akıllı arama
    };
  };
}
