# Popüler Aramalar

## ADDED Requirements

### Requirement: Popüler Hizmetleri Gösterme
Kullanıcılar arama ekranının başlangıç görünümünde, sistemde en çok sunulan hizmetleri "Popüler Aramalar" bölümünde görebilmelidir.

#### Scenario: Popüler Aramalar Başarıyla Yükleniyor
- **GIVEN** Kullanıcı arama ekranına girmiştir
- **AND** Sistemde en az 3 farklı hizmet sunan işletme vardır
- **WHEN** Arama ekranı yüklendiğinde
- **THEN** "Popüler Aramalar" bölümü görüntülenir
- **AND** En çok sunulan 6-7 hizmet chip formatında gösterilir

#### Scenario: Yetersiz Veri Durumunda Popüler Aramalar Gizleniyor
- **GIVEN** Kullanıcı arama ekranına girmiştir
- **AND** Sistemde 3'ten az farklı hizmet vardır
- **WHEN** Arama ekranı yüklendiğinde
- **THEN** "Popüler Aramalar" bölümü gösterilmez

#### Scenario: Popüler Aramaya Tıklama
- **GIVEN** Kullanıcı arama ekranındadır
- **AND** "Popüler Aramalar" bölümü görüntülenmektedir
- **WHEN** Kullanıcı bir hizmet chip'ine tıkladığında
- **THEN** Arama sorgusu ilgili hizmet adı olarak ayarlanır
- **AND** İlgili hizmet için arama başlatılır

### Requirement: Popüler Hizmetleri Cache'leme
Performans optimizasyonu için popüler aramalar cihaz yerelinde cache'lenir.

#### Scenario: Cache'ten Popüler Aramalar Yükleme
- **GIVEN** Popüler aramalar daha önce yüklenmiş ve cache'lenmiştir
- **WHEN** Kullanıcı arama ekranını açtığında (5 dakika içinde)
- **THEN** Popüler aramalar veritabanına sorgu atılmadan cache'ten yüklenir

## MODIFIED Requirements

### Requirement: Category Filtering and Search
Sistem, arama çubuğu ve kategori grid'ine ek olarak popüler arama önerilerini de sunarak keşif kabiliyetini genişletir.

#### Scenario: User searches for a category
- **GIVEN** The Discovery screen is open
- **WHEN** the user enters a category name in the search bar OR selects a popular search chip
- **THEN** both the Map markers and List items SHALL be filtered to show only matching venues.
