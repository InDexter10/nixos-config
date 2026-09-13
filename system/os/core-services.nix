{ ... }:

{
  security = {
    rtkit.enable = true;
    polkit.enable = true;

    audit.enable = false;
    auditd.enable = false;
  };

  services.journald = {
    storage = "persistent";
    extraConfig = ''
      SystemMaxUse=200M
      SystemMaxFileSize=25M
      MaxRetentionSec=2week
    '';
  };

  services.speechd.enable = false;

  environment.defaultPackages = [ ];

  documentation = {
    man.enable = true;
    nixos.enable = true;

    doc.enable = false;
    info.enable = false;
  };
}
