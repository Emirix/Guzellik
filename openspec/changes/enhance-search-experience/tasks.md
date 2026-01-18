# Tasks: Arama Deneyimi İyileştirmeleri

## 1. Backend Hazırlık
- [ ] 1.1 `get_popular_services` RPC fonksiyonu migration dosyasını oluştur
- [ ] 1.2 Migration'ı test et ve veritabanına uygula

## 2. Popüler Aramalar (Frontend)
- [ ] 2.1 `PopularService` model sınıfını ve mapping metodlarını oluştur
- [ ] 2.2 `VenueRepository`'ye `getPopularServices` metodunu ekle
- [ ] 2.3 `SearchProvider`'a popüler aramalar yükleme ve cache mantığını ekle
- [ ] 2.4 `PopularSearchesSection` widget'ını tasarla ve kodla
- [ ] 2.5 `SearchInitialView` ekranına popüler aramalar bölümünü entegre et

## 3. Sesli Arama (Frontend)
- [ ] 3.1 `speech_to_text` ve `permission_handler` paketlerini ekle
- [ ] 3.2 Android ve iOS platform izinlerini yapılandır
- [ ] 3.3 `VoiceSearchService` abstract servisini ve STT mantığını oluştur
- [ ] 3.4 `SearchProvider`'ı sesli arama durumunu yönetecek şekilde güncelle
- [ ] 3.5 Mikrofon butonu ve dinleme dialog'u UI bileşenlerini oluştur
- [ ] 3.6 `SearchHeader` widget'ına sesli arama girişini entegre et

## 4. Test ve Validasyon
- [ ] 4.1 Tüm metinleri Türkçe lokalizasyon dosyasına ekle
- [ ] 4.2 Widget ve entegrasyon testlerini yaz
- [ ] 4.3 iOS ve Android simülatörlerinde ses tanıma doğruluğunu kontrol et
- [ ] 4.4 Başarı kriterlerini doğrula ve OpenSpec arşivlemesi için hazırla
