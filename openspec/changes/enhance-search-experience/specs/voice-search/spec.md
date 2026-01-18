# Sesli Arama

## ADDED Requirements

### Requirement: Sesli Arama Başlatma

Kullanıcılar arama çubuğundaki mikrofon butonuna tıklayarak sesli arama başlatabilmelidir. Sistem konuşmayı dinler ve metne dönüştürerek arama input'una yazar.

#### Scenario: Sesli Arama Başarıyla Başlatılıyor

**Given** Kullanıcı arama ekranındadır  
**And** Mikrofon izni verilmiştir  
**And** Cihazda sesli arama özelliği mevcuttur  
**When** Kullanıcı mikrofon butonuna tıkladığında  
**Then** Sesli arama dialog'u açılır  
**And** "Dinliyorum..." mesajı gösterilir  
**And** Mikrofon ikonu pulse animasyonu oynatır  
**And** Sistem konuşmayı dinlemeye başlar

#### Scenario: Konuşma Metne Dönüştürülüyor

**Given** Kullanıcı sesli arama başlatmıştır  
**And** Sistem dinleme modundadır  
**When** Kullanıcı "Saç kesimi" dediğinde  
**Then** Konuşma gerçek zamanlı olarak metne dönüştürülür  
**And** "Saç kesimi" metni dialog'da gösterilir  
**And** Kullanıcı konuşmayı bitirdiğinde metin arama input'una yazılır  
**And** Arama otomatik olarak başlatılır

#### Scenario: Sesli Arama İptal Edilebilir

**Given** Kullanıcı sesli arama başlatmıştır  
**And** Dialog açıktır  
**When** Kullanıcı "İptal" butonuna tıkladığında  
**Then** Dinleme durdurulur  
**And** Dialog kapanır  
**And** Arama input'u değişmez

### Requirement: Mikrofon İzni Yönetimi

Sesli arama özelliğini kullanabilmek için kullanıcıdan mikrofon izni alınmalıdır. İzin verilmediği durumlarda kullanıcı bilgilendirilmelidir.

#### Scenario: İlk Kullanımda İzin İsteme

**Given** Kullanıcı uygulamayı ilk kez kullanmaktadır  
**And** Mikrofon izni henüz verilmemiştir  
**When** Kullanıcı mikrofon butonuna tıkladığında  
**Then** Sistem izin dialog'u gösterir  
**And** Dialog "Sesli arama için mikrofon iznine ihtiyacımız var" mesajını içerir  
**And** Kullanıcı "İzin Ver" veya "Reddet" seçeneklerini görür

#### Scenario: İzin Verildiğinde Sesli Arama Başlatılıyor

**Given** Kullanıcı mikrofon butonuna tıklamıştır  
**And** İzin dialog'u gösterilmiştir  
**When** Kullanıcı "İzin Ver" seçeneğine tıkladığında  
**Then** Mikrofon izni verilir  
**And** Sesli arama otomatik olarak başlatılır  
**And** Dinleme dialog'u açılır

#### Scenario: İzin Reddedildiğinde Kullanıcı Bilgilendiriliyor

**Given** Kullanıcı mikrofon butonuna tıklamıştır  
**And** İzin dialog'u gösterilmiştir  
**When** Kullanıcı "Reddet" seçeneğine tıkladığında  
**Then** İzin reddedilir  
**And** "Sesli arama kullanabilmek için mikrofon iznine ihtiyacımız var" mesajı gösterilir  
**And** "Ayarlara Git" butonu gösterilir  
**And** Mikrofon butonu disabled duruma geçer

#### Scenario: Ayarlardan İzin Verme

**Given** Kullanıcı mikrofon iznini reddetmiştir  
**And** "Ayarlara Git" mesajı gösterilmiştir  
**When** Kullanıcı "Ayarlara Git" butonuna tıkladığında  
**Then** Uygulama ayarları sayfası açılır  
**And** Kullanıcı mikrofon iznini manuel olarak verebilir

### Requirement: Türkçe Dil Desteği

Sesli arama özelliği Türkçe dilini desteklemelidir. Kullanıcılar Türkçe konuştuklarında doğru bir şekilde tanınmalıdır.

#### Scenario: Türkçe Konuşma Tanıma

**Given** Kullanıcı sesli arama başlatmıştır  
**And** Sistem Türkçe locale ile yapılandırılmıştır  
**When** Kullanıcı "Manikür pedikür" dediğinde  
**Then** Konuşma "Manikür pedikür" olarak tanınır  
**And** Türkçe karakterler doğru şekilde işlenir (ü, ö, ç, ş, ğ, ı)  
**And** Metin arama input'una yazılır

#### Scenario: Türkçe Özel İsimler Tanıma

**Given** Kullanıcı sesli arama başlatmıştır  
**When** Kullanıcı "Botoks" dediğinde  
**Then** Konuşma "Botoks" olarak tanınır  
**And** Kelime doğru şekilde yazılır

### Requirement: Hata Yönetimi

Sesli arama sırasında oluşabilecek hatalar kullanıcıya net bir şekilde bildirilmelidir.

