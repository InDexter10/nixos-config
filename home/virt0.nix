{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./global

    ./features/desktop/niri
    ./features/desktop/common

    ./features/pkgs/gui
    ./features/pkgs/gui/uyap
    ./features/pkgs/gui/keepass

    ./features/pkgs/flatpakApps

  ];

  home.username = "virt0";
  home.homeDirectory = "/home/virt0";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;
  };

  home.packages = with pkgs; [
    # ... mevcut paketlerin ...

    # 2. EKLENECEK TEK SATIR BU:
    inputs.noctalia.packages.${pkgs.system}.default
    inputs.fresh-editor.packages.${pkgs.system}.default
  ];

}
