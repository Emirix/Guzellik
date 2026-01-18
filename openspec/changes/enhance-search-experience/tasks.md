# Implementation Tasks

## Faz 1: Popüler Aramalar Backend

### Task 1.1: Popüler Hizmetler RPC Fonksiyonu Oluşturma
- [ ] `get_popular_services` RPC fonksiyonu oluştur
  - Validation: `openspec validate enhance-search-experience --strict` başarılı
  - Dependencies: Yok
  - Details:
    - `venue_services` tablosundan en çok kullanılan hizmetleri getir
    - `service_category_id` bazında gruplama yap
    - `venue_count` ile sıralama yap (DESC)
    - Limit 7 sonuç
    - `is_available = true` filtresi ekle

### Task 1.2: Migration Dosyası Oluşturma
- [ ] Supabase migration dosyası oluştur ve test et
  - Validation: Migration başarıyla çalışıyor, RPC fonksiyonu çağrılabiliyor
  - Dependencies: Task 1.1
  - Details:
    - Migration dosyası: `supabase/migrations/YYYYMMDDHHMMSS_add_popular_services_rpc.sql`
    - RPC fonksiyonunu oluştur
    - GRANT permissions ekle (anon, authenticated)
    - Rollback script'i ekle

## Faz 2: Popüler Aramalar Frontend

### Task 2.1: PopularService Model Oluşturma
- [ ] `PopularService` model sınıfı oluştur
  - Validation: Model testleri geçiyor
  - Dependencies: Yok
  - Details:
    - Dosya: `lib/data/models/popular_service.dart`
    - Fields: `id`, `name`, `icon`, `imageUrl`, `venueCount`
    - `fromJson` ve `toJson` metodları
    - `copyWith` metodu
    - Equality override

### Task 2.2: Repository Metodunu Ekleme
- [ ] `VenueRepository`'ye `getPopularServices` metodu ekle
  - Validation: Repository testi geçiyor
  - Dependencies: Task 1.2, Task 2.1
  - Details:
    - `getPopularServices()` metodu
    - Supabase RPC çağrısı
    - Error handling
    - Model mapping

### Task 2.3: SearchProvider'a Popüler Aramalar Ekleme
- [ ] `SearchProvider`'a popüler aramalar state ve metodları ekle
  - Validation: Provider testleri geçiyor
  - Dependencies: Task 2.2
  - Details:
    - `List<PopularService> popularServices` state
    - `bool isLoadingPopularServices` state
    - `_loadPopularServices()` private metodu
    - `selectPopularService(PopularService)` metodu
    - Cache mekanizması (SharedPreferences, 5 dk TTL)
    - initState'te yükleme

### Task 2.4: Popüler Aramalar Widget'ı Oluşturma
- [ ] `PopularSearchesSection` widget'ı oluştur
  - Validation: Widget testi geçiyor, UI tasarım dosyasına uygun
  - Dependencies: Task 2.3
  - Details:
    - Dosya: `lib/presentation/widgets/search/popular_searches_section.dart`
    - Horizontal scrollable chip list
    - Her chip: hizmet adı, ikon (opsiyonel)
    - Tıklama animasyonu
    - Loading state (shimmer)
    - Empty state (minimum 3 hizmet yoksa gizle)
    - Premium tasarım (gradient, shadow, rounded)

### Task 2.5: SearchInitialView'a Popüler Aramalar Ekleme
- [ ] `SearchInitialView`'a popüler aramalar bölümünü ekle
  - Validation: Arama ekranında popüler aramalar görünüyor
  - Dependencies: Task 2.4
  - Details:
    - Kategorilerin altına `PopularSearchesSection` ekle
    - Başlık: "Popüler Aramalar" veya "Trend Hizmetler"
    - Spacing ve padding ayarları
    - Responsive tasarım

## Faz 3: Sesli Arama Backend Hazırlık

