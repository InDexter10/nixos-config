{
  pkgs,
  ...
}:

{
  imports = [
    ./locale.nix
    ./nix.nix
    ./fish.nix
    ./hardware.nix
    ./zram.nix
    ./power-management.nix
  ];

}
