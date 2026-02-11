{
  pkgs,
  ...
}:

{
  imports = [
    ./sudo-rs.nix
    ./opensnitch.nix
    ./usbguard.nix
    ./others.nix
  ];

  system.stateVersion = "25.11";
}
