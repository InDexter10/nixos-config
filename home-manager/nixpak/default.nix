{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./vlc.nix
    ./okular.nix
    ./gwenview.nix
  ];

  _module.args.mkNixPak = inputs.nixpak.lib.nixpak {
    inherit lib pkgs;
  };
}