### Task 3.1: Paket Bağımlılıklarını Ekleme
- [ ] `speech_to_text` ve `permission_handler` paketlerini ekle
  - Validation: `flutter pub get` başarılı, paketler yüklendi
  - Dependencies: Yok
  - Details:
    - `pubspec.yaml`'a ekle:
      - `speech_to_text: ^6.6.0`
      - `permission_handler: ^11.3.0`
    - `flutter pub get` çalıştır

### Task 3.2: Platform İzinlerini Yapılandırma
- [ ] Android ve iOS için mikrofon izinlerini yapılandır
  - Validation: İzin dialog'ları gösteriliyor
  - Dependencies: Task 3.1
  - Details:
    - **Android**: `android/app/src/main/AndroidManifest.xml`
      - `<uses-permission android:name="android.permission.RECORD_AUDIO"/>`
      - `<uses-permission android:name="android.permission.INTERNET"/>`
    - **iOS**: `ios/Runner/Info.plist`
      - `NSMicrophoneUsageDescription`: "Sesli arama yapmak için mikrofon iznine ihtiyacımız var"
      - `NSSpeechRecognitionUsageDescription`: "Konuşmanızı metne dönüştürmek için izin gerekli"

## Faz 4: Sesli Arama Frontend

### Task 4.1: VoiceSearchService Oluşturma
- [ ] Sesli arama servisi oluştur
  - Validation: Servis testleri geçiyor
  - Dependencies: Task 3.2
  - Details:
    - Dosya: `lib/core/services/voice_search_service.dart`
    - Singleton pattern
    - Metodlar:
      - `Future<bool> initialize()` - STT başlatma
      - `Future<bool> checkPermission()` - İzin kontrolü
      - `Future<bool> requestPermission()` - İzin isteme
      - `Future<void> startListening(Function(String) onResult)` - Dinleme başlat
      - `Future<void> stopListening()` - Dinleme durdur
      - `bool get isAvailable` - STT mevcut mu
      - `bool get isListening` - Dinliyor mu
    - Türkçe locale: `tr_TR`
    - Error handling

### Task 4.2: SearchProvider'a Sesli Arama Ekleme
- [ ] `SearchProvider`'a sesli arama state ve metodları ekle
  - Validation: Provider testleri geçiyor
  - Dependencies: Task 4.1
  - Details:
    - `bool isVoiceSearching` state
    - `String? voiceSearchError` state
    - `startVoiceSearch()` metodu
    - `stopVoiceSearch()` metodu
    - `_onVoiceResult(String text)` callback
    - Error handling ve user feedback

### Task 4.3: Mikrofon Butonu Widget'ı Oluşturma
- [ ] `VoiceMicrophoneButton` widget'ı oluştur
  - Validation: Widget testi geçiyor, animasyonlar akıcı
  - Dependencies: Task 4.2
  - Details:
    - Dosya: `lib/presentation/widgets/search/voice_microphone_button.dart`
    - İkon: `Icons.mic` (idle), `Icons.mic_none` (listening)
    - Animasyon: Pulse effect dinlerken
    - Renk: Primary color (idle), accent color (listening)
    - Tıklama: `onPressed` callback
    - Tooltip: "Sesli arama"
    - Disabled state (izin yoksa)

### Task 4.4: SearchHeader'a Mikrofon Butonu Ekleme
- [ ] `SearchHeader` widget'ına mikrofon butonunu ekle
  - Validation: Mikrofon butonu arama çubuğunda görünüyor
  - Dependencies: Task 4.3
  - Details:
    - Arama input'unun sağ tarafına `VoiceMicrophoneButton` ekle
    - Spacing ayarları
    - Provider'dan `isVoiceSearching` state'ini dinle
    - `onPressed`: `provider.startVoiceSearch()`

