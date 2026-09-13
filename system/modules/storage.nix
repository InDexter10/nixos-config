{ ... }:

{
  services.fstrim.enable = true;

  fileSystems = {
    "/".options = [ "noatime" ];

    "/boot".options = [
      "nosuid"
      "nodev"
      "noexec"
    ];
  };
}
