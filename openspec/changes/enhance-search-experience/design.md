# Architecture Design: Arama Deneyimi İyileştirmeleri

## Overview

Bu değişiklik, Güzellik uygulamasının arama özelliğine iki yeni capability ekler:
1. **Popüler Aramalar**: Kullanıcılara en çok sunulan hizmetleri öneren bir keşif özelliği
2. **Sesli Arama**: Kullanıcıların konuşarak arama yapabilmesini sağlayan bir kolaylık özelliği

Her iki özellik de mevcut arama altyapısını genişletir ve kullanıcı deneyimini iyileştirir.

## Components

### Backend Components

#### 1. Popüler Hizmetler RPC Fonksiyonu

**Sorumluluk**:
- `venue_services` tablosundan en çok sunulan hizmetleri sorgulamak
- Hizmetleri popülerlik sırasına göre sıralamak
- Sadece aktif hizmetleri (`is_available = true`) dahil etmek

**Bağımlılıklar**:
- `venue_services` tablosu
- `service_categories` tablosu

**Interface**:
```sql
CREATE OR REPLACE FUNCTION get_popular_services(
  p_limit INTEGER DEFAULT 7
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  icon TEXT,
  image_url TEXT,
  venue_count BIGINT
)
```

**Implementation Details**:
- `venue_services` tablosunda `service_category_id` bazında gruplama
- `COUNT(DISTINCT venue_id)` ile her hizmetin kaç işletme tarafından sunulduğunu hesaplama
- `is_available = true` filtresi
- `venue_count DESC` ile sıralama
- `LIMIT p_limit` ile sonuç sayısını sınırlama

### Frontend Components

#### 2. PopularService Model

**Sorumluluk**:
- Popüler hizmet verilerini temsil etmek
- JSON serialization/deserialization

**Bağımlılıklar**: Yok

**Interface**:
```dart
class PopularService {
  final String id;
  final String name;
  final String? icon;
  final String? imageUrl;
  final int venueCount;
  
  factory PopularService.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  PopularService copyWith({...});
}
```

#### 3. VenueRepository Extension

**Sorumluluk**:
- Popüler hizmetleri backend'den çekmek
- Hata yönetimi

**Bağımlılıklar**:
- Supabase client
- PopularService model

**Interface**:
```dart
Future<List<PopularService>> getPopularServices({int limit = 7});
```

#### 4. SearchProvider Extension (Popüler Aramalar)

**Sorumluluk**:
- Popüler aramaları yüklemek ve cache'lemek
- Popüler aramaya tıklandığında arama başlatmak
- Loading ve error state'lerini yönetmek

**Bağımlılıklar**:
- VenueRepository
- SharedPreferences (cache için)

**Interface**:
```dart
class SearchProvider extends ChangeNotifier {
  List<PopularService> popularServices = [];
  bool isLoadingPopularServices = false;
  
  Future<void> _loadPopularServices();
  Future<void> selectPopularService(PopularService service);
}
```

**State Management**:
- `popularServices`: Yüklenen popüler hizmetler listesi
- `isLoadingPopularServices`: Yükleme durumu
- Cache: SharedPreferences ile 5 dakika TTL

#### 5. PopularSearchesSection Widget

**Sorumluluk**:
- Popüler aramaları görsel olarak göstermek
- Kullanıcı etkileşimlerini handle etmek
- Loading ve empty state'leri göstermek

**Bağımlılıklar**:
- SearchProvider

**UI Structure**:
```
PopularSearchesSection
├── Başlık ("Popüler Aramalar")
├── Horizontal ScrollView
│   ├── PopularSearchChip 1
│   ├── PopularSearchChip 2
│   └── ...
└── Loading State (Shimmer)
```

#### 6. VoiceSearchService

**Sorumluluk**:
- Speech-to-text işlemlerini yönetmek
- Mikrofon izinlerini kontrol etmek
- Dinleme durumunu yönetmek

**Bağımlılıklar**:
- `speech_to_text` paketi
- `permission_handler` paketi

**Interface**:
```dart
class VoiceSearchService {
  static final VoiceSearchService instance = VoiceSearchService._();
  
  Future<bool> initialize();
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  });
  Future<void> stopListening();
  
  bool get isAvailable;
  bool get isListening;
}
```

**State Management**:
- Singleton pattern
- Internal state: `_isListening`, `_isAvailable`, `_speechToText`

#### 7. SearchProvider Extension (Sesli Arama)

**Sorumluluk**:
- Sesli arama durumunu yönetmek
- VoiceSearchService ile koordinasyon
- Tanınan metni arama input'una yazmak

**Bağımlılıklar**:
- VoiceSearchService

**Interface**:
```dart
class SearchProvider extends ChangeNotifier {
  bool isVoiceSearching = false;
  String? voiceSearchError;
  
  Future<void> startVoiceSearch();
  Future<void> stopVoiceSearch();
  void _onVoiceResult(String text);
}
```

#### 8. VoiceMicrophoneButton Widget

