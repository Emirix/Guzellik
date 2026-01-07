## ADDED Requirements

### Requirement: Ana sayfa görünümü sunulmalı

Kullanıcılar keşfet ekranına girdiklerinde, doğrudan harita veya liste yerine ilham verici bir ana sayfa görmelidir.

#### Scenario: Kullanıcı keşfet ekranını açar

- **GIVEN** kullanıcı uygulamayı açmış
- **WHEN** alt navigasyondan "Keşfet" sekmesine tıklar
- **THEN** ana sayfa görünümü gösterilir
- **AND** "Keşfet" başlığı görünür
- **AND** arama çubuğu görünür
- **AND** kategori filtreleri görünür
- **AND** popüler hizmetler bölümü görünür
- **AND** editörün seçimi bölümü görünür

#### Scenario: Ana sayfa 2 saniyeden kısa sürede yüklenir

- **GIVEN** kullanıcı keşfet ekranını açmış
- **WHEN** sayfa yüklenmeye başlar
- **THEN** tüm bileşenler 2 saniye içinde yüklenir
- **AND** loading indicator gösterilir
- **AND** yükleme tamamlandığında indicator kaybolur

---

### Requirement: Popüler hizmetler gösterilmeli

Kullanıcılar en çok aranan hizmetleri görerek hızlıca ilgili mekanları keşfedebilmelidir.

#### Scenario: Popüler hizmetler listesi gösterilir

- **GIVEN** kullanıcı ana sayfada
- **WHEN** sayfa yüklenir
- **THEN** "Popüler Hizmetler" başlığı görünür
- **AND** en az 6 popüler hizmet chip'i görünür
- **AND** chip'ler yatay scroll edilebilir
- **AND** her chip hizmet adını gösterir

#### Scenario: Popüler hizmet seçimi

- **GIVEN** kullanıcı ana sayfada
- **WHEN** bir popüler hizmet chip'ine tıklar (örn: "Botoks")
- **THEN** liste görünümüne geçilir
- **AND** seçilen hizmeti sunan mekanlar gösterilir
- **AND** arama çubuğunda hizmet adı görünür

#### Scenario: Popüler hizmetler cache'lenir

- **GIVEN** kullanıcı ana sayfayı yüklemiş
- **WHEN** 5 dakika içinde tekrar ana sayfaya döner
- **THEN** popüler hizmetler cache'ten yüklenir
- **AND** network isteği yapılmaz

---

### Requirement: Editörün seçtiği mekanlar gösterilmeli

Kullanıcılar öne çıkan, kaliteli mekanları kolayca keşfedebilmelidir.

#### Scenario: Editörün seçimi bölümü gösterilir

- **GIVEN** kullanıcı ana sayfada
- **WHEN** sayfa yüklenir
- **THEN** "Editörün Seçimi" başlığı görünür
- **AND** "Tümünü Gör" butonu görünür
- **AND** en az 5 mekan kartı görünür
- **AND** kartlar yatay scroll edilebilir

#### Scenario: Mekan kartı bilgileri

- **GIVEN** kullanıcı editörün seçimi bölümünde
- **WHEN** bir mekan kartına bakar
- **THEN** mekan fotoğrafı görünür
- **AND** mekan adı görünür
- **AND** rating (yıldız) görünür
- **AND** konum bilgisi görünür
- **AND** sunulan hizmet türleri görünür

#### Scenario: Mekan kartına tıklama

- **GIVEN** kullanıcı editörün seçimi bölümünde
- **WHEN** bir mekan kartına tıklar
- **THEN** mekan detay sayfasına yönlendirilir

#### Scenario: Tümünü Gör butonu

- **GIVEN** kullanıcı editörün seçimi bölümünde
- **WHEN** "Tümünü Gör" butonuna tıklar
- **THEN** liste görünümüne geçilir
- **AND** tüm öne çıkan mekanlar gösterilir

---

### Requirement: Görünüm modları arasında geçiş yapılabilmeli

Kullanıcılar ana sayfa, harita ve liste görünümleri arasında kolayca geçiş yapabilmelidir.

#### Scenario: Harita görünümüne geçiş

- **GIVEN** kullanıcı ana sayfada
- **WHEN** görünüm değiştirme butonundan "Harita" seçer
- **THEN** harita görünümü gösterilir
- **AND** mekanlar haritada marker olarak görünür
- **AND** arama çubuğu ve filtreler korunur

#### Scenario: Liste görünümüne geçiş

- **GIVEN** kullanıcı ana sayfada
- **WHEN** görünüm değiştirme butonundan "Liste" seçer
- **THEN** liste görünümü gösterilir
- **AND** mekanlar liste halinde görünür
- **AND** arama çubuğu ve filtreler korunur

#### Scenario: Ana sayfaya dönüş

- **GIVEN** kullanıcı harita veya liste görünümünde
- **WHEN** görünüm değiştirme butonundan "Ana Sayfa" seçer
- **THEN** ana sayfa görünümü gösterilir
- **AND** önceki state korunur (scroll position hariç)

---

### Requirement: Filtrele butonu çalışmalı

Kullanıcılar sağ üst köşedeki filtrele butonu ile gelişmiş filtreleme yapabilmelidir.

#### Scenario: Filtrele butonu gösterilir

- **GIVEN** kullanıcı ana sayfada
- **WHEN** sayfayı görüntüler
- **THEN** sağ üst köşede "Filtrele" butonu görünür
- **AND** buton pembe/kırmızı renkte
- **AND** filtre ikonu görünür

#### Scenario: Filtre bottom sheet açılır

- **GIVEN** kullanıcı ana sayfada
- **WHEN** "Filtrele" butonuna tıklar
- **THEN** filtre bottom sheet açılır
- **AND** mevcut filtreler gösterilir

#### Scenario: Filtre badge gösterilir

- **GIVEN** kullanıcı filtre uygulamış
- **WHEN** ana sayfaya döner
- **THEN** "Filtrele" butonunda badge görünür
- **AND** badge aktif filtre sayısını gösterir

---

### Requirement: Boş state'ler uygun şekilde gösterilmeli

Veri olmadığında veya hata oluştuğunda kullanıcıya uygun mesajlar gösterilmelidir.

#### Scenario: Popüler hizmetler yüklenemedi

- **GIVEN** network hatası oluşmuş
- **WHEN** popüler hizmetler yüklenmeye çalışılır
- **THEN** hata mesajı gösterilir
- **AND** "Tekrar Dene" butonu gösterilir

#### Scenario: Editörün seçimi boş

- **GIVEN** henüz öne çıkan mekan yok
- **WHEN** editörün seçimi bölümü yüklenir
- **THEN** "Henüz öne çıkan mekan yok" mesajı gösterilir

#### Scenario: Loading state

- **GIVEN** kullanıcı ana sayfayı açmış
- **WHEN** veriler yüklenirken
- **THEN** skeleton loader gösterilir
- **AND** shimmer efekti uygulanır
