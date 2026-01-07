## ADDED Requirements

### Requirement: Kategori filtreleri gösterilmeli

Kullanıcılar ana sayfada hizmet kategorilerine göre filtreleme yapabilmelidir.

#### Scenario: Kategori filtreleri listesi gösterilir

- **GIVEN** kullanıcı ana sayfada
- **WHEN** sayfa yüklenir
- **THEN** kategori filtreleri görünür
- **AND** "Tümü" kategorisi varsayılan olarak seçili
- **AND** en az 6 kategori chip'i görünür
- **AND** chip'ler yatay scroll edilebilir

#### Scenario: Kategori listesi

- **GIVEN** kullanıcı kategori filtrelerinde
- **WHEN** listeye bakar
- **THEN** şu kategoriler görünür: "Tümü", "Saç Tasarım", "Cilt Bakım", "Tırnak", "Estetik", "Vücut", "Kaş-Kirpik"
- **AND** her kategori chip olarak gösterilir

---

### Requirement: Kategori seçimi yapılabilmeli

Kullanıcılar kategorilere tıklayarak filtreleme yapabilmelidir.

#### Scenario: Kategori seçimi

- **GIVEN** kullanıcı ana sayfada
- **WHEN** "Cilt Bakım" kategorisine tıklar
- **THEN** "Cilt Bakım" kategorisi seçili hale gelir
- **AND** seçili kategori pembe arka plan ile vurgulanır
- **AND** önceki seçim kaldırılır (sadece bir kategori seçili olabilir)

#### Scenario: Seçili kategori stili

- **GIVEN** kullanıcı bir kategori seçmiş
- **WHEN** kategori chip'ine bakar
- **THEN** seçili chip pembe/kırmızı arka plana sahip
- **AND** beyaz metin rengi kullanılır
- **AND** seçili olmayan chip'ler beyaz arka plana sahip
- **AND** seçili olmayan chip'ler gri metin rengi kullanır

#### Scenario: Tümü kategorisi

- **GIVEN** kullanıcı bir kategori seçmiş
- **WHEN** "Tümü" kategorisine tıklar
- **THEN** tüm kategoriler gösterilir
- **AND** kategori filtresi kaldırılır
- **AND** "Tümü" seçili hale gelir

---

### Requirement: Kategori filtresi sonuçları etkilemeli

Seçilen kategori, gösterilen mekanları ve hizmetleri filtrelemelidir.

#### Scenario: Kategori seçimi sonuçları filtreler

- **GIVEN** kullanıcı ana sayfada
- **WHEN** "Estetik" kategorisini seçer
- **THEN** popüler hizmetler "Estetik" kategorisine göre filtrelenir
- **AND** editörün seçimi "Estetik" hizmeti sunan mekanları gösterir
- **AND** arama sonuçları (varsa) "Estetik" kategorisine göre filtrelenir

#### Scenario: Kategori filtresi harita görünümünde korunur

- **GIVEN** kullanıcı "Saç Tasarım" kategorisini seçmiş
- **WHEN** harita görünümüne geçer
- **THEN** haritada sadece "Saç Tasarım" hizmeti sunan mekanlar gösterilir
- **AND** kategori seçimi korunur

#### Scenario: Kategori filtresi liste görünümünde korunur

- **GIVEN** kullanıcı "Cilt Bakım" kategorisini seçmiş
- **WHEN** liste görünümüne geçer
- **THEN** listede sadece "Cilt Bakım" hizmeti sunan mekanlar gösterilir
- **AND** kategori seçimi korunur

---

### Requirement: Kategori filtresi diğer filtrelerle birlikte çalışmalı

Kategori filtresi, arama ve diğer filtrelerle kombine edilebilmelidir.

#### Scenario: Kategori + Arama

- **GIVEN** kullanıcı "Estetik" kategorisini seçmiş
- **WHEN** "Botoks" arar
- **THEN** sadece "Estetik" kategorisinde "Botoks" hizmeti sunan mekanlar gösterilir
- **AND** her iki filtre de aktif kalır

#### Scenario: Kategori + Gelişmiş Filtre

- **GIVEN** kullanıcı "Cilt Bakım" kategorisini seçmiş
- **WHEN** filtre bottom sheet'ten "Rating 4.5+" seçer
- **THEN** sadece "Cilt Bakım" kategorisinde ve rating'i 4.5+ olan mekanlar gösterilir
- **AND** her iki filtre de aktif kalır

#### Scenario: Filtreleri temizleme

- **GIVEN** kullanıcı kategori ve diğer filtreleri seçmiş
- **WHEN** "Tümü" kategorisine tıklar
- **THEN** sadece kategori filtresi temizlenir
- **AND** diğer filtreler korunur

---

### Requirement: Kategori filtresi performanslı olmalı

Kategori değişimi kullanıcı deneyimini etkilemememelidir.

#### Scenario: Kategori değişimi hızlı olmalı

- **GIVEN** kullanıcı ana sayfada
- **WHEN** bir kategoriye tıklar
- **THEN** UI anında güncellenir (debounce yok)
- **AND** sonuçlar 500ms içinde yüklenir

#### Scenario: Kategori scroll performansı

- **GIVEN** kullanıcı kategori filtrelerinde
- **WHEN** yatay scroll yapar
- **THEN** scroll smooth ve akıcı olur
- **AND** 60 FPS korunur

---

### Requirement: Kategori filtresi state'i korunmalı

Kullanıcı uygulamada gezinirken kategori seçimi korunmalıdır.

#### Scenario: Görünüm değişiminde state korunur

- **GIVEN** kullanıcı "Tırnak" kategorisini seçmiş
- **WHEN** harita görünümüne geçer ve tekrar ana sayfaya döner
- **THEN** "Tırnak" kategorisi hala seçili
- **AND** filtrelenmiş sonuçlar korunur

#### Scenario: Uygulama arka plana alınır

- **GIVEN** kullanıcı "Vücut" kategorisini seçmiş
- **WHEN** uygulamayı arka plana alır ve tekrar açar
- **THEN** "Vücut" kategorisi hala seçili
- **AND** state korunur

#### Scenario: Keşfet sekmesinden çıkıp geri dönme

- **GIVEN** kullanıcı "Kaş-Kirpik" kategorisini seçmiş
- **WHEN** başka bir sekmeye geçer ve tekrar keşfet sekmesine döner
- **THEN** kategori seçimi temizlenir
- **AND** "Tümü" kategorisi seçili hale gelir
- **AND** fresh start sağlanır
