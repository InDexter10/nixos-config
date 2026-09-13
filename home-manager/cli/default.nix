{ pkgs, ... }:

{
  imports = [
    ./foot.nix
    ./git.nix
    ./zsh.nix
    ./helix.nix
    ./yazi.nix
  ];

  home.packages = with pkgs; [
    tree
    timewarrior
    jq
    htop
    ripgrep
    onefetch
    pciutils
    usbutils
    binutils
    nix-tree
    file

    poppler-utils
    ocrmypdf
  ];
}
