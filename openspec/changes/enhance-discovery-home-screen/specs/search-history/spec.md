## ADDED Requirements

### Requirement: Son aramalar kaydedilmeli

Kullanıcıların yaptığı aramalar kaydedilmeli ve tekrar kullanılabilir olmalıdır.

#### Scenario: Arama yapıldığında kaydedilir

- **GIVEN** kullanıcı arama çubuğuna "Botoks" yazmış
- **WHEN** arama yapar (Enter veya arama butonu)
- **THEN** "Botoks" son aramalara eklenir
- **AND** arama local storage'a kaydedilir
- **AND** timestamp ile birlikte saklanır

#### Scenario: Duplicate aramalar engellenir

- **GIVEN** kullanıcı daha önce "Botoks" aramış
- **WHEN** tekrar "Botoks" arar
- **THEN** yeni kayıt oluşturulmaz
- **AND** mevcut kaydın timestamp'i güncellenir
- **AND** kayıt listenin en üstüne taşınır

#### Scenario: Maksimum 10 arama saklanır

- **GIVEN** kullanıcının 10 arama geçmişi var
- **WHEN** yeni bir arama yapar
- **THEN** en eski arama silinir
- **AND** yeni arama eklenir
- **AND** toplam 10 arama korunur

---

### Requirement: Son aramalar gösterilmeli

Kullanıcılar ana sayfada son aramalarını görüp tekrar kullanabilmelidir.

#### Scenario: Son aramalar bölümü gösterilir

- **GIVEN** kullanıcının arama geçmişi var
- **WHEN** ana sayfayı açar
- **THEN** "Son Aramalar" başlığı görünür
- **AND** "Temizle" butonu görünür
- **AND** son aramalar listesi görünür
- **AND** her arama öğesi saat ikonu ile gösterilir

#### Scenario: Arama geçmişi yoksa boş state

- **GIVEN** kullanıcının arama geçmişi yok
- **WHEN** ana sayfayı açar
- **THEN** "Son Aramalar" bölümü gösterilmez
- **OR** "Henüz arama yapmadınız" mesajı gösterilir

#### Scenario: Son aramalar sıralı gösterilir

- **GIVEN** kullanıcının birden fazla arama geçmişi var
- **WHEN** son aramalar bölümüne bakar
- **THEN** aramalar en yeniden en eskiye sıralanır
- **AND** en son yapılan arama en üstte görünür

---

### Requirement: Son aramalar üzerinde işlem yapılabilmeli

Kullanıcılar son aramalarını tekrar kullanabilmeli veya silebilmelidir.

#### Scenario: Arama öğesine tıklama

- **GIVEN** kullanıcı son aramalar bölümünde
- **WHEN** bir arama öğesine tıklar (örn: "Botoks")
- **THEN** arama otomatik olarak yapılır
- **AND** liste görünümüne geçilir
- **AND** "Botoks" ile ilgili mekanlar gösterilir

#### Scenario: Tek bir aramayı silme

- **GIVEN** kullanıcı son aramalar bölümünde
- **WHEN** bir arama öğesinin yanındaki "X" butonuna tıklar
- **THEN** o arama geçmişten silinir
- **AND** liste güncellenir
- **AND** local storage'dan kaldırılır

#### Scenario: Tüm aramaları temizleme

- **GIVEN** kullanıcı son aramalar bölümünde
- **WHEN** "Temizle" butonuna tıklar
- **THEN** onay dialog'u gösterilir
- **AND** kullanıcı onaylarsa tüm aramalar silinir
- **AND** "Son Aramalar" bölümü gizlenir veya boş state gösterilir

#### Scenario: Temizleme onayı iptal edilir

- **GIVEN** kullanıcı "Temizle" butonuna tıklamış
- **WHEN** onay dialog'unda "İptal" seçer
- **THEN** hiçbir arama silinmez
- **AND** dialog kapanır
- **AND** son aramalar korunur

---

### Requirement: Arama geçmişi kalıcı olmalı

Kullanıcı uygulamayı kapatıp açsa bile arama geçmişi korunmalıdır.

#### Scenario: Uygulama kapatılıp açılır

- **GIVEN** kullanıcının 5 arama geçmişi var
- **WHEN** uygulamayı kapatır ve tekrar açar
- **THEN** 5 arama geçmişi korunur
- **AND** son aramalar bölümünde görünür
- **AND** sıralama korunur

#### Scenario: Cache temizleme

- **GIVEN** kullanıcının arama geçmişi var
- **WHEN** uygulama cache'i temizlenir
- **THEN** arama geçmişi korunur
- **AND** local storage'dan yüklenir

---

### Requirement: Arama geçmişi performanslı olmalı

Arama geçmişi işlemleri kullanıcı deneyimini etkilemememelidir.

#### Scenario: Arama kaydetme hızlı olmalı

- **GIVEN** kullanıcı arama yapmış
- **WHEN** arama kaydedilir
- **THEN** işlem 100ms'den kısa sürer
- **AND** UI bloke olmaz

#### Scenario: Arama geçmişi yükleme hızlı olmalı

- **GIVEN** kullanıcı ana sayfayı açmış
- **WHEN** son aramalar yüklenir
- **THEN** işlem 200ms'den kısa sürer
- **AND** sayfa yüklenmesi geciktirilmez
