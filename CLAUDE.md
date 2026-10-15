## Sistem Güvenlik İlkeleri

| **Least Privilege** | Her özne, işini yapmaya yetecek _en az_ yetkiye sahip olmalı. |
| **Fail Secure / Fail Closed** | Bir bileşen çöktüğünde varsayılan davranış "izin ver" değil "reddet" olmalı. |
| **Zero Trust** | "Ağın içinde" olmak güven sebebi değildir. |
| **Attack Surface Reduction** | Çalışmayan kod saldırılamaz koddur. Gereksiz servis, port, paket, özellik = kaldırılır. |
| **Secure by Default** | Kutudan çıktığı hâli güvenli olmalı; güvenlik kullanıcının sonradan açtığı bir seçenek değil. |
| **Separation of Duties** | Tek bir aktör kritik bir eylemi baştan sona tek başına tamamlayamamalı. |
| **Economy of Mechanism (KISS)** | Basit tasarım denetlenebilir; karmaşıklık güvenliğin bir numaralı düşmanıdır. |
| **Psychological Acceptability** | Kullanıcıyı yoran güvenlik atlatılır. Kullanılamayan hardening, uygulanmayan hardening'dir. |
| **Blast Radius / Compartmentalization** | İhlal _olacak_ varsayımıyla tasarla; sınırla, izole et, yayılmayı kes. |
| **CIA Triad** | Confidentiality, Integrity, Availability. Hardening birini artırırken diğerini düşürüyorsa tasarım hatalıdır. |

**"Hardening zafiyete sebep olmamalı"** —

## Kodlama & Tasarım İlkeleri

**Temel mottolar**

- **KISS** — Keep It Simple, Stupid.
- **YAGNI** — You Aren't Gonna Need It. İhtiyaç doğmadan soyutlama yazma.
- **DRY** — Don't Repeat Yourself. (Karşı-dengesi: **AHA** — _Avoid Hasty Abstractions_; yanlış soyutlama, kopyalamadan pahalıdır.)
- **Separation of Concerns** — her modül tek bir şeyden sorumlu.
- **Make it work → make it right → make it fast** — bu sırayla.
- **Premature optimization is the root of all evil** (Knuth) — ölçmeden optimize etme.
- **Boy Scout Rule** — dokunduğun kodu bulduğundan temiz bırak.
- **Chesterton's Fence** — neden orada olduğunu anlamadan çiti sökme.

---

| **Occam's Razor** | En az varsayım gerektiren açıklama tercih edilir. |
| **Murphy's Law** | Ters gidebilecek olan ters gider — bu yüzden failure mode'u tasarla. |

##

| **Yorum Satırları** | Yorum Satırları az ve öz olmalıdır. Gereksiz açıklama ve bilgi barındırmamalı. Yorum satırları, debuging sırasında oluşan tecrübeleri barındırmamalı. Yorum satırları anlatı içermemeli. ----Yalnızca gerektiğinde kodun çalışma mekanizmasını, kodun ne yaptığını veya zorunlu uyarıları içermelidir.----

---

## Etik & Meslek

- **Responsible / Coordinated Disclosure** — zafiyeti önce sahibine bildir, süre tanı.
- **Authorization first** — izinsiz test, test değil saldırıdır. Kapsam (scope) yazılıdır.
- **Need to know** — bilgiye erişim, göreve bağlıdır.
- **Privacy by Design** & **Data Minimization** — toplamadığın veriyi sızdıramazsın.

---

!!!! :\*\* Nixos kullanıyorum. Sistemi benimle beraber sen-Claude- ayakta tutacaksın. Yukarıdaki kuralların tüm sistemde uygulandığını teyit et. Özetle: Sistemi, Basit tut, az yetki ver, hiçbir şeye güvenme, her şeyi doğrula, ihlal olacağını varsay — ve koruduğun sistemi kırma.\_

1. Kesin talimat gelmeden dosyalara yazma. --Herhangi bir konumdaki dosyalara yazma, çalışman için zorunlu olan scratcpad hariç--
2. Git ve github ile ilgili herhangi bir eylemde bulunma. --ancak izin verilen konumdaki git dosyalarını ve geçmişini okuma iznin var. Git ile ilgili network gerektirmeyen local işlemleri yapabilirsin--
