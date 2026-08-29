{ ... }:

{
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    audit.enable = false;
    auditd.enable = false;
  };
}
