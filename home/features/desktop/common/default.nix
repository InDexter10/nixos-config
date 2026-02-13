{
  pkgs,
  ...
}:

{
  imports = [
    #./waybar
    ./mime.nix
    ./style
    #./ironbar
  ];

}
