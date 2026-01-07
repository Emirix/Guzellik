## MODIFIED Requirements

### Requirement: UI View Toggle

**Değişiklik**: Üç görünüm modu desteği eklendi (Ana Sayfa, Harita, Liste)

Sistem, kullanıcıların ana sayfa, harita ve liste görünümleri arasında geçiş yapabilmesini SAĞLAMALIDIR.

#### Scenario: Varsayılan görünüm ana sayfa olmalı

- **GIVEN** kullanıcı keşfet ekranını ilk kez açıyor
- **WHEN** ekran yüklenir
- **THEN** ana sayfa görünümü gösterilmeli
- **AND** görünüm toggle'ı "Ana Sayfa" modunda olmalı

#### Scenario: Ana sayfadan haritaya geçiş

- **GIVEN** kullanıcı ana sayfa görünümünde
- **WHEN** görünüm toggle'ından "Harita" seçer
- **THEN** harita görünümü gösterilmeli
- **AND** mekanlar haritada marker olarak görünmeli
- **AND** arama çubuğu ve filtreler korunmalı

#### Scenario: Ana sayfadan listeye geçiş

- **GIVEN** kullanıcı ana sayfa görünümünde
- **WHEN** görünüm toggle'ından "Liste" seçer
- **THEN** liste görünümü gösterilmeli
- **AND** mekanlar liste halinde görünmeli
- **AND** arama çubuğu ve filtreler korunmalı

#### Scenario: Harita veya listeden ana sayfaya dönüş

- **GIVEN** kullanıcı harita veya liste görünümünde
- **WHEN** görünüm toggle'ından "Ana Sayfa" seçer
- **THEN** ana sayfa görünümü gösterilmeli
- **AND** önceki state korunmalı (scroll position hariç)

---

### Requirement: Category Filtering and Search

**Değişiklik**: Arama yapıldığında otomatik liste görünümüne geçiş eklendi

Sistem, kullanıcıların arama yapabilmesini ve sonuçları uygun görünümde gösterebilmesini SAĞLAMALIDIR.

#### Scenario: Arama yapıldığında liste görünümüne geçiş

- **GIVEN** kullanıcı ana sayfa veya harita görünümünde
- **WHEN** arama çubuğuna bir sorgu girer ve arama yapar
- **THEN** otomatik olarak liste görünümüne geçilmeli
- **AND** arama sonuçları liste halinde gösterilmeli
- **AND** arama sorgusu arama çubuğunda görünmeli

#### Scenario: Arama temizlendiğinde ana sayfaya dönüş

- **GIVEN** kullanıcı arama yapmış ve liste görünümünde
- **WHEN** arama çubuğundaki metni temizler
- **THEN** ana sayfa görünümüne dönülmeli
- **AND** popüler hizmetler ve editörün seçimi tekrar gösterilmeli

---

### Requirement: Filter Persistence

**Değişiklik**: Görünüm modları arasında filter persistence desteği eklendi

Sistem, kullanıcının seçtiği filtreleri görünüm değişikliklerinde de korumalıdır.

#### Scenario: Görünüm değişiminde filtreler korunur

- **GIVEN** kullanıcı kategori ve diğer filtreleri seçmiş
- **WHEN** ana sayfa, harita ve liste görünümleri arasında geçiş yapar
- **THEN** seçili filtreler tüm görünümlerde aktif kalmalı
- **AND** filtrelenmiş sonuçlar her görünümde gösterilmeli

#### Scenario: Ana sayfada kategori seçimi diğer görünümleri etkiler

- **GIVEN** kullanıcı ana sayfada "Estetik" kategorisini seçmiş
- **WHEN** harita veya liste görünümüne geçer
- **THEN** sadece "Estetik" kategorisindeki mekanlar gösterilmeli
- **AND** kategori filtresi aktif kalmalı
