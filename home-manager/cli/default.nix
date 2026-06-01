{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./zsh.nix
    ./helix.nix
    ./yazi.nix
  ];

  home.packages = with pkgs; [
    tree
    timewarrior
    jq

    grc
    ripgrep

    onefetch

    pciutils
    usbutils
    binutils

    nix-tree
    file

  ];

}
