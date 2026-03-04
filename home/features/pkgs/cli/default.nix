{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./zsh.nix
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

    pciutils
    usbutils
    binutils

  ];

}
