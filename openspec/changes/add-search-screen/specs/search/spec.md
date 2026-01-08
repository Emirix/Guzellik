# Search Capability Specification

## Purpose
Kullanıcıların hizmetlere, mekanlara ve konumlara göre gelişmiş arama ve filtreleme yapabilmelerini sağlayan ayrı bir arama ekranı.

## ADDED Requirements

### Requirement: Dedicated Search Screen
Sistem, kullanıcılara navbar üzerinden erişilebilen ayrı bir arama ekranı SAĞLAMALIDIR.

#### Scenario: Navbar'dan arama ekranına erişim
- **GIVEN** uygulama açık
- **WHEN** kullanıcı navbar'daki "Ara" sekmesine tıklar
- **THEN** tam ekran arama sayfası gösterilmeli

#### Scenario: Keşfet ekranından arama ekranına geçiş
- **GIVEN** kullanıcı Keşfet ekranında
- **WHEN** arama çubuğuna tıklar
- **THEN** otomatik olarak "Ara" sekmesine geçmeli

### Requirement: Recent Searches
Sistem, kullanıcının son aramalarını yerel olarak saklayıp göstermelidir.

#### Scenario: Son aramaların görüntülenmesi
- **GIVEN** kullanıcı daha önce arama yapmış
- **WHEN** arama ekranını açar ve arama alanı boş
- **THEN** son 10 arama "Son Aramalar" bölümünde gösterilmeli

#### Scenario: Son aramadan tekrar arama
- **GIVEN** son aramalar listesi görünür
- **WHEN** kullanıcı bir arama öğesine tıklar
- **THEN** o arama sorgusu ile arama yapılmalı

#### Scenario: Tek arama silme
- **GIVEN** son aramalar listesi görünür
- **WHEN** kullanıcı bir arama öğesinin silme butonuna tıklar
- **THEN** o arama listeden kaldırılmalı

#### Scenario: Tüm aramaları temizleme
- **GIVEN** son aramalar listesi görünür
- **WHEN** kullanıcı "Temizle" butonuna tıklar
- **THEN** tüm aramalar silinmeli

### Requirement: Popular Services Display
Sistem, popüler hizmetleri chip olarak göstermelidir.

#### Scenario: Popüler hizmetlerin gösterilmesi
- **GIVEN** arama ekranı açık ve arama alanı boş
- **WHEN** sayfa yüklenir
- **THEN** popüler hizmetler chip olarak listelenmeli

#### Scenario: Popüler hizmet seçimi
- **GIVEN** popüler hizmetler görünür
- **WHEN** kullanıcı bir hizmet chip'ine tıklar
- **THEN** o hizmet adı ile arama yapılmalı

### Requirement: Location-Based Filtering
Sistem, kullanıcıların il ve ilçeye göre filtreleme yapabilmesini SAĞLAMALIDIR.

#### Scenario: Otomatik konum tespiti
- **GIVEN** konum izni verilmiş
- **WHEN** kullanıcı arama ekranını açar
- **THEN** mevcut konum otomatik olarak tespit edilmeli

#### Scenario: Konum izni isteme
- **GIVEN** konum izni verilmemiş
- **WHEN** kullanıcı "Konumumu Kullan" butonuna tıklar
- **THEN** konum izni dialog'u gösterilmeli

#### Scenario: Manuel konum seçimi
- **GIVEN** filtre paneli açık
- **WHEN** kullanıcı il dropdown'ından bir il seçer
- **THEN** ilçe dropdown'ı o ilin ilçeleri ile doldurulmalı

### Requirement: Distance Slider Filter
Sistem, kullanıcıların mesafe bazlı filtreleme yapabilmesini SAĞLAMALIDIR.

#### Scenario: Mesafe slider kullanımı
- **GIVEN** filtre paneli açık
- **WHEN** kullanıcı mesafe slider'ını 5km'ye ayarlar
- **THEN** sadece 5km yarıçapındaki mekanlar gösterilmeli

#### Scenario: Mesafe filtresi sıfırlama
- **GIVEN** mesafe filtresi uygulanmış
- **WHEN** kullanıcı "Temizle" butonuna tıklar
- **THEN** mesafe filtresi kaldırılmalı

### Requirement: Service-Based Filtering
Sistem, kullanıcıların veritabanındaki hizmetlere göre filtreleme yapabilmesini SAĞLAMALIDIR.

#### Scenario: Hizmet seçimi
- **GIVEN** filtre paneli açık
- **WHEN** kullanıcı hizmet chip'lerinden birini seçer
- **THEN** arama sonuçları o hizmeti sunan mekanları göstermeli

#### Scenario: Çoklu hizmet seçimi
- **GIVEN** filtre paneli açık
- **WHEN** kullanıcı birden fazla hizmet seçer
- **THEN** tüm seçili hizmetleri sunan mekanlar listelenmeli

### Requirement: Venue Type Filtering
Sistem, kullanıcıların mekan türüne göre filtreleme yapabilmesini SAĞLAMALIDIR.

#### Scenario: Tek mekan türü seçimi
- **GIVEN** filtre paneli açık
- **WHEN** kullanıcı "Güzellik Salonu" chip'ini seçer
- **THEN** sadece güzellik salonları listelenmeli

#### Scenario: Çoklu mekan türü seçimi
- **GIVEN** filtre paneli açık
- **WHEN** kullanıcı birden fazla mekan türü seçer
- **THEN** seçilen tüm türlerden mekanlar birlikte listelenmeli

### Requirement: Search Results Display
Sistem, arama sonuçlarını tasarıma uygun kart formatında göstermelidir.

#### Scenario: Sonuç kartı içeriği
- **GIVEN** arama sonuçları mevcut
- **WHEN** sonuçlar gösterilir
- **THEN** her kart mekan görseli, adı, konumu, puanı ve hizmetleri içermeli

#### Scenario: Aranan hizmet vurgulama
- **GIVEN** kullanıcı belirli bir hizmet araması yaptı
- **WHEN** sonuçlar gösterilir
- **THEN** aranan hizmet etiketi vurgulu gösterilmeli

### Requirement: Sort Options
Sistem, arama sonuçlarını farklı kriterlere göre sıralamalıdır.

#### Scenario: Sıralama seçenekleri
- **GIVEN** arama sonuçları mevcut
- **WHEN** kullanıcı sıralama dropdown'ını açar
- **THEN** Önerilen, En Yakın, En Yüksek Puan seçenekleri sunulmalı

#### Scenario: Sıralama uygulanması
- **GIVEN** sonuçlar listeleniyor
- **WHEN** kullanıcı "En Yakın" seçer
- **THEN** sonuçlar mesafeye göre artan sırada listelenmeli

### Requirement: Filter Preview
Sistem, filtre uygulanmadan önce sonuç sayısı önizlemesi göstermelidir.

#### Scenario: Sonuç sayısı önizlemesi
- **GIVEN** filtre paneli açık ve filtreler seçilmiş
- **WHEN** kullanıcı seçimlerini değiştirir
- **THEN** "Sonuçları Göster" butonunda tahmini sonuç sayısı gösterilmeli
