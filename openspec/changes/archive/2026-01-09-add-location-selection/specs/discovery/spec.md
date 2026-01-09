## MODIFIED Requirements

### Requirement: User Geolocation
Sistem, kullanıcının GPS konumunu almalı (SHALL) VE manuel konum girişine izin vermelidir (SHALL). Cihaz konumu kullanıldığında harita kamerası bu konuma odaklanmalıdır (SHALL).

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

#### Scenario: User centers on current location
- **GIVEN** location permissions are granted
- **WHEN** the user taps the location centering button
- **THEN** the map camera SHALL animate to the user's current GPS coordinates.