### Task 4.5: Sesli Arama Dialog'u Oluşturma
- [ ] Sesli arama sırasında gösterilecek dialog oluştur
  - Validation: Dialog gösteriliyor, animasyonlar çalışıyor
  - Dependencies: Task 4.4
  - Details:
    - Dosya: `lib/presentation/widgets/search/voice_search_dialog.dart`
    - Animasyon: Mikrofon ikonu pulse effect
    - Metin: "Dinliyorum..." / "Konuşun..."
    - Tanınan metin gösterimi (real-time)
    - İptal butonu
    - Hata mesajı gösterimi
    - Premium tasarım (glassmorphism)

## Faz 5: Localization ve Testing

### Task 5.1: Türkçe String'leri Ekleme
- [ ] Tüm yeni string'leri localization dosyasına ekle
  - Validation: Tüm metinler Türkçe gösteriliyor
  - Dependencies: Tüm UI task'ları
  - Details:
    - Dosya: `lib/core/localization/tr.dart` (veya ilgili dosya)
    - String'ler:
      - "Popüler Aramalar"
      - "Trend Hizmetler"
      - "Sesli arama"
      - "Dinliyorum..."
      - "Konuşun..."
      - "Mikrofon iznine ihtiyacımız var"
      - "Sesli arama kullanılamıyor"
      - "Bir hata oluştu, lütfen tekrar deneyin"

### Task 5.2: Widget Testleri Yazma
- [ ] Tüm yeni widget'lar için testler yaz
  - Validation: Tüm testler geçiyor, coverage %80+
  - Dependencies: Tüm widget task'ları
  - Details:
    - `test/presentation/widgets/search/popular_searches_section_test.dart`
    - `test/presentation/widgets/search/voice_microphone_button_test.dart`
    - `test/presentation/widgets/search/voice_search_dialog_test.dart`
    - Widget rendering testleri
    - Interaction testleri
    - State change testleri

### Task 5.3: Integration Testleri Yazma
- [ ] Popüler aramalar ve sesli arama için integration testleri yaz
  - Validation: Integration testleri geçiyor
  - Dependencies: Task 5.2
  - Details:
    - `integration_test/search_experience_test.dart`
    - Popüler aramaya tıklama senaryosu
    - Sesli arama başlatma senaryosu
    - İzin reddetme senaryosu
    - Error handling senaryoları

## Faz 6: Finalizasyon

### Task 6.1: iOS ve Android'de Test Etme
- [ ] Her iki platformda manuel test yap
  - Validation: Tüm özellikler her iki platformda çalışıyor
  - Dependencies: Tüm task'lar
  - Details:
    - iOS simulator ve gerçek cihazda test
    - Android emulator ve gerçek cihazda test
    - Sesli arama Türkçe tanıma testi
    - İzin akışları testi
    - Popüler aramalar testi
    - Performance testi

### Task 6.2: Dokümantasyon Güncelleme
- [ ] README ve ilgili dokümanları güncelle
  - Validation: Dokümantasyon güncel ve doğru
  - Dependencies: Task 6.1
  - Details:
    - Yeni özellikler README'ye ekle
    - API dokümantasyonu güncelle
    - Kullanıcı rehberi güncelle (varsa)
    - Changelog güncelle

### Task 6.3: Code Review ve Refactoring
- [ ] Kod kalitesini kontrol et ve iyileştir
  - Validation: Lint hataları yok, code review onaylandı
  - Dependencies: Task 6.2
  - Details:
    - `flutter analyze` çalıştır ve hataları düzelt
    - Code review yap
    - Gereksiz kod temizle
    - Performance optimizasyonları
    - Accessibility kontrolleri

### Task 6.4: Final Validation
- [ ] Tüm success criteria'ları kontrol et
  - Validation: Tüm success criteria karşılandı
  - Dependencies: Task 6.3
  - Details:
    - proposal.md'deki success criteria'ları tek tek kontrol et
    - Eksik varsa tamamla
    - Son testleri çalıştır
    - Production'a hazır olduğunu onayla
