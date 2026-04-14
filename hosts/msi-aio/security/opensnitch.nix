{
  pkgs,
  lib,
  config,
  ...
}:

{
  services.opensnitch = {
    enable = true;

    settings = {
      DefaultAction = "allow";

      DefaultDuration = "15s";

      LogOutput = "file:/var/log/opensnitchd.log";
    };

    rules = {
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
          data = "^/nix/store/[^/]+-systemd-[^/]+/lib/systemd/systemd-resolved$";
        };
      };

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
          data = "^/nix/store/[^/]+-networkmanager-[^/]+/bin/NetworkManager$";
        };
      };

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
