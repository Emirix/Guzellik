# Tasks: add-search-screen

## Phase 1: Foundation & Navigation (Bağımlılık yok)

### 1.1 Navbar Güncellemesi
- [x] `CustomBottomNav` widget'ına "Ara" sekmesi eklenmesi (search ikonu)
- [x] Sekme sıralaması: Keşfet(0), Ara(1), Favoriler(2), Bildirimler(3), Profil(4)
- [x] `AppStateProvider` güncellenerek 5 sekme desteklenmesi
- [x] `HomeScreen`'e `SearchScreen` placeholder eklenmesi
- **Doğrulama**: Navbar'da 5 sekme görünmeli, sekmeler arası geçiş çalışmalı ✅

### 1.2 Temel Modeller
- [x] `SearchFilter` model oluşturulması (`lib/data/models/search_filter.dart`)
- [x] `RecentSearch` model güncellenmesi (`lib/data/models/recent_search.dart`)
- [x] Model'lerin JSON serialization desteği
- **Doğrulama**: Dart analyzer hatasız çalışmalı ✅

### 1.3 SearchProvider Temel Yapısı
- [x] `SearchProvider` oluşturulması (`lib/presentation/providers/search_provider.dart`)
- [x] Temel state yönetimi (query, results, loading, error)
- [x] Provider'ın `main.dart`'a eklenmesi
- **Doğrulama**: Provider injection çalışmalı, state değişiklikleri UI'a yansımalı ✅

---

## Phase 2: Local Storage & Recent Searches (Phase 1'e bağlı)

### 2.1 Local Storage Entegrasyonu
- [x] Local storage fonksiyonları `SearchProvider` içinde implement edildi
- [x] Son aramaları kaydetme (`_addToRecentSearches`)
- [x] Son aramaları yükleme (`_loadRecentSearches`)
- [x] Tek arama silme (`deleteRecentSearch`)
- [x] Tüm aramaları temizleme (`clearAllRecentSearches`)
- [x] Maximum 10 arama limiti
- **Doğrulama**: Uygulama kapatılıp açıldığında aramalar korunmalı ✅

### 2.2 SearchProvider Local Storage Entegrasyonu
- [x] Provider başlatıldığında son aramaları yükleme
- [x] Arama yapıldığında otomatik kaydetme
- [x] Silme işlemlerinin provider'a bağlanması
- **Doğrulama**: Son aramalar listede görünmeli, silinebilmeli ✅

---

## Phase 3: Search Screen UI (Phase 1'e bağlı)

### 3.1 SearchScreen Temel Yapısı
- [x] `SearchScreen` oluşturulması (`lib/presentation/screens/search_screen.dart`)
- [x] Scaffold yapısı (header, content, no bottom nav overlap)
- [x] State'e göre içerik değişimi (empty, results, loading, error)
- **Doğrulama**: Ekran navbar'dan erişilebilir olmalı ✅

### 3.2 Search Header Widget
- [x] `SearchHeader` widget oluşturulması
- [x] Geri butonu (önceki sekmeye dönüş)
- [x] Arama input alanı (tıklanabilir, odaklanabilir)
- [ ] Konum alt yazısı gösterimi
- [x] Temizle (X) butonu
- [x] Harita toggle butonu
- [x] `design/ara/code.html` tasarımına uygunluk
- **Doğrulama**: Header tasarıma uygun görünmeli ✅

### 3.3 Filter Chips Row
- [x] `SearchFilterChips` widget oluşturulması
- [x] Horizontal scroll yapısı
- [x] Filtrele butonu (bottom sheet açar)
- [x] Sıralama chip'i (dropdown)
- [x] Puan filtre chip'i
- [x] "Şu An Açık" chip'i
- [x] Aktif/pasif chip stilleri
- **Doğrulama**: Chip'ler scroll edilebilmeli, tıklanabilir olmalı ✅

### 3.4 Empty State (Son Aramalar + Popüler Hizmetler)
- [x] `RecentSearchesSection` widget oluşturulması
- [x] `RecentSearchTile` oluşturuldu (ikon, text, silme butonu)
- [x] "Temizle" butonu ile tümünü silme
- [x] `PopularServicesSection` widget oluşturulması
- [x] Popüler hizmet chip'leri (şimdilik hardcoded)
- [x] `design/kesfet.html` "Son Aramalar" tasarımına uygunluk
- **Doğrulama**: Son aramalar ve popüler hizmetler görünmeli ✅

