# hosts/common/optional/labwc.nix
{ pkgs, ... }:

{
  programs.labwc = {
    enable = true;
  };
}
