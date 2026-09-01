# Waybar zaman sayaci. Alt komutlar:
#   feed    panelin SUREKLI beslendigi dongu (waybar bunu bir kez calistirir)
#   pick    rofi ile gecmis gorev sec veya yeni gorev ekle
#   stop    calisan gorevi bitir ve sureyi kaydet
#   extend  geri sayima dakika ekle/cikar
#
# GOREV DEFTERI timewarrior'dir ve icine BASKA HICBIR SEY yazilmaz: bir aralik
# = bir etiket = gorev adi. Sayacin modu ve planlanan bitisi deftere degil,
# $XDG_STATE_HOME altindaki oturum dosyasina yazilir; boylece "timew summary"
# ciktisi temiz kalir. Oturum dosyasi kalicidir, yeniden baslatmaya dayanir.
#
# Panel bir DONGU tarafindan beslenir: waybar saniyede bir surec acmaz, dongu
# de bosta hicbir sey yapmadan bekler. Uyanma FIFO'dan gelir; tiklama sonrasi
# panel aninda tazelenir. Bu yuzden dongunun icinde tek bir alt surec bile
# calistirilmaz - butun aritmetik ve bicimlendirme kabuk icindedir.

VARSAYILAN_DK=37
UYARI_SN=300 # geri sayimin son 5 dakikasi uyari renginde
GECMIS_GUN=90 # rofi listesinin kapsadigi gecmis
AD_SINIR=28 # panelde gosterilen gorev adi uzunlugu

IKON_GERI='󰔛'
IKON_SERBEST='󰔟'

DURDUR_SATIR='Stop and save'
IPTAL_SATIR='Discard (do not save)'
IPUCU_BOS='No task\nClick to start'

# Cok baytli kesme (${ad:0:N}) dogru calissin diye: systemd kullanici
# ortaminda LANG tanimsiz kalabiliyor.
export LC_ALL=C.UTF-8

# Oturum durumu KALICI: sayac acikken makine yeniden baslarsa mod ve kalan
# sure kaybolmasin. Kilit ve FIFO ise calisma zamanina aittir.
DURUM_DIZIN="${XDG_STATE_HOME:-$HOME/.local/state}/tw-timer"
OTURUM="$DURUM_DIZIN/oturum"
# /tmp'ye dusulmez: herkese yazilabilir bir dizinde tahmin edilebilir adla
# durum tutmak gereksiz risk.
CALISMA_DIZIN="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR tanimsiz}/tw-timer"
KILIT="$CALISMA_DIZIN/kilit"
FIFO="$CALISMA_DIZIN/uyandir"

dizinleri_hazirla() {
  if [[ ! -d $DURUM_DIZIN ]]; then
    mkdir -p "$DURUM_DIZIN"
    chmod 700 "$DURUM_DIZIN"
  fi
  # Ust dizin ($XDG_RUNTIME_DIR) her zaman vardir.
  [[ -d $CALISMA_DIZIN ]] || mkdir -m 700 "$CALISMA_DIZIN"
}

# --- bicimlendirme ---------------------------------------------------------

# Sonuc $BICIM'e yazilir; komut ikamesi (fork) dongude kullanilamaz.

sn_bicim() { # 91 -> 01:31   3725 -> 1:02:05
  local t=$1
  if ((t >= 3600)); then
    printf -v BICIM '%d:%02d:%02d' $((t / 3600)) $(((t / 60) % 60)) $((t % 60))
  else
    printf -v BICIM '%02d:%02d' $((t / 60)) $((t % 60))
  fi
}

dk_bicim() { # 6320 -> "1h 45m"
  local t=$1
  if ((t >= 3600)); then
    printf -v BICIM '%dh %dm' $((t / 3600)) $(((t % 3600) / 60))
  else
    printf -v BICIM '%dm' $((t / 60))
  fi
}

