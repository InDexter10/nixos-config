{ ... }:

# labwc kendi dosya duzenini kullanir; ./config icerigi oldugu gibi
# ~/.config/labwc altina baglanir:
#
#   rc.xml            genel ayarlar + klavye/fare kisayollari
#   menu.xml          sag tik menusu
#   themerc-override  renkler ve olculer
#   environment       oturum ortam degiskenleri
#   autostart         oturum acilisinda calisan komutlar
#   shutdown          oturum kapanisinda calisan komutlar
#
# Bu modulun tek isi o baglantiyi kurmak ve oturum hedefini tanimlamaktir.
#
# labwc "graphical-session.target"i kendisi acmaz; hedef hicbir zaman aktif
# olmadigi icin ona bagli kullanici servisleri (waybar, wlsunset) ya hic
# baslamiyor ya da aninda oluyordu.
#
# graphical-session.target'in RefuseManualStart=yes bayragi var, elle
# baslatilamaz. Cozum ortama ait kendi hedefimizi tanimlayip ona BindsTo ile
# baglamak: bagimlilik uzerinden baslatma yasak degildir. Bu, home-manager'in
# sway ve hyprland modullerinin yaptiginin aynisidir.
{
  wayland.systemd.target = "labwc-session.target";

  systemd.user.targets.labwc-session = {
    Unit = {
      Description = "labwc oturumu";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  # recursive: ~/.config/labwc gercek dizin kalir, icindeki dosyalar tek tek
  # baglanir. Dizinin kendisini tek bir baga cevirmek, home-manager'in
  # yonetmedigi mevcut dizini "clobber" saymasina yol acar.
  xdg.configFile."labwc" = {
    source = ./config;
    recursive = true;
  };
}
