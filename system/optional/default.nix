{
  pkgs,
  ...
}:

{
  imports = [
    ./zsh.nix
    ./labwc.nix
    ./greetd.nix
    ./flatpak.nix
  ];

}
