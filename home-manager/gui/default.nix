{ pkgs, ... }:

{
  imports = [
    ./flatpakapps.nix
    ./uyap.nix
  ];

  home.packages = [ pkgs.claude-code ];
}
