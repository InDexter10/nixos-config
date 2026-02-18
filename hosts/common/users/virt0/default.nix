{ pkgs, ... }:

{
  users.users.virt0 = {
    isNormalUser = true;
    description = "second user";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

}
