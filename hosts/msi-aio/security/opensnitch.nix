{
  pkgs,
  lib,
  config,
  ...
}:

{
  services.opensnitch = {
    enable = true;

    settings = {
      DefaultAction = "allow";

      LogOutput = "file:/var/log/opensnitchd.log";

    };

    rules = {
      systemd-resolved = {
        name = "systemd-resolved";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
        };
      };

      systemd-timesyncd = {
        name = "systemd-timesyncd";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
        };
      };

      networkmanager = {
        name = "NetworkManager";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin pkgs.networkmanager}/bin/NetworkManager";
        };
      };

      nix-daemon = {
        name = "nix-daemon";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${config.nix.package}/bin/nix-daemon";
        };
      };

      git = {
        name = "git";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${lib.getBin pkgs.git}/bin/git";
        };
      };
    };
  };

}
