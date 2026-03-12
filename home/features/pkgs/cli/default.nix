{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./zsh.nix
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

    pciutils
    usbutils
    binutils

    nix-tree

  ];

}
