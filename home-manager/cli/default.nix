{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./git.nix
    ./zsh.nix
    ./helix.nix
    ./yazi.nix
  ];

  home.packages = with pkgs; [
    tree
    timewarrior
    jq

    ripgrep

    onefetch

    pciutils
    usbutils
    binutils

    nix-tree
    file

  ];

}
