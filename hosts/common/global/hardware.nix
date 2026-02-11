{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };
  hardware.cpu.intel.updateMicrocode = true;

  hardware.enableRedistributableFirmware = true;

}
