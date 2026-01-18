# discovery Delta Spec

## ADDED Requirements

### Requirement: Popular Service Suggestions
Sistem, kullanıcıların arama ekranında en çok sunulan hizmetleri görebilmesini sağlamalıdır (SHALL).

#### Scenario: Displaying popular services
- **GIVEN** Kullanıcı arama ekranındadır
- **AND** Sistemde yeterli hizmet verisi mevcuttur
- **WHEN** Ekran yüklendiğinde
- **THEN** "Popüler Aramalar" bölümü gösterilir
- **AND** En çok sunulan 7 hizmet listelenir

#### Scenario: Selecting a popular service
- **GIVEN** Popüler aramalar gösterilmektedir
- **WHEN** Kullanıcı bir hizmete tıkladığında
- **THEN** Bu hizmet için otomatik arama başlatılır

### Requirement: Voice-to-Text Search
Kullanıcılar arama çubuğundaki mikrofon butonunu kullanarak sesli arama yapabilmelidir (SHALL).

#### Scenario: Voice search activation
- **GIVEN** Kullanıcı arama ekranındadır
- **WHEN** Mikrofon ikonuna tıkladığında
- **THEN** Sesli dinleme modu aktif olur
- **AND** Konuşma metne dönüştürülerek arama başlatılır

## MODIFIED Requirements

### Requirement: Category Filtering and Search
Arama çubuğu (SHALL), hem klavye girişini hem de sesli girişi desteklemelidir (SHALL); ayrıca popüler aramalar ile entegre çalışmalıdır (SHALL).

#### Scenario: User searches for a category
- **GIVEN** The Discovery screen is open
- **WHEN** the user enters text via keyboard OR speaks into the microphone OR selects a popular search chip
- **THEN** both the Map markers and List items SHALL be filtered to show only matching venues.