### 3.5 Search Results List
- [x] `SearchResultCard` widget oluşturulması
- [x] Venue image (mesafe badge'i ile)
- [x] Venue bilgileri (isim, konum, puan, yorum sayısı)
- [x] Hizmet etiketleri (arama ile eşleşenler vurgulu)
- [ ] Alt satır (son randevu zamanı, aksiyon butonu)
- [ ] Favori butonu entegrasyonu
- [x] `design/ara/code.html` tasarımına uygunluk
- **Doğrulama**: Sonuç kartları tasarıma uygun görünmeli ✅

### 3.6 Loading & Error States
- [ ] Shimmer/skeleton loading kartları
- [x] Hata mesajı UI'ı
- [x] "Sonuç bulunamadı" empty state
- [x] "Haritada Görüntüle" butonu
- **Doğrulama**: Tüm state'ler doğru görüntülenmeli

---

## Phase 4: Filter Bottom Sheet (Phase 3'e bağlı)

### 4.1 Filter Bottom Sheet Yapısı
- [x] `SearchFilterBottomSheet` widget oluşturulması
- [x] DraggableScrollableSheet yapısı
- [x] Header (kapat, başlık, temizle)
- [x] ScrollView içerik alanı
- [x] Alt uygula butonu (sonuç sayısı ile)
- [x] `design/filtreleme_sayfası/screen.png` tasarımına uygunluk
- **Doğrulama**: Bottom sheet açılıp kapanabilmeli ✅

### 4.2 Sıralama Bölümü
- [x] `SortOptionSection` chip'ler olarak implement edildi
- [x] Chip tabanlı seçim (Önerilen, Fiyat Artan, Fiyat Azalan)
- [x] Tek seçim (radio-like behavior)
- **Doğrulama**: Sıralama seçimi çalışmalı ✅

### 4.3 Konum Bölümü
- [ ] `LocationFilterSection` oluşturulması
- [ ] İl dropdown'ı (Türkiye illeri listesi)
- [ ] İlçe dropdown'ı (seçili ile bağımlı)
- [ ] "Konumumu Kullan" butonu
- [ ] Konum izni kontrolü ve isteme
- [ ] Reverse geocoding (koordinat → il/ilçe)
- **Doğrulama**: Konum seçimi çalışmalı, otomatik tespit yapılabilmeli

### 4.4 Mesafe Slider Bölümü
- [x] Mesafe slider'ı implement edildi
- [x] RangeSlider (1-50 km)
- [x] Mevcut değer gösterimi
- [x] Slider stili (primary renk)
- **Doğrulama**: Slider değeri değiştirilebilmeli ✅

### 4.5 Mekan Türü Bölümü
- [x] Mekan türü chip'leri
- [x] Mekan türü chip'leri (çoklu seçim)
- [x] Sabit liste: Güzellik Salonu, Kuaför, Estetik Kliniği, Tırnak Stüdyosu, Solaryum, Ayak Bakım
- **Doğrulama**: Birden fazla mekan türü seçilebilmeli ✅

### 4.6 Hizmet Filtresi Bölümü
- [ ] `ServiceFilterSection` oluşturulması
- [ ] Veritabanından hizmet listesi çekme
- [ ] Hizmet chip'leri (çoklu seçim)
- [ ] "Tümünü Gör" linki (expand/collapse veya modal)
- [ ] Seçili hizmet sayısı gösterimi
- **Doğrulama**: Hizmetler DB'den gelmeli, seçilebilmeli

### 4.7 Puan & Rozet Bölümleri
- [x] Minimum puan seçimi (yıldız butonları)
- [x] Güven rozetleri checkbox'ları
- [x] Checkbox'lar: Onaylı Mekan, Hijyen Onaylı, En Çok Tercih
- **Doğrulama**: Puan ve rozet filtreleri çalışmalı ✅

### 4.8 Filtre Uygulama
- [x] "Sonuçları Göster" butonu
- [ ] Buton üzerinde sonuç sayısı preview
- [x] Filtre uygulama ve bottom sheet kapatma
- [x] "Temizle" ile tüm filtreleri sıfırlama
- **Doğrulama**: Filtreler uygulandığında sonuçlar güncellenmeli

---

## Phase 5: Search Integration (Phase 2, 3, 4'e bağlı)

### 5.1 Arama İşlevi
- [x] SearchProvider'da arama metodu
- [x] Debounced search (300ms)
- [x] VenueRepository.searchVenues çağrısı
- [x] Filtrelerle birlikte arama
- **Doğrulama**: Arama yapıldığında sonuçlar gelmeli ✅

### 5.2 Keşfet Ekranı Entegrasyonu
- [x] `DiscoverySearchBar` tıklandığında SearchScreen'e yönlendirme
- [x] `AppStateProvider.setBottomNavIndex(1)` ile geçiş
- [ ] Mevcut arama sorgusu varsa aktarma
- **Doğrulama**: Keşfet'teki arama çubuğuna tıklanınca Ara sekmesine geçmeli ✅

### 5.3 Harita Entegrasyonu
- [ ] Arama sonuçlarından harita görünümüne geçiş
- [ ] Filtrelerin harita görünümünde korunması
- **Doğrulama**: Harita butonu çalışmalı

---

## Phase 6: Polish & Testing (Tüm phase'lere bağlı)

### 6.1 UI Polish
- [ ] Tüm animasyonların eklenmesi
- [ ] Hover/press state'leri
- [ ] Responsive layout kontrolü
- [ ] Dark mode desteği (varsa)
- **Doğrulama**: UI premium hissiyat vermeli

### 6.2 Error Handling
- [ ] Ağ hatası durumları
- [x] Boş sonuç durumu
- [ ] Konum izni reddi durumu
- [ ] Servis yükleme hatası
- **Doğrulama**: Tüm hata durumları graceful handle edilmeli

### 6.3 Performance
- [ ] Hizmet listesi caching
- [ ] Arama sonuçları pagination
- [ ] Image lazy loading
- [ ] Memory leak kontrolü
- **Doğrulama**: Performans metrikleri kabul edilebilir seviyede

### 6.4 Testler
- [ ] SearchFilter model unit testleri
- [ ] SearchProvider unit testleri
- [ ] SearchLocalStorage unit testleri
- [ ] Widget testleri (SearchResultCard, RecentSearchTile)
- **Doğrulama**: Test coverage >70%
