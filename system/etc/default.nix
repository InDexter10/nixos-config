{
  pkgs,
  ...
}:

{
  imports = [
    ./zsh.nix
    ./zram.nix
    ./labwc.nix
    ./greetd.nix
    ./fonts.nix
    ./power-management.nix
    ./pipewire.nix
    ./driver.nix
  ];

}
