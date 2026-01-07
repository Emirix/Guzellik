# Tasks: Gelişmiş Filtreleme ve Arama Sistemi

## Backend Tasks

### 1. Supabase RPC Fonksiyonu Oluşturma
**Hedef**: Gelişmiş arama ve filtreleme için `search_venues_advanced` RPC fonksiyonunu oluşturmak.

**Adımlar**:
- [ ] `supabase/migrations/` klasöründe yeni migration dosyası oluştur
- [ ] `search_venues_advanced` fonksiyonunu tanımla (parametreler: search_query, category_list, min_rating, lat, lng, radius_meters)
- [ ] Fonksiyon içinde:
  - Coğrafi filtreleme (ST_DWithin)
  - Mekan adı ve hizmet adlarında metin araması (ILIKE veya full-text search)
  - Kategori filtresi (ANY array)
  - Minimum puan filtresi
  - Güven rozeti filtreleri
- [ ] Sonuçları uzaklık ve alaka düzeyine göre sırala
- [ ] Migration'ı Supabase'e uygula
- [ ] Test et: Farklı parametre kombinasyonları ile RPC'yi çağır

**Bağımlılıklar**: `database` spec

**Doğrulama**: 
- RPC fonksiyonu "Botoks Jawline" araması için doğru sonuçlar döndürmeli
- Coğrafi filtreleme çalışmalı (5km yarıçapı test et)

---

### 2. VenueRepository'de searchVenues Metodunu Güncelleme
**Hedef**: Repository'nin yeni RPC fonksiyonunu kullanmasını sağlamak.

**Adımlar**:
- [ ] `lib/data/repositories/venue_repository.dart` dosyasını aç
- [ ] `searchVenues` metodunu güncelle veya yeni oluştur
- [ ] Metod parametreleri: query, filter (VenueFilter), lat, lng
- [ ] RPC çağrısını yap: `_supabase.rpc('search_venues_advanced', params: {...})`
- [ ] Sonuçları `Venue` modeline dönüştür
- [ ] Hata yönetimi ekle

**Bağımlılıklar**: Task #1

**Doğrulama**: 
- Repository metodu çağrıldığında doğru veriler dönmeli
- Filtreler backend'e doğru iletilmeli

---

## Data Model Tasks

### 3. VenueFilter Modelini Genişletme
**Hedef**: Yeni filtre seçeneklerini desteklemek için modeli güncellemek.

**Adımlar**:
- [ ] `lib/data/models/venue_filter.dart` dosyasını aç
- [ ] Yeni alanlar ekle (eğer yoksa):
  - `List<String> services` (hizmet adları)
  - `List<String> categories` (zaten var)
  - `double? minRating` (zaten var)
  - `double? maxDistanceKm` (zaten var)
- [ ] `copyWith` metodunu güncelle
- [ ] `hasFilters` getter'ını güncelle
- [ ] `toJson` ve `fromJson` metodları ekle (opsiyonel, persistence için)

**Bağımlılıklar**: Yok

**Doğrulama**: 
- Model tüm filtre kombinasyonlarını tutabilmeli
- copyWith metodu doğru çalışmalı

---

## UI Tasks

### 4. Filter Bottom Sheet Widget Oluşturma
**Hedef**: Kullanıcıların filtreleri yönetebileceği modern bir bottom sheet.

**Adımlar**:
- [ ] `lib/presentation/widgets/discovery/filter_bottom_sheet.dart` dosyası oluştur
- [ ] Bottom sheet yapısını kur (DraggableScrollableSheet veya showModalBottomSheet)
- [ ] Bileşenler:
  - **Kategori Seçici**: Yatay kaydırılabilir Chip listesi
  - **Uzaklık Slider**: 1-50 km arası
  - **Puan Seçici**: Radio buttons veya Chip'ler (3.0+, 4.0+, 4.5+)
  - **Rozet Filtreleri**: Switch veya Checkbox'lar (Onaylı, Hijyenik, Tercih Edilen)
- [ ] "Uygula" ve "Temizle" butonları ekle
- [ ] Design klasöründeki renk paletine uygun stil uygula (nude, soft pink, gold)

**Bağımlılıklar**: Task #3

**Doğrulama**: 
- Bottom sheet açılıp kapanmalı
- Tüm filtre kontrolleri çalışmalı
- Design dosyalarına uygun görünmeli

---

### 5. Discovery Screen'e Filtre Butonu Ekleme
**Hedef**: Kullanıcıların filtre paneline erişebilmesi.

