{ ... }:

{
  services.thermald.enable = true;

  # cpuFreqGovernor tanimlanmaz: cekirdek varsayilani zaten schedutil
  # (CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL, built-in). Secenek yalnizca var
  # olmayan cpufreq_schedutil modulunu yuklemeye calisip hata basiyordu.
}
