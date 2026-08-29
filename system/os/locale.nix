{ ... }:

# Yerellestirme ayarlari. users.nix icinde duruyorlardi; kullaniciyla ilgileri
# olmadigi icin kendi modullerine alindi (kural 6: modul sinirlari net olsun).

{
  time.timeZone = "Europe/Istanbul";

  i18n.defaultLocale = "en_US.UTF-8";

  # TTY klavye duzeni. Grafik oturumun (labwc/wayland) duzeni bundan bagimsizdir
  # ve home-manager tarafinda ayarlanir.
  console.keyMap = "trq";
}
