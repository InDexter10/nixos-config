{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    tree
    timewarrior
    uair
    jq

    translate-shell

    grc
    ripgrep
    fd
    p7zip

    onefetch

    pciutils
    usbutils
    binutils

    nix-tree
    file

  ];

}
