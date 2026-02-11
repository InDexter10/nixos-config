{ pkgs, ... }:

{
  security.rtkit.enable = true;

  security.polkit.enable = true;

  security.audit.enable = true;
  security.auditd.enable = true;
}