**Sorumluluk**:
- Mikrofon butonunu göstermek
- Tıklama etkileşimini handle etmek
- Dinleme animasyonunu göstermek

**Bağımlılıklar**:
- SearchProvider

**UI States**:
- Idle: Normal mikrofon ikonu
- Listening: Pulse animasyonlu mikrofon ikonu
- Disabled: Gri, tıklanamaz mikrofon ikonu

#### 9. VoiceSearchDialog Widget

**Sorumluluk**:
- Sesli arama sırasında kullanıcıya feedback vermek
- Tanınan metni göstermek
- İptal butonunu sağlamak

**Bağımlılıklar**:
- SearchProvider

**UI Structure**:
```
VoiceSearchDialog
├── Glassmorphism Container
│   ├── Mikrofon İkonu (Animated)
│   ├── Durum Metni ("Dinliyorum..." / Tanınan metin)
│   └── İptal Butonu
└── Backdrop (Blur effect)
```

## Data Flow

### Popüler Aramalar Data Flow

```
1. SearchScreen initState
   ↓
2. SearchProvider._loadPopularServices()
   ↓
3. Check cache (SharedPreferences)
   ├─ Cache valid → Return cached data
   └─ Cache invalid/empty → Continue
   ↓
4. VenueRepository.getPopularServices()
   ↓
5. Supabase RPC: get_popular_services()
   ↓
6. Database Query:
   SELECT sc.id, sc.name, sc.icon, sc.image_url, COUNT(DISTINCT vs.venue_id)
   FROM service_categories sc
   JOIN venue_services vs ON sc.id = vs.service_category_id
   WHERE vs.is_available = true
   GROUP BY sc.id
   ORDER BY COUNT(DISTINCT vs.venue_id) DESC
   LIMIT 7
   ↓
7. Map to PopularService models
   ↓
8. Save to cache (5 min TTL)
   ↓
9. Update SearchProvider.popularServices
   ↓
10. notifyListeners()
   ↓
11. PopularSearchesSection rebuilds
   ↓
12. User taps chip
   ↓
13. SearchProvider.selectPopularService()
   ↓
14. Set search query
   ↓
15. Trigger search
```

### Sesli Arama Data Flow

```
1. User taps microphone button
   ↓
2. SearchProvider.startVoiceSearch()
   ↓
3. VoiceSearchService.checkPermission()
   ├─ Permission granted → Continue
   └─ Permission denied → Request permission
       ├─ User grants → Continue
       └─ User denies → Show error, return
   ↓
4. VoiceSearchService.startListening()
   ↓
5. speech_to_text package starts listening
   ↓
6. Show VoiceSearchDialog
   ↓
7. User speaks
   ↓
8. speech_to_text processes audio
   ↓
9. Partial results → Update dialog text (real-time)
   ↓
10. Final result → SearchProvider._onVoiceResult(text)
   ↓
11. Set search query
   ↓
12. Close dialog
   ↓
13. Trigger search
   ↓
14. Show results
```

## Trade-offs

### Popüler Aramalar: Database View vs RPC Function

#### Option 1: Mevcut `popular_services` View'ını Kullanma

**Pros**:
- Zaten mevcut, yeni kod yazmaya gerek yok
- Basit SELECT sorgusu
- Otomatik güncellenir

**Cons**:
- Limit parametresi yok (her zaman 20 sonuç)
- `search_count` alanı kullanılmıyor (her zaman 0)
- Esneklik az

#### Option 2: Yeni RPC Fonksiyonu Oluşturma (Chosen)

**Pros**:
- Parametreli (limit ayarlanabilir)
- Daha temiz ve özelleştirilebilir
- Gelecekte genişletilebilir (örn: kategori filtresi)
- `search_count` alanını kaldırabilir veya gerçek veri ile doldurabilir

**Cons**:
- Yeni kod yazmak gerekiyor
- Migration gerekiyor

**Why Chosen**: Esneklik ve gelecek genişlemeler için RPC fonksiyonu daha uygun. Limit parametresi ile 6-7 sonuç döndürebiliriz.

### Sesli Arama: Native STT vs Cloud STT

#### Option 1: Native STT (speech_to_text paketi) (Chosen)

**Pros**:
- Ücretsiz
- Offline çalışabilir
- Düşük latency
- Privacy (veri cihazda kalır)
- Kolay entegrasyon

**Cons**:
- Doğruluk cihaza bağlı
- Türkçe desteği cihazın STT motoruna bağlı
- Özelleştirme sınırlı

#### Option 2: Google Cloud Speech-to-Text

**Pros**:
- Yüksek doğruluk
- Güçlü Türkçe desteği
- Özelleştirilebilir (custom models)

**Cons**:
- Ücretli (ilk 60 dk/ay ücretsiz)
- Internet bağlantısı gerekli
- Yüksek latency
- Privacy concerns

#### Option 3: Gemini AI

**Pros**:
- Mevcut API anahtarı kullanılabilir
- Context-aware arama (akıllı öneriler)
- Doğal dil işleme

