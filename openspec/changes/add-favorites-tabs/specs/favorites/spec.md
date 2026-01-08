## ADDED Requirements

### Requirement: Favorites Tab Navigation
Favoriler sayfası İKİ ayrı sekme içermelidir: "Favoriler" ve "Takip Ettiklerim". Kullanıcılar sekmeler arasında kolayca geçiş yapabilmelidir.

#### Scenario: User views favorites tab
- **WHEN** kullanıcı Favoriler sayfasını açar
- **THEN** varsayılan olarak "Favoriler" sekmesi aktif olmalıdır
- **AND** sekme bar'da "Favoriler" ve "Takip Ettiklerim" sekmeleri görünmelidir
- **AND** aktif sekme vurgulanmış (bold text, colored indicator) olmalıdır

#### Scenario: User switches between tabs
- **WHEN** kullanıcı "Takip Ettiklerim" sekmesine tıklar
- **THEN** sekme geçişi smooth animasyon ile gerçekleşmelidir
- **AND** "Takip Ettiklerim" içeriği gösterilmelidir
- **AND** sekme göstergesi (indicator) yeni sekmeye kaymalıdır

#### Scenario: User swipes between tabs
- **WHEN** kullanıcı ekranda sağa/sola kaydırma (swipe) yapar
- **THEN** sekmeler arasında geçiş yapılmalıdır
- **AND** sekme göstergesi otomatik olarak güncellenmelidir

### Requirement: Display Favorite Venues
"Favoriler" sekmesi kullanıcının favori olarak eklediği mekanları liste halinde göstermelidir.

#### Scenario: User has favorite venues
- **WHEN** kullanıcının favori mekanları varsa
- **THEN** mekanlar liste halinde (en yeni üstte) gösterilmelidir
- **AND** her mekan kartı mekan adı, fotoğraf, konum, rating bilgilerini içermelidir
- **AND** her mekan kartında favori butonu (dolu kalp ikonu) bulunmalıdır

#### Scenario: User has no favorite venues
- **WHEN** kullanıcının hiç favori mekanı yoksa
- **THEN** boş state gösterilmelidir
- **AND** boş state "Henüz favori mekanınız yok" mesajı içermelidir
- **AND** boş state açıklayıcı bir ikon (kalp) içermelidir
- **AND** "Mekanları favorilere ekleyerek daha sonra kolayca bulabilirsiniz" gibi yardımcı metin gösterilmelidir

#### Scenario: Favorite venues loading
- **WHEN** favori mekanlar yüklenirken
- **THEN** loading indicator (shimmer veya skeleton) gösterilmelidir
- **AND** kullanıcı arayüzün yanıt verdiğini anlamalıdır

#### Scenario: Favorite venues load error
- **WHEN** favori mekanlar yüklenirken hata oluşursa
- **THEN** hata mesajı gösterilmelidir
- **AND** "Tekrar Dene" butonu sunulmalıdır

### Requirement: Display Followed Venues
"Takip Ettiklerim" sekmesi kullanıcının takip ettiği mekanları liste halinde göstermelidir.

#### Scenario: User has followed venues
- **WHEN** kullanıcının takip ettiği mekanlar varsa
- **THEN** mekanlar liste halinde (en yeni üstte) gösterilmelidir
- **AND** her mekan kartı mekan adı, fotoğraf, konum, rating bilgilerini içermelidir
- **AND** her mekan kartında takip butonu (aktif durum) bulunmalıdır

#### Scenario: User has no followed venues
- **WHEN** kullanıcının hiç takip ettiği mekan yoksa
- **THEN** boş state gösterilmelidir
- **AND** boş state "Henüz takip ettiğiniz mekan yok" mesajı içermelidir
- **AND** boş state açıklayıcı bir ikon (bildirim/takip) içermelidir
- **AND** "Mekanları takip ederek güncellemelerinden haberdar olabilirsiniz" gibi yardımcı metin gösterilmelidir

