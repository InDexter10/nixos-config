{
  pkgs,
  ...
}:

{
  imports = [
    ./zram.nix
    ./zsh.nix
    ./labwc.nix
    ./greetd.nix
  ];

}
