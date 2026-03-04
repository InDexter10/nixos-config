{
  pkgs,
  ...
}:

{
  imports = [
    ./locale.nix
    ./nix.nix
    ./zsh.nix
    ./hardware.nix
    ./zram.nix
    ./power-management.nix
  ];

}
