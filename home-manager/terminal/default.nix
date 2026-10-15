{ pkgs, ... }:

{
  imports = [
    ./foot.nix
    ./fish.nix
    ./helix.nix
    ./yazi.nix
    ./cava.nix
    ./claude-code.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    tree
    jq
    htop
    ripgrep
    pciutils
    usbutils
    binutils
    file
    unzip

    poppler-utils
    ocrmypdf
  ];
}
