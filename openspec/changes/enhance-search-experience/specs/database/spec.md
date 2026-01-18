# database Delta Spec

## ADDED Requirements

### Requirement: Popular Services RPC
Sistem, en çok sunulan hizmetleri veritabanı seviyesinde hesaplayıp döndüren bir fonksiyon sağlamalıdır (SHALL).

#### Scenario: Calling popular services function
- **GIVEN** Veritabanında `venue_services` verisi mevcuttur
- **WHEN** `get_popular_services(limit => 7)` fonksiyonu çağrıldığında
- **THEN** En çok işletme tarafından sunulan 7 hizmet bilgisi döner
- **AND** Sonuçlar `venue_count` değerine göre büyükten küçüğe sıralanır
