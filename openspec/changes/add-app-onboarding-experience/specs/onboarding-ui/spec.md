# Uygulama Onboarding UI

## ADDED Requirements

### Requirement: Onboarding Ekran Akışı
Yeni kullanıcılar uygulamayı ilk kez açtığında 6 ekranlık bir onboarding deneyimi görmeli ve uygulamanın temel özelliklerini öğrenmelidir.

#### Scenario: İlk Kez Uygulama Açılışı
**Given** Kullanıcı uygulamayı ilk kez yükledi ve açtı
**When** Splash screen tamamlandı
**Then** Kullanıcı onboarding ekranının 1. sayfasına yönlendirilir
**And** Sayfa göstergeleri "1/6" durumunu gösterir
**And** "İleri" butonu görünür durumdadır

#### Scenario: Onboarding Sayfaları Arası Geçiş
**Given** Kullanıcı onboarding ekranının 3. sayfasında
**When** Kullanıcı sağa swipe yapar veya "İleri" butonuna basar
**Then** 4. sayfaya smooth bir animasyonla geçiş yapılır
**And** Sayfa göstergeleri "4/6" olarak güncellenir
**And** Önceki sayfa animasyonu durdurulur, yeni sayfa animasyonu başlar

#### Scenario: Onboarding Tamamlama
**Given** Kullanıcı onboarding ekranının 6. sayfasında
**When** Kullanıcı "Hadi Başlayalım!" butonuna basar
**Then** Onboarding tamamlandı olarak işaretlenir (SharedPreferences)
**And** Kullanıcı ana ekrana yönlendirilir
**And** Konum onboarding kontrolü yapılır

#### Scenario: İkinci Kez Uygulama Açılışı
**Given** Kullanıcı daha önce onboarding'i tamamlamış
**When** Uygulama açılır ve splash screen tamamlanır
**Then** Onboarding atlanır
**And** Kullanıcı direkt ana ekrana yönlendirilir

### Requirement: Sayfa İçerikleri ve Animasyonlar
Her onboarding sayfası belirli bir özelliği tanıtmalı ve engaging animasyonlara sahip olmalıdır.

#### Scenario: Hoş Geldiniz Ekranı (Sayfa 1)
**Given** Kullanıcı onboarding'in 1. sayfasında
**When** Sayfa yüklenir
**Then** Logo animasyonu oynatılır (fade-in + bounce)
**And** Başlık "Güzelliğinize Değer Katan Adresler, Bir Tıkta!" gösterilir
**And** Alt metin "Türkiye'nin en kapsamlı güzellik ve bakım merkezi rehberi..." gösterilir
**And** Gradient background ve altın accent'ler görünür

#### Scenario: Kampanyalar Ekranı (Sayfa 2)
**Given** Kullanıcı onboarding'in 2. sayfasına geçti
**When** Sayfa yüklenir
**Then** Kampanya kartları aşağıdan yukarı slide-in animasyonu ile belirir
**And** Her kart sırayla (stagger) görünür
**And** Başlık "Özel Fırsatları Kaçırmayın!" gösterilir
**And** 3-4 örnek kampanya kartı görüntülenir

#### Scenario: Harita Ekranı (Sayfa 3)
**Given** Kullanıcı onboarding'in 3. sayfasına geçti
**When** Sayfa yüklenir
**Then** Harita zoom-in animasyonu oynatılır
**And** Konum pin'leri yukarıdan düşer (drop animation)
**And** Bir pin seçili durumda gösterilir ve detay kartı açılır
**And** Başlık "Yakınınızdaki Salonları Keşfedin" gösterilir

#### Scenario: Filtreleme Ekranı (Sayfa 4)
**Given** Kullanıcı onboarding'in 4. sayfasına geçti
**When** Sayfa yüklenir
**Then** Filtre chip'leri soldan sağa slide-in ile belirir
**And** Seçili filtreler highlight olur (scale + color change)
**And** Başlık "Tam İstediğiniz Gibi Filtreleyin" gösterilir
**And** Örnek filtreler (kategori, fiyat, puan) gösterilir

#### Scenario: Randevu Ekranı (Sayfa 5)
**Given** Kullanıcı onboarding'in 5. sayfasına geçti
**When** Sayfa yüklenir
**Then** Takvim expand animasyonu ile açılır
**And** Seçili tarih highlight olur
**And** Saat slotları fade-in ile belirir
**And** Başlık "Randevunuzu Hemen Oluşturun" gösterilir

#### Scenario: Favoriler Ekranı (Sayfa 6)
**Given** Kullanıcı onboarding'in 6. sayfasına geçti
**When** Sayfa yüklenir
**Then** Kalp ikonu büyür ve kırmızı olur
**And** Favori listesi yukarıdan aşağı scroll animasyonu ile gösterilir
**And** Başlık "Favorilerinizi Kaydedin, Takipte Kalın" gösterilir
**And** "Hadi Başlayalım!" butonu bounce animasyonu ile belirir

### Requirement: Navigasyon ve Etkileşim
Kullanıcılar onboarding sayfaları arasında kolayca gezinebilmeli ve akışı kontrol edebilmelidir.

#### Scenario: Swipe Gesture ile İleri Gitme
**Given** Kullanıcı herhangi bir onboarding sayfasında
**When** Kullanıcı sağa doğru swipe yapar
**Then** Bir sonraki sayfaya geçiş yapılır
**And** Geçiş animasyonu smooth oynatılır (400ms)
**And** Sayfa göstergeleri güncellenir

#### Scenario: Swipe Gesture ile Geri Gitme
**Given** Kullanıcı 3. veya daha sonraki bir sayfada
**When** Kullanıcı sola doğru swipe yapar
**Then** Bir önceki sayfaya geçiş yapılır
**And** Geçiş animasyonu smooth oynatılır
**And** Sayfa göstergeleri güncellenir

