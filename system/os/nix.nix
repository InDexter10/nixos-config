{ ... }:

{
  nix = {
    # Sistem tamamen flake tabanli. Legacy channel mekanizmasi kullanilmiyor;
    # acik kalmasi hem gereksiz yapi (kural 3) hem de flake'lerle celisen ikinci
    # bir paket kaynagi demek (kural 6).
    #
    # NOT: kurulumdan kalma channel profili ayrica ELLE temizlenmeli, bu secenek
    # onu geriye donuk silmez:
    #   sudo nix-channel --remove nixos
    #   sudo rm -rf /nix/var/nix/profiles/per-user/root/channels*
    channel.enable = false;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Store'a dogrudan yazabilen / sandbox ayarlarini gecersiz kilabilen
      # kullanicilar. Buraya bir hesap eklemek ona fiilen root yetkisi vermektir.
      # Varsayilaniyla ayni, ama sessizce degismemesi gereken bir karar.
      trusted-users = [ "root" ];

      # nix-daemon'a is gonderebilecek hesaplar. Varsayilani "*", yani
      # sistemdeki her hesap. Tek kullanicili sistemde daraltmanin bedeli yok
      # (kural 4: varsayilan minimal, ihtiyaca gore acilir).
      allowed-users = [
        "root"
        "dex"
      ];

      warn-dirty = false;
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      # 7 gun: calisan bir rollback penceresi birakacak kadar uzun.
      # (2026-08-29'daki Wi-Fi arizasinda onceki nesle donmek gerekmisti.)
      options = "--delete-older-than 7d";
    };
  };
}
