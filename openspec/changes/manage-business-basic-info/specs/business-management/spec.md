## ADDED Requirements

### Requirement: Temel Bilgiler Düzenleme

İşletme sahipleri mobil uygulamadan işletme temel bilgilerini düzenleyebilmelidir. Sistem SHALL allow business owners to edit basic business information from the mobile application.

#### Scenario: İşletme adı ve açıklama güncelleme

**GIVEN** kullanıcı işletme sahibi olarak giriş yapmış  
**AND** yönetim panelinde "Temel Bilgiler" ekranında  
**WHEN** işletme adını ve açıklamasını değiştirip kaydet butonuna bastığında  
**THEN** sistem venues tablosunda name ve description alanlarını günceller  
**AND** değişiklikler anında venue details ekranında görünür  
**AND** kullanıcıya "Değişiklikler kaydedildi" mesajı gösterilir

#### Scenario: İletişim bilgileri güncelleme

**GIVEN** kullanıcı temel bilgiler ekranında  
**WHEN** telefon ve e-posta adresini girip kaydeder  
**THEN** sistem phone ve email alanlarını günceller  
**AND** telefon numarası formatı doğrulanır (+90 5XX XXX XX XX)  
**AND** e-posta formatı doğrulanır (xxx@xxx.xxx)  
**AND** geçersiz format durumunda hata mesajı gösterilir

#### Scenario: Sosyal medya linkleri ekleme

