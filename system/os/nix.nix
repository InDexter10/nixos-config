{ ... }:

{
  nix = {
    # Sistem tamamen flake tabanli; channel ikinci bir paket kaynagi olurdu.
    # NOT: kurulumdan kalma channel profili ELLE temizlenmeli:
    #   sudo nix-channel --remove nixos
    #   sudo rm -rf /nix/var/nix/profiles/per-user/root/channels*
    channel.enable = false;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Buraya bir hesap eklemek ona fiilen root yetkisi vermektir.
      trusted-users = [ "root" ];

      # Varsayilani "*", yani sistemdeki her hesap.
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
      # 7 gun: calisan bir rollback penceresi birakir.
      options = "--delete-older-than 7d";
    };
  };

  # /tmp tmpfs oldugu icin (os/boot.nix) derleme agaci RAM'i tuketirdi.
  # /var/tmp diskte; nix kendi derleme dizinlerini kendisi siler.
  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
}