#### Scenario: İleri Butonu ile Navigasyon
**Given** Kullanıcı 1-5. sayfalardan birinde
**When** Kullanıcı "İleri" butonuna basar
**Then** Bir sonraki sayfaya geçiş yapılır
**And** Buton press animasyonu oynatılır (scale down/up)
**And** Sayfa göstergeleri güncellenir

#### Scenario: Son Sayfada Tamamlama Butonu
**Given** Kullanıcı 6. (son) sayfada
**When** Sayfa yüklenir
**Then** "İleri" butonu yerine "Hadi Başlayalım!" butonu gösterilir
**And** Buton farklı bir renk/stil ile vurgulanır
**And** Buton pulse animasyonu ile dikkat çeker

#### Scenario: Sayfa Göstergeleri (Dots)
**Given** Kullanıcı herhangi bir onboarding sayfasında
**When** Sayfa değişir
**Then** Aktif sayfa dot'u büyük ve renkli gösterilir
**And** Diğer dot'lar küçük ve soluk gösterilir
**And** Dot geçişi animasyonlu olur (smooth scale/color change)

### Requirement: Telefon Mockup Frame
Onboarding ekranları telefon frame içinde animasyonlu UI mockup'ları göstermelidir.

#### Scenario: Telefon Frame Görünümü
**Given** Kullanıcı herhangi bir onboarding sayfasında
**When** Sayfa render edilir
**Then** Modern telefon frame (rounded corners, notch) gösterilir
**And** Frame shadow ve depth efektleri ile 3D görünüm sağlanır
**And** İçerideki UI mockup'ı frame'e uygun boyutlandırılır

#### Scenario: Responsive Telefon Frame
**Given** Uygulama farklı ekran boyutlarında çalışıyor
**When** Onboarding sayfası gösterilir
**Then** Telefon frame ekran boyutuna göre ölçeklenir
**And** Küçük ekranlarda frame daha kompakt gösterilir
**And** Tablet'lerde frame merkezi konumda ve optimal boyutta gösterilir

### Requirement: Onboarding Durumu Yönetimi
Onboarding'in tamamlanıp tamamlanmadığı kalıcı olarak saklanmalı ve yönetilmelidir.

#### Scenario: İlk Açılışta Durum Kontrolü
**Given** Uygulama açılıyor
**When** Splash screen initialization sırasında
**Then** SharedPreferences'tan `hasSeenOnboarding` değeri okunur
**And** Değer `false` veya null ise onboarding gösterilir
**And** Değer `true` ise onboarding atlanır

#### Scenario: Onboarding Tamamlama Kaydı
**Given** Kullanıcı son sayfada "Hadi Başlayalım!" butonuna bastı
**When** Onboarding tamamlanıyor
**Then** SharedPreferences'a `hasSeenOnboarding = true` yazılır
**And** Kayıt başarılı olduğunda ana ekrana yönlendirme yapılır

#### Scenario: Debug - Onboarding Sıfırlama
**Given** Developer onboarding'i tekrar test etmek istiyor
**When** `OnboardingPreferences.resetOnboarding()` çağrılır
**Then** SharedPreferences'tan `hasSeenOnboarding` değeri silinir
**And** Bir sonraki uygulama açılışında onboarding tekrar gösterilir

### Requirement: Performans ve Optimizasyon
Onboarding animasyonları smooth ve performanslı olmalıdır.

#### Scenario: 60 FPS Animasyon Performansı
**Given** Onboarding ekranı gösteriliyor
**When** Sayfa geçişleri ve animasyonlar oynatılıyor
**Then** Animasyonlar 60 FPS'de smooth çalışır
**And** Frame drop olmaz
**And** Düşük seviye cihazlarda da kabul edilebilir performans sağlanır

#### Scenario: Memory Kullanımı
**Given** Onboarding ekranı aktif
**When** Kullanıcı sayfalar arasında geziniyor
**Then** Memory kullanımı optimize edilmiştir
**And** Gereksiz widget rebuild'leri önlenmiştir
**And** Lottie animasyonları optimize edilmiş dosyalar kullanır

#### Scenario: Asset Yükleme
**Given** Onboarding ekranı açılıyor
**When** Lottie ve görsel asset'ler yükleniyor
**Then** Asset'ler lazy load edilir
**And** Kullanılmayan asset'ler memory'den temizlenir
**And** İlk sayfa hızlı yüklenir (< 500ms)

### Requirement: Konum Onboarding Entegrasyonu
Uygulama onboarding'i tamamlandıktan sonra konum onboarding'i tetiklenmelidir.

#### Scenario: Onboarding Sonrası Konum Kontrolü
**Given** Kullanıcı uygulama onboarding'ini tamamladı
**When** Ana ekrana yönlendirme yapılıyor
**Then** Konum seçilip seçilmediği kontrol edilir
**And** Eğer konum seçilmemişse `LocationOnboardingProvider` tetiklenir
**And** Kullanıcı konum seçim akışına yönlendirilir

#### Scenario: Konum Zaten Seçilmişse
**Given** Kullanıcı uygulama onboarding'ini tamamladı
**And** Kullanıcı daha önce konum seçmiş
**When** Ana ekrana yönlendirme yapılıyor
**Then** Konum onboarding atlanır
**And** Kullanıcı direkt ana ekrana (home) yönlendirilir

## MODIFIED Requirements

Yok - Bu yeni bir özellik olduğu için mevcut requirement'lar değiştirilmiyor.

## REMOVED Requirements

Yok - Bu yeni bir özellik olduğu için silinecek requirement yok.