**Adımlar**:
- [ ] `lib/presentation/screens/discovery/discovery_screen.dart` dosyasını aç
- [ ] Arama çubuğunun yanına "Filtrele" ikonu ekle
- [ ] İkona tıklandığında `FilterBottomSheet` widget'ını göster
- [ ] Aktif filtre varsa ikon üzerinde badge göster (örn: kırmızı nokta)
- [ ] Bottom sheet'ten dönen filtreleri `DiscoveryProvider.updateFilter()` ile uygula

**Bağımlılıklar**: Task #4

**Doğrulama**: 
- Filtre butonu görünür ve tıklanabilir olmalı
- Bottom sheet açılmalı
- Aktif filtre durumu gösterilmeli

---

### 6. Search Bar'ı Hizmet Araması için Güncelleme
**Hedef**: Arama çubuğunun hizmet isimlerini de aramasını sağlamak.

**Adımlar**:
- [ ] `lib/presentation/widgets/discovery/search_bar.dart` dosyasını kontrol et
- [ ] Placeholder metnini güncelle: "Mekan veya hizmet ara... (örn: Botoks)"
- [ ] `onChanged` callback'inde `DiscoveryProvider.setSearchQuery()` çağrısını doğrula
- [ ] Debounce ekle (300-500ms) gereksiz API çağrılarını önlemek için

**Bağımlılıklar**: Yok

**Doğrulama**: 
- Arama yaparken backend'e doğru sorgu gitmeli
- Debounce çalışmalı

---

## Provider Tasks

### 7. DiscoveryProvider'da Filtre Yönetimi
**Hedef**: Provider'ın yeni filtre sistemini desteklemesi.

**Adımlar**:
- [ ] `lib/presentation/providers/discovery_provider.dart` dosyasını aç
- [ ] `updateFilter(VenueFilter newFilter)` metodunu doğrula (zaten var)
- [ ] `resetFilters()` metodunu doğrula (zaten var)
- [ ] `_loadVenues()` metodunun güncel `searchVenues` metodunu çağırdığını doğrula
- [ ] Filtre değişikliklerinde `notifyListeners()` çağrıldığından emin ol

**Bağımlılıklar**: Task #2, Task #3

**Doğrulama**: 
- Filtre güncellemeleri UI'ı yenilemeli
- Venue listesi filtrelere göre güncellenme

---

## Testing Tasks

### 8. Backend Testleri
**Hedef**: RPC fonksiyonunun doğru çalıştığını doğrulamak.

**Adımlar**:
- [ ] Supabase dashboard'dan RPC'yi manuel test et
- [ ] Test senaryoları:
  - Sadece arama sorgusu
  - Sadece kategori filtresi
  - Sadece uzaklık filtresi
  - Tüm filtreler birlikte
  - Boş sonuç dönen durumlar

**Bağımlılıklar**: Task #1

---

### 9. Integration Testleri
**Hedef**: End-to-end filtreleme akışını test etmek.

**Adımlar**:
- [ ] `test/integration/` klasöründe test dosyası oluştur
- [ ] Test senaryoları:
  - Filtre panelini açma
  - Kategori seçme ve sonuçları görme
  - Uzaklık değiştirme ve haritanın güncellenmesi
  - Filtreleri temizleme
  - Arama + filtre kombinasyonu

**Bağımlılıklar**: Tüm UI ve backend task'ları

---

## Documentation Tasks

### 10. Kullanıcı Dokümantasyonu
**Hedef**: Filtreleme sisteminin nasıl kullanılacağını açıklamak.

**Adımlar**:
- [ ] README veya docs klasöründe filtreleme rehberi oluştur
- [ ] Ekran görüntüleri ekle
- [ ] Örnek kullanım senaryoları yaz

**Bağımlılıklar**: Tüm task'lar tamamlandıktan sonra

---

## Sıralama Önerisi

1. **Backend Hazırlık**: Task #1, #2 (RPC ve Repository)
2. **Model Güncelleme**: Task #3 (VenueFilter)
3. **UI Geliştirme**: Task #4, #5, #6 (Bottom Sheet, Buton, Search Bar)
4. **Provider Entegrasyonu**: Task #7
5. **Test ve Doğrulama**: Task #8, #9
6. **Dokümantasyon**: Task #10

**Paralel Çalışılabilir**: Task #3 ve #6 diğer task'lardan bağımsız olarak yapılabilir.
