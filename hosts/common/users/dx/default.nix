{ pkgs, ... }:

{
  users.users.dx = {
    isNormalUser = true;
    description = "second user";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "render"
    ];
    shell = pkgs.fish;
  };

}
