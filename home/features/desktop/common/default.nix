{
  pkgs,
  ...
}:

{
  imports = [
    ./style
    ./waybar
  ];
  home.packages = with pkgs; [
    ironbar
  ];

}
