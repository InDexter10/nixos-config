{ pkgs, ... }:

{
  security.rtkit.enable = true;

  security.polkit.enable = true;

  security.audit.enable = false;
  security.auditd.enable = false;
}
