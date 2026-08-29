{ ... }:

{
  imports = [
    ./boot.nix
    ./core-services.nix
    ./hardware-configuration.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./sudo-rs.nix
    ./users.nix
  ];

  # --- Aktivasyon mekanizmalari ---
  # Ucu de su an nixpkgs'te zaten varsayilan olarak false. Burada acikca
  # sabitleniyorlar ki upstream varsayilani degistirdiginde sistem sessizce
  # yeni bir aktivasyon/kullanici yonetimi yoluna gecmesin - ongorulebilirlik
  # (kural 6) bu sistemde yeni ozellikten daha degerli.
  #
  #   nixos-init  : bash kullanmayan yeni aktivasyon yolu
  #   etc.overlay : /etc'yi overlayfs olarak baglar. Ileride salt-okunur /etc
  #                 gibi bir hardening imkani sunabilir, ANCAK nixpkgs onu
  #                 "currently experimental - only enable this option if you're
  #                 confident that you can recover your system if it breaks"
  #                 diye isaretliyor. Kural 1 geregi kapali.
  #   userborn    : yeni kullanici/parola olusturma yolu
  system.nixos-init.enable = false;
  system.etc.overlay.enable = false;
  services.userborn.enable = false;

  # Ilk kurulum surumu. ASLA guncellenmemeli; veri formati uyumlulugu buna bagli.
  system.stateVersion = "26.05";
}
