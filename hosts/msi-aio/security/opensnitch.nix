{
  pkgs,
  lib,
  config,
  ...
}:

{
  services.opensnitch = {
    enable = false;

    settings = {
      # İstasyon Mimarının Altın Kuralı: Tanımıyorsan Vur (Reddet).
      DefaultAction = "allow";

      # UI açık değilse veya sen ekranda yoksan, 15 saniye bekler ve otomatik REDDEDER.
      DefaultDuration = "15s";

      LogOutput = "file:/var/log/opensnitchd.log";
    };

    rules = {
      # 1. DNS Çözümleyici (İnternetin kapı kolu, mecburi)
      systemd-resolved = {
        name = "systemd-resolved";
        enabled = true;
        action = "allow";
        duration = "always";
        created = "2026-03-10T00:00:00Z";
        updated = "2026-03-10T00:00:00Z";
        operator = {
          type = "regexp";
          operand = "process.path";
          # Nix store içindeki systemd klasörünü bulur, altındaki lib yoluna gider.
          data = "^/nix/store/[^/]+-systemd-[^/]+/lib/systemd/systemd-resolved$";
        };
      };

      # 2. Saat Senkronizasyonu (Kriptografi ve HTTPS sertifikaları için hayati)
      systemd-timesyncd = {
        name = "systemd-timesyncd";
        enabled = true;
        action = "allow";
        created = "2026-03-10T00:00:00Z";
        updated = "2026-03-10T00:00:00Z";
        duration = "always";
        operator = {
          type = "regexp";
          operand = "process.path";
          data = "^/nix/store/[^/]+-systemd-[^/]+/lib/systemd/systemd-timesyncd$";
        };
      };

      # 3. Ağ Yöneticisi (IP almamız ve yönlendirme için şart)
      networkmanager = {
        name = "NetworkManager";
        enabled = true;
        action = "allow";
        created = "2026-03-10T00:00:00Z";
        updated = "2026-03-10T00:00:00Z";
        duration = "always";
        operator = {
          type = "regexp";
          operand = "process.path";
          # NetworkManager her zaman bin altındadır.
          data = "^/nix/store/[^/]+-networkmanager-[^/]+/bin/NetworkManager$";
        };
      };

      # 4. Nix Paket Yöneticisi (Sistemi güncelleyebilmek için)
      nix-daemon = {
        name = "nix-daemon";
        enabled = true;
        action = "allow";
        duration = "always";
        created = "2026-03-10T00:00:00Z";
        updated = "2026-03-10T00:00:00Z";
        operator = {
          type = "regexp";
          operand = "process.path";
          data = "^/nix/store/[^/]+-nix-[^/]+/bin/nix-daemon$";
        };
      };

      # 5. Git (Flake'leri çekmek ve repo yönetimi için)
      git = {
        name = "git";
        enabled = true;
        action = "allow";
        duration = "always";
        created = "2026-03-10T00:00:00Z";
        updated = "2026-03-10T00:00:00Z";
        operator = {
          type = "regexp";
          operand = "process.path";
          data = "^/nix/store/[^/]+-git-[^/]+/bin/git$";
        };
      };
    };
  };
}
