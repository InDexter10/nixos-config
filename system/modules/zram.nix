{ ... }:

{
  # Disk swap yok. zram dolarsa kademeli yavaslama degil dogrudan OOM olur;
  # zstd ~3:1 sikistirmada gercek RAM maliyeti tavanda ~2.5 GB.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  # zram'e sayfalama diske gore cok ucuz oldugu icin agresif degerler.
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
}
