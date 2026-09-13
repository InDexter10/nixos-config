{ ... }:

{
  nix = {
    channel.enable = false;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [ "root" ];

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
      options = "--delete-older-than 7d";
    };
  };

  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
}