#### Scenario: Followed venues loading
- **WHEN** takip edilen mekanlar yüklenirken
- **THEN** loading indicator (shimmer veya skeleton) gösterilmelidir
- **AND** kullanıcı arayüzün yanıt verdiğini anlamalıdır

#### Scenario: Followed venues load error
- **WHEN** takip edilen mekanlar yüklenirken hata oluşursa
- **THEN** hata mesajı gösterilmelidir
- **AND** "Tekrar Dene" butonu sunulmalıdır

### Requirement: Add to Favorites
Kullanıcılar mekanları favorilere ekleyebilmelidir.

#### Scenario: User adds venue to favorites
- **WHEN** kullanıcı bir mekan kartındaki favori butonuna (boş kalp) tıklar
- **THEN** mekan favorilere eklenmelidir
- **AND** favori butonu dolu kalp ikonuna dönüşmelidir
- **AND** başarı feedback'i (snackbar veya toast) gösterilmelidir
- **AND** "Favoriler" sekmesindeki liste güncellenmelidir

#### Scenario: User is not authenticated
- **WHEN** kullanıcı giriş yapmamışsa ve favori butonuna tıklarsa
- **THEN** giriş yapması için yönlendirilmelidir
- **OR** "Favorilere eklemek için giriş yapın" mesajı gösterilmelidir

#### Scenario: Add to favorites fails
- **WHEN** favorilere ekleme işlemi başarısız olursa
- **THEN** hata mesajı gösterilmelidir
- **AND** favori butonu eski haline dönmelidir

### Requirement: Remove from Favorites
Kullanıcılar mekanları favorilerden çıkarabilmelidir.

#### Scenario: User removes venue from favorites
- **WHEN** kullanıcı bir mekan kartındaki favori butonuna (dolu kalp) tıklar
- **THEN** mekan favorilerden çıkarılmalıdır
- **AND** favori butonu boş kalp ikonuna dönüşmelidir
- **AND** "Favoriler" sekmesindeki listeden kaldırılmalıdır
- **AND** başarı feedback'i gösterilmelidir

#### Scenario: Remove from favorites fails
- **WHEN** favorilerden çıkarma işlemi başarısız olursa
- **THEN** hata mesajı gösterilmelidir
- **AND** favori butonu eski haline dönmelidir
- **AND** mekan listeden kaldırılmamalıdır

### Requirement: Premium Tab Design
Sekme tasarımı uygulamanın genel tasarım diline (soft pink, nude, cream, gold) uygun olmalıdır.

#### Scenario: Tab bar styling
- **WHEN** kullanıcı Favoriler sayfasını görüntüler
- **THEN** sekme bar beyaz arka plana sahip olmalıdır
- **AND** aktif sekme metni primary renkte (vibrant pink) ve bold olmalıdır
- **AND** pasif sekme metni gray600 renkte olmalıdır
- **AND** sekme göstergesi (indicator) primary renkte ve 2px yüksekliğinde olmalıdır
- **AND** sekme bar elevation 0 olmalıdır (flat design)

#### Scenario: Venue card styling
- **WHEN** mekan kartları gösterilir
- **THEN** kartlar mevcut uygulama stiline uygun olmalıdır
- **AND** kartlar rounded corners, subtle shadow içermelidir
- **AND** favori/takip butonları görsel olarak belirgin olmalıdır

### Requirement: Venue Card Actions
Mekan kartlarından mekan detay sayfasına gidebilmelidir.

#### Scenario: User taps on venue card
- **WHEN** kullanıcı bir mekan kartına (favori butonu hariç) tıklar
- **THEN** mekan detay sayfası açılmalıdır
- **AND** geçiş animasyonu smooth olmalıdır

#### Scenario: User returns from venue details
- **WHEN** kullanıcı mekan detayından geri döner
- **THEN** favoriler sayfası önceki durumunda (aynı sekme, aynı scroll pozisyonu) olmalıdır
- **AND** favori/takip durumu güncel olmalıdır
