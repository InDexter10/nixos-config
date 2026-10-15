{ pkgs, ... }:

{
  users.mutableUsers = true;

  users.users.dex = {
    isNormalUser = true;
    description = "main user";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    shell = pkgs.fish;
  };

  users.users.dex2 = {
    isNormalUser = true;
    description = "main user";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    shell = pkgs.fish;
  };
}
