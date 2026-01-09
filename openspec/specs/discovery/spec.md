# discovery Specification

## Purpose
Provides venue discovery and filtering capabilities for users to find beauty service providers based on location, services, categories, and ratings.
## Requirements
<!-- This spec will be populated when implement-advanced-filtering change is archived -->

### Requirement: Interactive Map Discovery
The system SHALL provide a Google Maps based interface showing venue locations using custom markers.

#### Scenario: User navigates to map view
- **GIVEN** the user is on the Discovery screen
- **WHEN** the Map view mode is active
- **THEN** a Google Map SHALL be rendered
- **AND** it SHALL display markers representing venues within the current viewport.

### Requirement: UI View Toggle
The system SHALL allow users to switch between a map view and a list view seamlessly.

#### Scenario: User toggles from Map to List
- **GIVEN** the user is in Map view
- **WHEN** the user taps the view toggle button
- **THEN** the Map view SHALL be replaced by a scrollable List view of venues
- **AND** the toggle UI SHALL update to reflect the new state.

### Requirement: Category Filtering and Search
The system SHALL provide a search bar to filter venues by name or category.

#### Scenario: User searches for a category
- **GIVEN** the Discovery screen is open
- **WHEN** the user enters a category name in the search bar
- **THEN** both the Map markers and List items SHALL be filtered to show only matching venues.

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

### Requirement: Service-Based Search
Sistem, kullanıcıların hizmet adlarına göre mekan araması yapabilmesini SAĞLAMALIDIR (SHALL).

#### Scenario: Tek hizmet araması
- **GIVEN** kullanıcı keşfet ekranında
- **WHEN** arama çubuğuna "Botoks" yazar
- **THEN** "Botoks" hizmeti sunan tüm mekanlar listelenmeli
- **AND** sonuçlar kullanıcının konumuna göre sıralanmalı

#### Scenario: Çoklu hizmet araması
- **GIVEN** kullanıcı keşfet ekranında
- **WHEN** arama çubuğuna "Botoks Jawline" yazar
- **THEN** hem "Botoks" hem de "Jawline" hizmetlerini sunan mekanlar listelenmeli
- **AND** her iki hizmeti de sunan mekanlar öncelikli olarak gösterilmeli

### Requirement: Category Filtering
Sistem, kullanıcıların mekan kategorilerine göre filtreleme yapabilmesini SAĞLAMALIDIR (SHALL).

#### Scenario: Tek kategori seçimi
- **GIVEN** kullanıcı filtre panelini açtı
- **WHEN** "Estetik Klinikleri" kategorisini seçer
- **THEN** sadece estetik klinikleri listelenmeli
- **AND** diğer kategoriler gizlenmeli

#### Scenario: Çoklu kategori seçimi
- **GIVEN** kullanıcı filtre panelinde
- **WHEN** "Güzellik Salonları" ve "Kuaför" kategorilerini seçer
- **THEN** her iki kategoriden mekanlar birlikte listelenmeli

### Requirement: Proximity-Based Filtering
Sistem, kullanıcıların belirli bir yarıçap içindeki mekanları filtreleyebilmesini SAĞLAMALIDIR (SHALL).

#### Scenario: Yarıçap ayarlama
- **GIVEN** kullanıcı filtre panelinde
- **WHEN** uzaklık slider'ını 5km olarak ayarlar
- **THEN** sadece 5km yarıçapındaki mekanlar gösterilmeli
- **AND** harita görünümü bu yarıçapı yansıtmalı

#### Scenario: Konum izni olmadan filtreleme
- **GIVEN** kullanıcı konum iznini vermemiş
- **WHEN** uzaklık filtresi kullanmaya çalışır
- **THEN** varsayılan bir konum (örn: İstanbul merkez) kullanılmalı
- **OR** konum izni istenmeli

### Requirement: Rating-Based Filtering
Sistem, kullanıcıların minimum puan kriterine göre filtreleme yapabilmesini SAĞLAMALIDIR (SHALL).

#### Scenario: Minimum puan belirleme
- **GIVEN** kullanıcı filtre panelinde
- **WHEN** minimum puanı 4.0 olarak seçer
- **THEN** sadece 4.0 ve üzeri puana sahip mekanlar listelenmeli

### Requirement: Trust Badge Filtering
Sistem, kullanıcıların güven rozetlerine göre filtreleme yapabilmesini SAĞLAMALIDIR (SHALL).

#### Scenario: Onaylı mekan filtresi
- **GIVEN** kullanıcı filtre panelinde
- **WHEN** "Sadece Onaylı Mekanlar" seçeneğini aktif eder
- **THEN** sadece `is_verified = true` olan mekanlar listelenmeli

#### Scenario: Çoklu rozet filtresi
- **GIVEN** kullanıcı filtre panelinde
- **WHEN** "Onaylı" ve "Hijyenik" rozetlerini seçer
- **THEN** her iki rozete de sahip mekanlar listelenmeli

### Requirement: Filter Persistence
Sistem, kullanıcının seçtiği filtreleri oturum boyunca korumalıdır (SHALL).

#### Scenario: Filtre durumu korunması
- **GIVEN** kullanıcı filtreleri ayarladı
- **WHEN** mekan detay sayfasına gidip geri döner
- **THEN** önceki filtreler hala aktif olmalı
- **AND** aynı sonuçlar gösterilmeli

### Requirement: Filter Reset
Sistem, kullanıcıların tüm filtreleri tek bir işlemle sıfırlayabilmesini SAĞLAMALIDIR (SHALL).

#### Scenario: Filtreleri temizleme
- **GIVEN** kullanıcı birden fazla filtre uygulamış
- **WHEN** "Filtreleri Temizle" butonuna tıklar
- **THEN** tüm filtreler varsayılan değerlerine dönmeli
- **AND** tüm mekanlar tekrar gösterilmeli

### Requirement: Advanced Search Query
Sistem, backend tarafında gelişmiş arama sorgularını desteklemelidir (SHALL).

#### Scenario: RPC fonksiyonu ile arama
- **GIVEN** Supabase'de `search_venues_advanced` RPC fonksiyonu mevcut
- **WHEN** kullanıcı filtreler ve arama sorgusu ile istek yapar
- **THEN** fonksiyon hem mekan adını hem de hizmet adlarını taramalı
- **AND** coğrafi filtreleme uygulamalı
- **AND** sonuçları uzaklık ve alaka düzeyine göre sıralamalı

