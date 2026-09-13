{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  hardware.cpu.intel.updateMicrocode = true;

  hardware.enableRedistributableFirmware = true;
}
