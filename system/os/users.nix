{ pkgs, ... }:

{
  # Kurulum senaryosu root parolasinin ELLE belirlenmesine dayaniyor.
  # false olsaydi elle konan parola her aktivasyonda silinir ve rescue
  # kabugu erisilemez hale gelirdi.
  users.mutableUsers = true;

  users.users.dex = {
    isNormalUser = true;
    description = "main user";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    shell = pkgs.zsh;

    # Parola bilerek burada tanimli DEGIL:
    #   1) Depo GitHub'a gidiyor; hash'i buraya yazmak onu yayinlamaktir.
    #   2) mutableUsers = true iken zaten yalnizca ilk olusturmada gecerli,
    #      yani islevsiz.
    # Kurulum:  root konsolunda  passwd dex
    # Deklaratif gerekirse dogru yol depo DISINDA bir dosyadir:
    #   hashedPasswordFile = "/etc/nixos-secrets/dex.hash";   (mkpasswd -m yescrypt)
  };
}
