# CLAUDE.md

1. Kesin talimat gelmeden dosyalara dokunulmayacak.
2. git ve github ile ilgili hiçbir işlem yapma.
3. tek kullanıcılı ve tek bilgisayar kullanıyorum.

system hardening hakkında:

1. hardening zaafiyete sebep olmamalı --bu ana kuraldır. diğer kurallar bu kuralı hiçbir şekilde override edemez--.
2. network güvenliği üst seviyede tutulacak --beklenen davranış anonimlik değildir. mahremiyet ve gizlilik mümkün olduğunca sıkı tutulacak.--
3. sistem gereksiz paket, yapı ve bağımlılık barındırmamalı.
4. sistem varsayılan olarak minimal tutulacak. kullanıcının kullanımına göre ek özellikler ve davranışlar eklenecek.
   ama varsayılan olarak hardaening e meyil edilecek.
5. kernel hardening kullanıcının niyetine göre optimum ama -hardeninge meyilli- şekilde olacak. kullanılmayan servis, yapı ve davrnışlar varsayılan kapalı tutulacak.
6. sistem tutarlı olmalıdır. modüller bir biriyle çelişmemeli ve çakışmamalıdır. sistem bütünlüğü ve uyumluluğu sağlanmalıdır.
   tercihler:

7. msi all in one tek kullanıcı erişimi bir pc kullanıyorum. disk şifreleme kullanılmayacak.
8. hashde password sadece kullanıcı şifresi için. kullanım senaryosu şöyle olacak, sistem ilk kurulumda manuel olarak root şifresi belirlenecek.
9. ***
10. latest kernel tercih edilcek.
11. sistem genelinde güvenlik ve kontrol için zorunlu olanlar hariç gereksiz loglama işlemi önlenecek. ama zaruri olanlar açık bırakılacak.
12. bluetooth, thunderbolt gibi gereksiz servisler kullanılmayacak.

önemli not : kullanıcı nixos öğrenmeye çalışıyor. nixos ve hardening bilgisi yeterli değil. o yüzden ai olarak sen,
kullanıcının farkında olmadığı ama niyetiyle uyumlu olan herhangi bir konuda açıklama yaparak uyarmak zorundasın.
mutlaka kullanıcının bilipte isteyebileceği bir davranış fark ettiğinde uyar.