# Sirasi onemli: & once, yoksa sonraki varliklarin & isareti ikinci kez
# kacirilir. Degistirme dizesindeki & bash 5.2'de ESLESEN METNE genisler,
# bu yuzden ters boluyle kacirilir.
pango_kacir() {
  local s=$1
  s=${s//&/\&amp;}
  s=${s//</\&lt;}
  s=${s//>/\&gt;}
  printf '%s' "$s"
}

json_kacir() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '%s' "$s"
}

kisalt() {
  local s=$1
  if ((${#s} > AD_SINIR)); then printf '%s…' "${s:0:AD_SINIR}"; else printf '%s' "$s"; fi
}

# --- oturum dosyasi --------------------------------------------------------

oturum_oku() {
  [[ -f $OTURUM ]] || return 1
  {
    read -r MOD BAS BIT UYARILDI &&
      read -r ONCE_BUGUN ONCE_TOPLAM &&
      IFS= read -r BAS_SAAT &&
      IFS= read -r AD &&
      IFS= read -r AD_GOSTER &&
      IFS= read -r AD_BALON
  } <"$OTURUM" || return 1
}

oturum_yaz() {
  dizinleri_hazirla
  printf '%s %s %s %s\n%s %s\n%s\n%s\n%s\n%s\n' \
    "$MOD" "$BAS" "$BIT" "$UYARILDI" \
    "$ONCE_BUGUN" "$ONCE_TOPLAM" \
    "$BAS_SAAT" "$AD" "$AD_GOSTER" "$AD_BALON" >"$OTURUM"
}

# Gorev adinin panel ve balon icin hazirlanmis halleri; her ikisi de hem pango
# hem JSON acisindan guvenli. Dongu bu yuzden ad uzerinde hicbir is yapmaz.
ad_turet() {
  AD=$1
  AD_GOSTER=$(json_kacir "$(pango_kacir "$(kisalt "$1")")")
  AD_BALON=$(json_kacir "$(pango_kacir "$1")")
}

# --- kilit ve uyandirma ----------------------------------------------------

# Yalnizca durum DEGISTIREN yollar kilit alir; asagidaki yardimcilar kilidin
# cagiran tarafindan alindigini varsayar.

kilitle() {
  dizinleri_hazirla
  exec 9>"$KILIT"
  flock 9
}

kilit_ac() { exec 9>&-; }

# Dongunun bir sonraki saniyeyi beklemeden tazelenmesi icin. FIFO okuma-yazma
# aciliyor, boylece okuyucu yoksa da yazma bloklamaz.
uyandir() {
  [[ -p $FIFO ]] || return 0
  printf . 1<>"$FIFO" 2>/dev/null || true
}

# --- timewarrior -----------------------------------------------------------

timew_aktif() { [[ $(timew get dom.active 2>/dev/null) == 1 ]]; }

# $1: gorev adi -> "bugun_saniye toplam_saniye". Tek gecis: defter iki kez
# okunmaz. Gunluk toplam gece yarisinda kirpilir, yoksa geceyi asan bir aralik
# bugune butunuyle yazilirdi. Yalnizca KAPANMIS araliklar sayilir; calisan
# aralik panelde ustune eklenir.
toplamlar() {
  local v gun0
  gun0=$(date -d 'today 00:00' +%s)
  v=$(timew export :all 2>/dev/null | jq -r --arg t "$1" --argjson g "$gun0" '
        [ .[]
          | select(.end != null and ((.tags // []) | index($t)))
          | { s: (.start | strptime("%Y%m%dT%H%M%SZ") | mktime),
              e: (.end   | strptime("%Y%m%dT%H%M%SZ") | mktime) } ]
        | ((map(.e - .s) | add) // 0) as $tum
        | ((map(select(.e > $g) | .e - (if .s > $g then .s else $g end)) | add) // 0) as $bugun
        | "\($bugun) \($tum)"' 2>/dev/null) || v='0 0'
  [[ $v =~ ^[0-9]+\ [0-9]+$ ]] || v='0 0'
  printf '%s' "$v"
}

# En son kullanilan ustte olacak sekilde, tekrarsiz gorev adlari.
gecmis_listesi() {
  local baslangic
  baslangic=$(date -d "$GECMIS_GUN days ago" +%F)
  timew export "$baslangic" - now 2>/dev/null | jq -r '
      sort_by(.start) | reverse
      | [ .[].tags[0]? ]
      | reduce .[] as $t ([]; if index($t) then . else . + [$t] end)
      | .[]' 2>/dev/null | head -n 30 || true
}

# --- durum gecisleri -------------------------------------------------------

# Kilit alinmis ve oturum_oku basariyla cagrilmis olmali.
bitir() {
  local sure_sn=$((EPOCHSECONDS - BAS))
  if timew_aktif; then
    if ! timew stop >/dev/null 2>&1; then
      if ((sure_sn < 2)); then
        # timew saniye cozunurlugundedir ve baslangicla ayni saniyede biten
        # araligi kaydetmeyi reddeder; zaten kayda deger bir sey yok.
        timew cancel >/dev/null 2>&1 || true
      else
        # Baska bir nedenle kaydedilemedi: oturum dosyasi DURUYOR, boylece
        # panel ile defter ayrisimaz ve sure kaybolmaz.
        notify-send -u critical -a tw-timer 'Could not save time' "$(pango_kacir "$AD")" || true
        return 1
      fi
    fi
  else
    # Disaridan "timew stop" yapilmis. Panel temizlenir ama yapilmamis bir
    # kayit bildirilmez.
    rm -f "$OTURUM"
    notify-send -u low -a tw-timer 'Timer was already stopped' "$(pango_kacir "$AD")" || true
    return 0
  fi
  rm -f "$OTURUM"
  dk_bicim "$sure_sn"
  notify-send -u low -a tw-timer 'Saved' "$(pango_kacir "$AD") - $BICIM" || true
}

# Kilit alinmis ve oturum_oku basariyla cagrilmis olmali.
iptal() {
  timew cancel >/dev/null 2>&1 || true
  rm -f "$OTURUM"
  notify-send -u low -a tw-timer 'Discarded' "$(pango_kacir "$AD")" || true
}

# Kilit alinmis olmali. $1: gorev adi, $2: geri | serbest
baslat() {
  local ad=$1 modu=$2 cikti
  if timew_aktif; then
    if oturum_oku; then
      bitir
    else
      timew stop >/dev/null 2>&1 || true
      rm -f "$OTURUM"
    fi
  fi
  # Deftere yalnizca gorev adi yazilir.
  if ! cikti=$(timew start "$ad" 2>&1); then
    notify-send -u critical -a tw-timer 'Could not start timer' "$(pango_kacir "$cikti")" || true
    return 0
  fi
  MOD=$modu
  BAS=$EPOCHSECONDS
  if [[ $modu == geri ]]; then BIT=$((BAS + VARSAYILAN_DK * 60)); else BIT=0; fi
  UYARILDI=0
  read -r ONCE_BUGUN ONCE_TOPLAM <<<"$(toplamlar "$ad")"
  printf -v BAS_SAAT '%(%H:%M)T' "$BAS"
  ad_turet "$ad"
  oturum_yaz
}

# Kilit alinmis olmali. Panel durumunu deftere gore duzeltir.
resync() {
  if ! timew_aktif; then
    rm -f "$OTURUM"
    return 0
  fi
  local bilgi bas ad
  # Alanlar ayri SATIR olarak alinir: @tsv gorev adindaki ters boluyu
  # kacirir ve adi bozardi.
  bilgi=$(timew get dom.active.json | jq -r '
      (.start | strptime("%Y%m%dT%H%M%SZ") | mktime),
      (.tags[0] // "Untitled")')
  {
    IFS= read -r bas
    IFS= read -r ad
  } <<<"$bilgi"

  # Ayni aralik zaten izleniyorsa dokunulmaz; mod, bitis ve uzatmalar korunur.
  if oturum_oku && [[ $BAS == "$bas" ]]; then
    return 0
  fi

  # Panel disinda baslatilmis aralik: plan bilgisi yok, serbest sayilir.
  MOD=serbest
  BIT=0
  UYARILDI=0
  BAS=$bas
  read -r ONCE_BUGUN ONCE_TOPLAM <<<"$(toplamlar "$ad")"
  printf -v BAS_SAAT '%(%H:%M)T' "$BAS"
  ad_turet "$ad"
  oturum_yaz
}

# --- panel dongusu ---------------------------------------------------------

bos_json() {
  printf '{"text":"%s","tooltip":"%s","class":"bos"}\n' "$IKON_GERI" "$IPUCU_BOS"
}

# Tek printf; alt surec yok.
durum_json() {
  local gecen=$((EPOCHSECONDS - BAS)) ikon sinif sure kalan
  local ikinciSatir='' tekerlek='' gecenStr bugunStr toplamStr

  if [[ $MOD == geri ]]; then
    ikon=$IKON_GERI
    kalan=$((BIT - EPOCHSECONDS))
    if ((kalan > 0)); then
      sn_bicim "$kalan"
      sure=$BICIM
      ikinciSatir="Remaining  $BICIM\\n"
      if ((kalan <= UYARI_SN)); then sinif=uyari; else sinif=geri; fi
    else
      # Sure doldu: durmaz, mesai fazlasi olarak ileri sayar.
      sn_bicim $((-kalan))
      sure="+$BICIM"
      ikinciSatir="Overtime   +$BICIM\\n"
      sinif=mesai
    fi
    tekerlek='   Scroll: adjust time'
  else
    ikon=$IKON_SERBEST
    sinif=serbest
    sn_bicim "$gecen"
    sure=$BICIM
  fi

  sn_bicim "$gecen"
  gecenStr=$BICIM
  dk_bicim $((ONCE_BUGUN + gecen))
  bugunStr=$BICIM
  dk_bicim $((ONCE_TOPLAM + gecen))
  toplamStr=$BICIM

  printf '{"text":"%s %s · %s","tooltip":"<b>%s</b>\\nStarted    %s\\nElapsed    %s\\n%sToday      %s\\nTotal      %s\\n\\nClick: switch task   Right click: stop and save%s","class":"%s"}\n' \
    "$ikon" "$sure" "$AD_GOSTER" \
    "$AD_BALON" "$BAS_SAAT" "$gecenStr" "$ikinciSatir" "$bugunStr" "$toplamStr" "$tekerlek" \
    "$sinif"
}

# Geri sayim sifirlandiginda BIR KEZ uyarir. Bayrak oturum dosyasinda tutulur,
# panel yeniden baslarsa uyari tekrarlanmaz.
sure_doldu_uyar() {
  kilitle
  if oturum_oku && ((UYARILDI == 0)); then
    UYARILDI=1
    oturum_yaz
    notify-send -u critical -a tw-timer 'Time is up' \
      "$(pango_kacir "$AD") - now counting overtime" || true
  fi
  kilit_ac
}

komut_feed() {
  dizinleri_hazirla
  [[ -p $FIFO ]] || {
    rm -f "$FIFO"
    mkfifo -m 600 "$FIFO"
  }
  # Hem okuma hem yazma icin acilir: yazan olmadiginda EOF gelmez, boylece
  # dongu okuma uzerinde uyuyabilir.
  exec 8<>"$FIFO"

  kilitle
  resync
  kilit_ac

  local _
  while :; do
    if oturum_oku; then
      if [[ $MOD == geri ]] && ((UYARILDI == 0)) && ((EPOCHSECONDS >= BIT)); then
        sure_doldu_uyar
        oturum_oku || true
      fi
      durum_json
      # Saniyede bir; tiklama gelirse daha erken.
      read -r -t 1 -n 1 -u 8 _ || true
    else
      bos_json
      # Bosta hicbir sey hesaplanmaz: yeni gorev secilene kadar beklenir.
      read -r -n 1 -u 8 _ || true
    fi
  done
}

# --- kullanici komutlari ---------------------------------------------------

komut_pick() {
  kilitle
  resync
  kilit_ac

  local -a satirlar=()
  if oturum_oku; then satirlar+=("$DURDUR_SATIR" "$IPTAL_SATIR"); fi
  local sat
  while IFS= read -r sat; do
    [[ -n $sat ]] && satirlar+=("$sat")
  done < <(gecmis_listesi)

  # Genel temada mainbox'ta mode-switcher var; dmenu'de o yok, yerine ipucu
  # satiri gosteriliyor. Override yalnizca bu cagri icin gecerli.
  local -a ropt=(
    -dmenu -i
    -p Task
    -mesg "Enter: $VARSAYILAN_DK min countdown     Alt+Enter: free running"
    -kb-custom-1 Alt+Return
    -theme-str 'window { width: 520px; } mainbox { children: [ inputbar, message, listview ]; } listview { lines: 8; }'
  )

  local secim='' kod=0
  if ((${#satirlar[@]} == 0)); then
    secim=$(rofi "${ropt[@]}" </dev/null) || kod=$?
  else
    secim=$(printf '%s\n' "${satirlar[@]}" | rofi "${ropt[@]}") || kod=$?
  fi

  local modu
  case $kod in
    0) modu=geri ;;
    10) modu=serbest ;;
    *) return 0 ;;
  esac

  kilitle
  case $secim in
    "$DURDUR_SATIR")
      if oturum_oku; then bitir; fi
      ;;
    "$IPTAL_SATIR")
      if oturum_oku; then iptal; fi
      ;;
    *)
      local ad=$secim
      ad=${ad//$'\t'/ }
      ad=${ad#"${ad%%[![:space:]]*}"}
      ad=${ad%"${ad##*[![:space:]]}"}
      if [[ -n $ad ]]; then baslat "$ad" "$modu"; fi
      ;;
  esac
  kilit_ac
  uyandir
}

komut_stop() {
  kilitle
  if oturum_oku; then bitir; fi
  kilit_ac
  uyandir
}

komut_extend() {
  local d=$1
  [[ $d =~ ^[+-]?[0-9]+$ ]] || return 0
  kilitle
  if oturum_oku && [[ $MOD == geri ]]; then
    local yeni=$((BIT + d * 60)) alt=$((EPOCHSECONDS + 60))
    if ((yeni < alt)); then yeni=$alt; fi # en az bir dakika kalsin
    BIT=$yeni
    UYARILDI=0 # yeni bitiste yeniden uyarilsin
    oturum_yaz
  fi
  kilit_ac
  uyandir
}

case "${1:-}" in
  feed) komut_feed ;;
  pick) komut_pick ;;
  stop) komut_stop ;;
  extend) komut_extend "${2:-0}" ;;
  *)
    printf 'kullanim: tw-timer feed|pick|stop|extend <dk>\n' >&2
    exit 2
    ;;
esac
