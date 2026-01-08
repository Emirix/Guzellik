# Navigation Specification Delta

## MODIFIED Requirements

### Requirement: Bottom Navigation
The system SHALL provide a bottom navigation bar for primary app sections.

#### Scenario: Bottom navigation structure
- **WHEN** the app is launched
- **THEN** a bottom navigation bar SHALL be displayed with 5 tabs: Keşfet, Ara, Favoriler, Bildirimler, Profil

#### Scenario: Navigation state management
- **WHEN** a user taps a navigation tab
- **THEN** the active tab SHALL be highlighted and the corresponding screen SHALL be displayed

#### Scenario: Search tab navigation
- **GIVEN** kullanıcı herhangi bir ekranda
- **WHEN** "Ara" sekmesine tıklar
- **THEN** SearchScreen görüntülenmeli

## ADDED Requirements

### Requirement: Cross-Screen Search Navigation
Sistem, farklı ekranlardan arama ekranına yönlendirmeyi desteklemelidir.

#### Scenario: Keşfet'ten arama ekranına geçiş
- **GIVEN** kullanıcı Keşfet ekranında
- **WHEN** arama çubuğuna tıklar
- **THEN** navbar'da "Ara" sekmesi aktif olmalı ve SearchScreen görüntülenmeli

#### Scenario: Arama sonuçlarından haritaya geçiş
- **GIVEN** kullanıcı arama sonuçlarını görüntülüyor
- **WHEN** "Haritada Görüntüle" butonuna tıklar
- **THEN** harita görünümüne geçmeli ve arama filtreleri korunmalı
