{ ... }:

{
  services.fstrim.enable = true;
  fileSystems."/".options = [ "noatime" ];
}