**Cons**:
- Ücretli
- Internet bağlantısı gerekli
- Overkill (basit STT için)
- Kompleks entegrasyon

**Why Chosen**: Başlangıç için native STT yeterli ve ücretsiz. İhtiyaç olursa ileride cloud STT'ye geçiş yapılabilir. Altyapı bunu destekleyecek şekilde tasarlandı (VoiceSearchService abstraction).

### Cache Strategy: In-Memory vs SharedPreferences

#### Option 1: In-Memory Cache

**Pros**:
- Çok hızlı
- Basit implementasyon

**Cons**:
- App restart'ta kaybolur
- Memory kullanımı

#### Option 2: SharedPreferences (Chosen)

**Pros**:
- Persistent (app restart'ta kalır)
- Düşük memory kullanımı
- Flutter'da standart

**Cons**:
- Biraz daha yavaş (minimal)
- Disk I/O

**Why Chosen**: Popüler aramalar sık değişmeyen veri. SharedPreferences ile cache'lemek hem performans hem de UX açısından daha iyi. Kullanıcı uygulamayı her açtığında yeniden yükleme yapmaya gerek kalmaz.

## Migration Strategy

### Faz 1: Popüler Aramalar (Bağımsız)

1. Backend migration'ı deploy et
2. Frontend model ve repository'yi ekle
3. SearchProvider'ı genişlet
4. UI widget'larını ekle
5. SearchInitialView'ı güncelle
6. Test et ve release et

**Risk**: Düşük. Mevcut arama fonksiyonelitesini etkilemez.

### Faz 2: Sesli Arama (Bağımsız)

1. Paket bağımlılıklarını ekle
2. Platform izinlerini yapılandır
3. VoiceSearchService'i oluştur
4. SearchProvider'ı genişlet
5. UI widget'larını ekle
6. Test et ve release et

**Risk**: Orta. İzin yönetimi ve platform-specific kod gerektirir.

### Rollback Plan

Her iki özellik de feature flag ile kontrol edilebilir:

```dart
class FeatureFlags {
  static const bool enablePopularSearches = true;
  static const bool enableVoiceSearch = true;
}
```

Sorun çıkarsa flag'i `false` yaparak özelliği devre dışı bırakabiliriz.

## Performance Considerations

### Popüler Aramalar

- **Database Query**: İndeksli sorgular kullanılıyor (`idx_venue_services_service_category_id`)
- **Cache**: 5 dakika TTL ile gereksiz sorguları önlüyor
- **Limit**: Sadece 7 sonuç döndürülerek veri transferi minimize ediliyor

### Sesli Arama

- **Native Processing**: Cihazın native STT'si kullanıldığı için server yükü yok
- **Lazy Initialization**: VoiceSearchService sadece ilk kullanımda initialize ediliyor
- **Memory**: Dialog kapatıldığında listener'lar temizleniyor

## Security Considerations

### Popüler Aramalar

- **RLS Policies**: Mevcut `service_categories` ve `venue_services` RLS policy'leri geçerli
- **Public Data**: Popüler aramalar public veri, özel bilgi içermiyor

### Sesli Arama

- **Permissions**: Runtime permission kontrolü yapılıyor
- **Privacy**: Native STT kullanıldığı için ses verisi cihazda kalıyor
- **No Recording**: Ses kaydedilmiyor, sadece gerçek zamanlı işleniyor

## Testing Strategy

### Unit Tests

- PopularService model testleri
- VoiceSearchService testleri
- SearchProvider popüler aramalar testleri
- SearchProvider sesli arama testleri

### Widget Tests

- PopularSearchesSection widget testi
- VoiceMicrophoneButton widget testi
- VoiceSearchDialog widget testi

### Integration Tests

- Popüler aramaya tıklama ve arama başlatma
- Sesli arama başlatma ve metin girişi
- İzin reddetme senaryosu
- Hata durumları

### Manual Tests

- iOS ve Android'de sesli arama Türkçe tanıma
- Farklı cihazlarda mikrofon kalitesi
- Offline durumda native STT çalışması
- Popüler aramaların doğru sıralanması

## Future Enhancements

### Popüler Aramalar

1. **Gerçek Arama Analitiği**: Kullanıcıların gerçek arama geçmişinden popüler aramaları belirleme
2. **Kişiselleştirilmiş Öneriler**: Kullanıcının geçmiş aramalarına göre özelleştirilmiş popüler aramalar
3. **Trend Göstergeleri**: Yükselen trend hizmetleri işaretleme (🔥 ikonu)
4. **Kategori Bazlı Popüler Aramalar**: Her kategori için ayrı popüler aramalar

### Sesli Arama

1. **Cloud STT Entegrasyonu**: Daha yüksek doğruluk için Google Cloud STT
2. **Sesli Komutlar**: "Yakınımdaki kuaförler" gibi doğal dil komutları
3. **Çoklu Dil Desteği**: İngilizce ve diğer diller
4. **Sesli Feedback**: Kullanıcıya sesli geri bildirim (TTS)
