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
      '';
    };
  };
}