**GIVEN** kullanıcı temel bilgiler ekranında  
**WHEN** Instagram, WhatsApp, Facebook ve Website linklerini girip kaydeder  
**THEN** sistem social_links JSONB alanını günceller  
**AND** URL formatları doğrulanır (https:// ile başlamalı)  
**AND** WhatsApp için telefon numarası formatı doğrulanır  
**AND** geçersiz URL durumunda hata mesajı gösterilir

---

### Requirement: Çalışma Saatleri Yönetimi

İşletme sahipleri haftalık çalışma saatlerini düzenleyebilmelidir. Sistem SHALL allow business owners to manage weekly working hours.

#### Scenario: Günlük çalışma saatleri ayarlama

**GIVEN** kullanıcı çalışma saatleri ekranında  
**WHEN** bir gün için açılış ve kapanış saatlerini seçip kaydeder  
**THEN** sistem working_hours JSONB alanını günceller  
**AND** açılış saati kapanış saatinden önce olmalıdır  
**AND** saat formatı 24 saat olmalıdır (HH:MM)  
**AND** geçersiz saat aralığında hata mesajı gösterilir

#### Scenario: Kapalı gün belirleme

**GIVEN** kullanıcı çalışma saatleri ekranında  
**WHEN** bir gün için "Kapalı" switch'ini aktif eder  
**THEN** sistem o gün için working_hours'da open: false kaydeder  
**AND** saat seçimi devre dışı kalır  
**AND** venue details'da o gün "Kapalı" olarak görünür

#### Scenario: Tüm günlere aynı saatleri uygulama

**GIVEN** kullanıcı çalışma saatleri ekranında  
**AND** bir gün için saat ayarlamış  
**WHEN** "Tüm Günler İçin Uygula" butonuna basar  
**THEN** sistem seçili saatleri tüm günlere kopyalar  
**AND** kullanıcıya onay mesajı gösterilir

---

### Requirement: Konum ve Adres Yönetimi

İşletme sahipleri işletme konumunu ve adresini güncelleyebilmelidir. Sistem SHALL allow business owners to update location and address information.

#### Scenario: Harita üzerinden konum seçme

**GIVEN** kullanıcı konum ekranında  
**WHEN** harita üzerinde bir nokta seçer ve kaydeder  
**THEN** sistem latitude, longitude ve location (PostGIS) alanlarını günceller  
**AND** seçilen konum marker ile haritada gösterilir  
**AND** koordinatlar doğru formatta kaydedilir

#### Scenario: Adres girişi ve güncelleme

**GIVEN** kullanıcı konum ekranında  
**WHEN** adres text field'ına yeni adres yazar ve kaydeder  
**THEN** sistem address alanını günceller  
**AND** adres boş bırakılamaz  
**AND** adres en az 10 karakter olmalıdır

#### Scenario: İl ve ilçe seçimi

**GIVEN** kullanıcı konum ekranında  
**WHEN** il ve ilçe dropdown'larından seçim yapar  
**THEN** sistem province_id ve district_id alanlarını günceller  
**AND** ilçe listesi seçilen ile göre filtrelenir

---

### Requirement: Form Validasyonu

Tüm form girişleri doğrulanmalı ve hatalı veri kaydedilmemelidir. Sistem SHALL validate all form inputs and prevent invalid data from being saved.

#### Scenario: Zorunlu alan kontrolü

**GIVEN** kullanıcı herhangi bir form ekranında  
**WHEN** zorunlu bir alanı boş bırakıp kaydet butonuna basar  
**THEN** sistem "Bu alan zorunludur" hata mesajı gösterir  
**AND** form kaydedilmez  
**AND** hatalı alan vurgulanır

#### Scenario: Format validasyonu

**GIVEN** kullanıcı telefon, e-posta veya URL alanına veri giriyor  
**WHEN** geçersiz format girip kaydet butonuna basar  
**THEN** sistem ilgili format hatasını gösterir  
**AND** doğru format örneği hint text olarak gösterilir  
**AND** form kaydedilmez

---

### Requirement: Güvenlik ve Yetkilendirme

Sadece işletme sahibi kendi işletmesinin bilgilerini düzenleyebilmelidir. Sistem SHALL ensure only the business owner can edit their own business information.

#### Scenario: Yetkili kullanıcı düzenleme

**GIVEN** kullanıcı owner_id'si ile eşleşen bir venue'ya sahip  
**WHEN** temel bilgileri güncellemeye çalışır  
**THEN** sistem güncellemeye izin verir  
**AND** RLS politikası kontrolü geçer

#### Scenario: Yetkisiz kullanıcı engelleme

**GIVEN** kullanıcı owner_id'si ile eşleşmeyen bir venue'ya erişmeye çalışıyor  
**WHEN** bilgileri güncellemeye çalışır  
**THEN** sistem "Yetkiniz yok" hatası döner  
**AND** RLS politikası güncellemeyi engeller  
**AND** kullanıcıya hata mesajı gösterilir

---

### Requirement: Gerçek Zamanlı Senkronizasyon

Yapılan değişiklikler anında uygulamanın diğer bölümlerinde görünmelidir. Sistem SHALL synchronize changes in real-time across the application.

#### Scenario: Venue details otomatik güncelleme

**GIVEN** kullanıcı temel bilgileri güncellemiş  
**WHEN** venue details ekranına geri döner  
**THEN** güncellenmiş bilgiler anında görünür  
**AND** sayfa yenilenmesine gerek yoktur  
**AND** provider listeners tetiklenir

#### Scenario: Arama sonuçlarında güncelleme

**GIVEN** kullanıcı işletme adını değiştirmiş  
**WHEN** başka bir kullanıcı arama yapar  
**THEN** yeni işletme adı arama sonuçlarında görünür  
**AND** eski ad artık görünmez

---

### Requirement: Kullanıcı Deneyimi

Form etkileşimleri kullanıcı dostu ve sezgisel olmalıdır. Sistem SHALL provide user-friendly and intuitive form interactions.

#### Scenario: Loading states

**GIVEN** kullanıcı bir form gönderiyor  
**WHEN** Supabase isteği devam ediyor  
**THEN** kaydet butonu devre dışı kalır  
**AND** loading indicator gösterilir  
**AND** kullanıcı birden fazla istek gönderemez

#### Scenario: Başarı bildirimi

**GIVEN** kullanıcı formu başarıyla göndermiş  
**WHEN** Supabase güncellemesi tamamlanır  
**THEN** yeşil SnackBar ile "Değişiklikler kaydedildi" mesajı gösterilir  
**AND** mesaj 3 saniye sonra kaybolur

#### Scenario: Hata bildirimi

**GIVEN** kullanıcı formu gönderiyor  
**WHEN** Supabase hatası oluşur  
**THEN** kırmızı SnackBar ile hata mesajı gösterilir  
**AND** hata detayı log'lanır  
**AND** kullanıcı tekrar deneyebilir

---

### Requirement: Optimistic Updates

UI güncellemeleri sunucu yanıtı beklenmeden yapılmalıdır. Sistem SHALL perform UI updates optimistically without waiting for server response.

#### Scenario: Anında UI güncelleme

**GIVEN** kullanıcı bir değişiklik yapıyor  
**WHEN** kaydet butonuna basar  
**THEN** UI anında güncellenir (optimistic)  
**AND** arka planda Supabase isteği gönderilir  
**AND** hata durumunda eski değere geri döner

#### Scenario: Hata durumunda rollback

**GIVEN** kullanıcı optimistic update yapmış  
**WHEN** Supabase hatası döner  
**THEN** UI eski değere geri döner  
**AND** kullanıcıya hata mesajı gösterilir  
**AND** değişiklik kaydedilmemiş olarak işaretlenir
