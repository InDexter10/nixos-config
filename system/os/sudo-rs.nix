{ ... }:

{
  security = {
    sudo.enable = false;

    sudo-rs = {
      enable = true;

      execWheelOnly = true;
      wheelNeedsPassword = true;

      extraConfig = ''
        Defaults !pwfeedback

        # Varsayilan 15 dakika. 0 = her komutta sorar.
        Defaults timestamp_timeout=5
      '';
    };
  };
}
