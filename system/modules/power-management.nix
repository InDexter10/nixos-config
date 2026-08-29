{ ... }:

{
  services.thermald.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";
}
