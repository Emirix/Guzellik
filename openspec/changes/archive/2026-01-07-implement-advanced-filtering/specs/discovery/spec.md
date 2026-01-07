## ADDED Requirements

### Requirement: Service-Based Search
Sistem, kullanıcıların hizmet adlarına göre mekan araması yapabilmesini SAĞLAMALIDIR.

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
Sistem, kullanıcıların mekan kategorilerine göre filtreleme yapabilmesini SAĞLAMALIDIR.

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
Sistem, kullanıcıların belirli bir yarıçap içindeki mekanları filtreleyebilmesini SAĞLAMALIDIR.

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
Sistem, kullanıcıların minimum puan kriterine göre filtreleme yapabilmesini SAĞLAMALIDIR.

#### Scenario: Minimum puan belirleme
- **GIVEN** kullanıcı filtre panelinde
- **WHEN** minimum puanı 4.0 olarak seçer
- **THEN** sadece 4.0 ve üzeri puana sahip mekanlar listelenmeli

### Requirement: Trust Badge Filtering
Sistem, kullanıcıların güven rozetlerine göre filtreleme yapabilmesini SAĞLAMALIDIR.

#### Scenario: Onaylı mekan filtresi
- **GIVEN** kullanıcı filtre panelinde
- **WHEN** "Sadece Onaylı Mekanlar" seçeneğini aktif eder
- **THEN** sadece `is_verified = true` olan mekanlar listelenmeli

#### Scenario: Çoklu rozet filtresi
- **GIVEN** kullanıcı filtre panelinde
- **WHEN** "Onaylı" ve "Hijyenik" rozetlerini seçer
- **THEN** her iki rozete de sahip mekanlar listelenmeli

### Requirement: Filter Persistence
Sistem, kullanıcının seçtiği filtreleri oturum boyunca korumalıdır.

#### Scenario: Filtre durumu korunması
- **GIVEN** kullanıcı filtreleri ayarladı
- **WHEN** mekan detay sayfasına gidip geri döner
- **THEN** önceki filtreler hala aktif olmalı
- **AND** aynı sonuçlar gösterilmeli

### Requirement: Filter Reset
Sistem, kullanıcıların tüm filtreleri tek bir işlemle sıfırlayabilmesini SAĞLAMALIDIR.

#### Scenario: Filtreleri temizleme
- **GIVEN** kullanıcı birden fazla filtre uygulamış
- **WHEN** "Filtreleri Temizle" butonuna tıklar
- **THEN** tüm filtreler varsayılan değerlerine dönmeli
- **AND** tüm mekanlar tekrar gösterilmeli

### Requirement: Advanced Search Query
Sistem, backend tarafında gelişmiş arama sorgularını desteklemelidir.

#### Scenario: RPC fonksiyonu ile arama
- **GIVEN** Supabase'de `search_venues_advanced` RPC fonksiyonu mevcut
- **WHEN** kullanıcı filtreler ve arama sorgusu ile istek yapar
- **THEN** fonksiyon hem mekan adını hem de hizmet adlarını taramalı
- **AND** coğrafi filtreleme uygulamalı
- **AND** sonuçları uzaklık ve alaka düzeyine göre sıralamalı
