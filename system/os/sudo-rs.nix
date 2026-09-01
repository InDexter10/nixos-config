{ ... }:

{
  security = {
    # Klasik C sudo yerine bellek-guvenli Rust implementasyonu.
    sudo.enable = false;

    sudo-rs = {
      enable = true;

      # setuid ikiliyi yalnizca wheel calistirabilir.
      execWheelOnly = true;
      wheelNeedsPassword = true;

      extraConfig = ''
        Defaults !pwfeedback

        # Varsayilan 15 dakika; makinenin basindan kalksan bile o sure
        # boyunca parolasiz root erisimi acik kalir. 0 = her komutta sor.
        Defaults timestamp_timeout=5
      '';
    };
  };
}
