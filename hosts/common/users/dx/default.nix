{ pkgs, ... }:

{
  users.users.dx = {
    isNormalUser = true;
    description = "second user";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

}
