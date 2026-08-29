{ pkgs, ... }:

{
  # true birakiliyor: kurulum senaryosu root parolasinin ELLE belirlenmesine
  # dayaniyor (CLAUDE.md kural 8). false yapilsaydi butun parolalar
  # yapilandirmadan gelmek zorunda kalirdi; elle konan root parolasi her
  # aktivasyonda silinir ve acil durum (rescue) kabugu erisilemez hale gelirdi.
  # Acikca yaziliyor cunku bu sessizce degismemesi gereken bir karar.
  users.mutableUsers = true;

  users.users.dex = {
    isNormalUser = true;
    description = "main user";

    extraGroups = [
      "networkmanager" # NM baglantilarini polkit uzerinden yonetebilmek icin
      "wheel" # sudo-rs (execWheelOnly = true)
    ];

    shell = pkgs.zsh;

    # --- PAROLA BILEREK BURADA TANIMLI DEGIL ---
    #
    # 1) Bu depo GitHub'a gonderiliyor. Parola hash'ini burada tutmak onu
    #    dogrudan yayinlamak demek. (Eski $6$ hash'i git GECMISINDE kaldi;
    #    dosyadan silmek yetmez, parolanin kendisi degistirilmelidir.)
    #
    # 2) Islevsel karsiligi da yoktu: mutableUsers = true iken nixpkgs
    #    belgesinin deyisiyle parola "only be set when the user is created for
    #    the first time" - yani ilk olusturmadan sonra bu satir hicbir sey
    #    yapmiyordu.
    #
    # Kurulum akisi (root parolasiyla ayni mantik):
    #   temiz kurulumdan sonra root konsolunda:  passwd dex
    #
    # Deklaratif parola gerekirse dogru yol hash'i depo DISINDA tutmaktir:
    #   hashedPasswordFile = "/etc/nixos-secrets/dex.hash";
    # (mkpasswd -m yescrypt ile uretilmeli; sha512crypt artik zayif sayilir.)
  };
}
