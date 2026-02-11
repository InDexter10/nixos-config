{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./fish.nix
    ./fastfetch.nix
  ];

  home.packages = with pkgs; [
    tree
    timewarrior
    jq

    grc
    ripgrep
    fd
    p7zip

    onefetch

  ];

}
