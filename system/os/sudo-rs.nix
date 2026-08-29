{ ... }:

{
  security = {
    # Klasik C sudo devre disi; yerine bellek-guvenli Rust implementasyonu.
    sudo.enable = false;

    sudo-rs = {
      enable = true;

      # setuid ikiliyi yalnizca wheel grubu calistirabilir. Wheel disindaki bir
      # hesap ele gecirilse bile sudo ikilisine hic dokunamaz.
      execWheelOnly = true;
      wheelNeedsPassword = true;

      extraConfig = ''
        # Parola girerken yildiz gosterme - parola uzunlugunu omuz surfune
        # sizdirmasin. (Zaten varsayilan; niyet acik olsun diye yaziliyor.)
        Defaults !pwfeedback

        # sudo dogrulamayi varsayilan olarak 15 dakika hatirlar; bu sure boyunca
        # makinenin basindan kalksan bile parolasiz root erisimi acik kalir.
        # 5 dakika, gunluk kullanimi zorlastirmadan bu pencereyi daraltir.
        # Her komutta parola sorulmasi icin: 0
        Defaults timestamp_timeout=5
      '';
    };
  };
}
