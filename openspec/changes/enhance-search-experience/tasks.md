# Tasks: Arama Deneyimi İyileştirmeleri

- [x] **Backend Hazırlığı**
  - [x] `get_popular_services` RPC fonksiyonu migration dosyasını oluştur. (Task 34)
  - [x] Migration'ı test et ve veritabanına uygula.

- [x] **Faz 1: Popüler Aramalar (Frontend)**
  - [x] `PopularService` model sınıfını ve mapping metodlarını oluştur.
  - [x] `VenueRepository`'ye `getPopularServices` metodunu ekle (Supabase RPC çağrısı ile).
  - [x] `SearchProvider`'a popüler aramalar yükleme ve cache mantığını ekle (TTL: 5dk).
  - [x] `PopularSearchesSection` widget'ını oluştur (Modern chip tasarımı).
  - [x] `SearchInitialView`'a bu bölümü entegre et.

- [x] **Faz 2: Sesli Arama (Frontend)**
  - [x] `speech_to_text` ve `permission_handler` paketlerini ekle.
  - [x] `VoiceSearchService` sınıfını oluştur (Permissions, initialization, listening logic).
  - [x] `SearchProvider`'a sesli arama durumlarını ve metodlarını ekle.
  - [x] `VoiceSearchDialog` widget'ını oluştur (Lottie animasyonu destekli).
  - [x] `SearchHeader` widget'ını sesli arama butonu ile güncelle.

- [x] **Test & Cila**
  - [x] Tüm akışı test et (Popüler seçimler -> arama, Ses -> arama).
  - [x] Turkish localization kontrolü yap.
  - [x] Uygulama ikonlarını ve renklerini tasarım rehberine göre fixle.
  - [x] Başarı kriterlerini doğrula ve OpenSpec arşivlemesi için hazırla.
