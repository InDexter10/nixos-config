{ config, pkgs, ... }:

{
  # 1. KEEPASSXC: Şifre Kasası
  home.packages = with pkgs; [
    keepassxc
  ];

  # 2. SYNCTHING: Kendi Şifreli Bulutun (P2P Senkronizasyon)
  # Bu servis, şifre kasanı (KDBX dosyası) Google'a yüklemeden,
  # doğrudan telefonunla şifreli bir tünel üzerinden eşitler.
  services.syncthing = {
    enable = true;
    # Celeron N4000 işlemcini yormaması için tarama ve CPU kullanımı minimize edildi
    extraOptions = [
      "--gui-address=127.0.0.1:8384" # Arayüze sadece bu bilgisayardan erişilebilir
    ];
  };

  # Syncthing'in varsayılan klasörlerini devre dışı bırakıp, sadece senin kasanı eşitlemesi için
  # ince ayarlar (GUI üzerinden localhost:8384 adresinden yöneteceksin)
}
