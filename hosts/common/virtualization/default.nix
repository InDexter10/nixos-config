{ config, pkgs, ... }:

{
  # 1. Kernel Modülleri
  boot.kernelModules = [ "kvm-intel" ];

  # 2. Libvirtd Servisi
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true; # TPM 2.0 desteği (Win11 için)

      # HATA DÜZELTME: 'ovmf' ve 'vhostUserPackages' hatalı olduğu için kaldırıldı.
      # Standart 'qemu_kvm' paketi gerekli özellikleri zaten barındırır.
    };

    onShutdown = "suspend";
  };

  # 3. SPICE USB Yönlendirme
  virtualisation.spiceUSBRedirection.enable = true;

  # 4. Grafik Arayüz
  programs.virt-manager.enable = true;
  programs.dconf.enable = true;

  # 5. Sistem Paketleri
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    swtpm
    OVMFFull
    adwaita-icon-theme
  ];

  # 6. Ağ Ayarları
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # 7. Kullanıcı İzni
  users.users.dx.extraGroups = [
    "libvirtd"
    "kvm"
  ];
}