#### Scenario: Mikrofon Kullanılamıyor Hatası

**Given** Kullanıcı sesli arama başlatmaya çalışmıştır  
**And** Cihazın mikrofonu başka bir uygulama tarafından kullanılmaktadır  
**When** Sistem mikrofona erişmeye çalıştığında  
**Then** "Mikrofon şu anda kullanılamıyor" hata mesajı gösterilir  
**And** Kullanıcıya "Tekrar Dene" seçeneği sunulur

#### Scenario: Konuşma Tanınamadı Hatası

**Given** Kullanıcı sesli arama başlatmıştır  
**And** Sistem dinleme modundadır  
**When** Kullanıcı 5 saniye boyunca konuşmadığında  
**Then** "Konuşmanızı anlayamadık, lütfen tekrar deneyin" mesajı gösterilir  
**And** Dinleme otomatik olarak durdurulur  
**And** Kullanıcı "Tekrar Dene" butonuna tıklayabilir

#### Scenario: Ağ Bağlantısı Hatası (Cloud STT Kullanılıyorsa)

**Given** Kullanıcı sesli arama başlatmıştır  
**And** Cihazın internet bağlantısı yoktur  
**And** Cloud-based STT servisi kullanılmaktadır  
**When** Sistem konuşmayı işlemeye çalıştığında  
**Then** "İnternet bağlantınızı kontrol edin" hata mesajı gösterilir  
**And** Kullanıcı offline STT'ye geçiş yapabilir (varsa)

### Requirement: Sesli Arama UI/UX

Sesli arama deneyimi kullanıcı dostu, modern ve etkileşimli olmalıdır.

#### Scenario: Mikrofon Butonu Görünümü

**Given** Kullanıcı arama ekranındadır  
**When** Arama çubuğu gösterildiğinde  
**Then** Arama input'unun sağ tarafında mikrofon ikonu gösterilir  
**And** İkon primary renkte gösterilir  
**And** İkona tıklandığında haptic feedback verilir

#### Scenario: Dinleme Animasyonu

**Given** Kullanıcı sesli arama başlatmıştır  
**When** Sistem dinleme modundayken  
**Then** Mikrofon ikonu pulse animasyonu oynatır  
**And** Animasyon ritmik ve süreklidir  
**And** İkon rengi accent color'a değişir

#### Scenario: Sesli Arama Dialog Tasarımı

**Given** Kullanıcı sesli arama başlatmıştır  
**When** Dialog gösterildiğinde  
**Then** Dialog glassmorphism efekti ile gösterilir  
**And** Üstte büyük mikrofon ikonu bulunur  
**And** Ortada "Dinliyorum..." veya tanınan metin gösterilir  
**And** Altta "İptal" butonu bulunur  
**And** Dialog animasyonlu bir şekilde açılır ve kapanır

### Requirement: Platform Uyumluluğu

Sesli arama özelliği hem iOS hem de Android platformlarında çalışmalıdır.

#### Scenario: iOS'ta Sesli Arama

**Given** Kullanıcı iOS cihazı kullanmaktadır  
**And** Mikrofon izni verilmiştir  
**When** Kullanıcı sesli arama başlattığında  
**Then** iOS native STT motoru kullanılır  
**And** Türkçe dil desteği aktiftir  
**And** Konuşma doğru şekilde tanınır

#### Scenario: Android'de Sesli Arama

**Given** Kullanıcı Android cihazı kullanmaktadır  
**And** Mikrofon izni verilmiştir  
**When** Kullanıcı sesli arama başlattığında  
**Then** Android native STT motoru kullanılır  
**And** Türkçe dil desteği aktiftir  
**And** Konuşma doğru şekilde tanınır

## MODIFIED Requirements

### Requirement: Arama Input Etkileşimi

Mevcut arama input'u sadece klavye girişi desteklemektedir. Bu requirement sesli arama girişini de destekleyecek şekilde genişletilmiştir.

#### Scenario: Sesli ve Klavye Girişi Birlikte Kullanılıyor

**Given** Kullanıcı arama ekranındadır  
**When** Kullanıcı sesli arama ile "Saç" dediğinde  
**Then** Arama input'una "Saç" yazılır  
**And** Kullanıcı klavye ile " kesimi" ekleyebilir  
**And** Final metin "Saç kesimi" olur  
**And** Arama bu metinle başlatılır

### Requirement: Arama Başlatma Tetikleyicileri

Mevcut arama sadece klavye girişi ve kategori seçimi ile başlatılabilmektedir. Bu requirement sesli arama tetikleyicisini de içerecek şekilde güncellenmiştir.

#### Scenario: Sesli Arama ile Arama Başlatma

**Given** Kullanıcı sesli arama başlatmıştır  
**And** "Botoks" demiştir  
**When** Konuşma tanımlandığında  
**Then** Arama input'una "Botoks" yazılır  
**And** Arama otomatik olarak başlatılır  
**And** Sonuçlar gösterilir

## REMOVED Requirements

_Bu değişiklik kapsamında kaldırılan requirement bulunmamaktadır._
