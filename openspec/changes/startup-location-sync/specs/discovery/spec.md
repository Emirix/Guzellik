## MODIFIED Requirements

### Requirement: User Geolocation
Sistem, kullanıcının GPS konumunu almalı (SHALL) VE manuel konum girişine izin vermelidir (SHALL). Uygulama her açıldığında cihazın konum servisi durumu kontrol edilmelidir. Konum servisi açıksa GPS verisiyle konum otomatik güncellenmeli, kapalıysa kullanıcıya bildirimle sorulmalıdır. Red durumunda kullanıcının profilindeki şehir varsayılan konum olarak ayarlanmalıdır.

#### Scenario: Kullanıcı manuel konum seçer
- **GIVEN** Keşfet veya Ana Sayfa ekranında
- **WHEN** Sol üstteki konum bilgisine tıklar
- **AND** Açılan listeden "İstanbul" ve "Beşiktaş" seçer
- **THEN** Uygulama coğrafi odağını Beşiktaş, İstanbul olarak güncellemelidir.
- **AND** Arama sonuçları bu yeni konuma göre güncellenmelidir.

#### Scenario: Kullanıcı mevcut konumunu kullanır
- **GIVEN** Konum seçim ekranında
- **WHEN** "Mevcut Konumumu Kullan" butonuna tıklar
- **THEN** Uygulama cihazın GPS verisini kullanarak konumu güncellemelidir.

#### Scenario: Kullanıcı haritadan konum seçer
- **GIVEN** Konum seçim ekranında
- **WHEN** "Haritadan Seç" butonuna tıklar
- **THEN** Kullanıcıya bir harita arayüzü sunulmalıdır.
- **WHEN** Kullanıcı haritadan bir nokta seçip onayladığında
- **THEN** Uygulama bu noktayı aktif discovery konumu olarak belirlemelidir.

#### Scenario: Uygulama açılışında otomatik konum güncelleme
- **GIVEN** Uygulama yeni başlatıldı (Cold Start)
- **AND** Cihazın konum servisi AÇIK
- **WHEN** Splash screen tamamlandığında
- **THEN** Sistem arka planda GPS koordinatlarını almalı
- **AND** Konum bilgilerini Discovery sistemine kaydetmelidir.

#### Scenario: Uygulama açılışında konum kapalıysa sorgulama
- **GIVEN** Uygulama yeni başlatıldı
- **AND** Cihazın konum servisi KAPALI
- **WHEN** Splash screen tamamlandığında
- **THEN** Kullanıcıya konumu açmasını isteyen bir Bottom Sheet gösterilmelidir.

#### Scenario: Konum açma isteği reddedildiğinde profil şehrine dönme
- **GIVEN** Konum açma Bottom Sheet'i devrede
- **WHEN** Kullanıcı isteği reddederse veya kapatırsa
- **AND** Kullanıcı giriş yapmışsa
- **THEN** Kullanıcının profilindeki il/ilçe bilgisi ve bu konumun **enlem/boylam koordinatları** varsayılan konum olarak ayarlanmalıdır.
- **AND** Tüm mesafe hesaplamaları bu koordinat merkezlerine göre doğru şekilde yapılmalıdır.
