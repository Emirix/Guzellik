# Tasks: Keşfet Ana Ekranını Geliştirme

## 1. Veri Modelleri Oluşturma
- [ ] `RecentSearch` modelini oluştur (id, query, timestamp, icon)
- [ ] `PopularService` modelini oluştur (id, name, icon, searchCount)
- [ ] Model testlerini yaz

**Validation**: Modeller doğru serialize/deserialize oluyor

---

## 2. Supabase Altyapısını Hazırlama
- [ ] `popular_services` view'ını oluştur (en çok aranan hizmetler)
- [ ] `featured_venues` view'ını oluştur (editörün seçtiği mekanlar)
- [ ] Local storage için son aramalar tablosunu oluştur
- [ ] Migration'ları test et

**Validation**: Supabase query'leri doğru veri döndürüyor

---

## 3. Repository Metodlarını Ekle
- [ ] `DiscoveryRepository`'ye `getPopularServices()` ekle
- [ ] `DiscoveryRepository`'ye `getFeaturedVenues()` ekle
- [ ] `DiscoveryRepository`'ye `getRecentSearches()` ekle
- [ ] `DiscoveryRepository`'ye `saveRecentSearch()` ekle
- [ ] `DiscoveryRepository`'ye `clearRecentSearches()` ekle
- [ ] Repository testlerini yaz

**Validation**: Repository metodları doğru çalışıyor ve hata yönetimi yapıyor

---

## 4. Provider State'ini Genişlet
- [ ] `DiscoveryViewMode` enum'ına `home` ekle
- [ ] `DiscoveryProvider`'a `recentSearches` state'i ekle
- [ ] `DiscoveryProvider`'a `popularServices` state'i ekle
- [ ] `DiscoveryProvider`'a `featuredVenues` state'i ekle
- [ ] `DiscoveryProvider`'a `selectedCategory` state'i ekle
- [ ] `loadHomeData()` metodunu ekle
- [ ] `addRecentSearch()` metodunu ekle
- [ ] `clearRecentSearches()` metodunu ekle
- [ ] `filterByCategory()` metodunu ekle

**Validation**: Provider state değişiklikleri UI'ı doğru güncelliyor

---

## 5. Kategori Filter Chips Widget'ı
- [ ] `CategoryFilterChips` widget'ını oluştur
- [ ] Yatay scroll yapısını ekle
- [ ] Seçili kategori vurgulama stilini uygula
- [ ] Kategori tıklama event'ini handle et
- [ ] Tasarıma uygun renk ve tipografi kullan

**Validation**: Kategoriler scroll edilebiliyor ve seçim çalışıyor

---

## 6. Son Aramalar Widget'ı
- [ ] `RecentSearches` widget'ını oluştur
- [ ] "Temizle" butonu ekle
- [ ] Her arama öğesi için silme (X) butonu ekle
- [ ] Arama öğesine tıklama ile yeniden arama yap
- [ ] Boş state göster (arama geçmişi yoksa)
- [ ] İkonları ekle (saat ikonu)

**Validation**: Son aramalar gösteriliyor, silinebiliyor ve tıklanabiliyor

---

## 7. Popüler Hizmetler Widget'ı
- [ ] `PopularServices` widget'ını oluştur
- [ ] Yatay scroll yapısını ekle
- [ ] Hizmet chip'lerini tasarla (rounded, border)
- [ ] Chip tıklama ile filtreleme yap
- [ ] Loading state ekle
- [ ] Boş state göster

**Validation**: Popüler hizmetler gösteriliyor ve tıklanınca filtreliyor

---

## 8. Editörün Seçimi Widget'ı
- [ ] `EditorsPick` widget'ını oluştur
- [ ] "Tümünü Gör" başlık ve butonu ekle
- [ ] Mekan kartlarını yatay scroll ile göster
- [ ] Mevcut `VenueCard` widget'ını kullan veya özelleştir
- [ ] Loading state ekle
- [ ] "Tümünü Gör" butonuna tıklama ile liste görünümüne geç

**Validation**: Editörün seçtiği mekanlar gösteriliyor ve tıklanabiliyor

---

## 9. Ana Sayfa Görünümü Widget'ı
- [ ] `DiscoveryHomeView` widget'ını oluştur
- [ ] Scroll edilebilir yapı oluştur (SingleChildScrollView)
- [ ] Başlık ("Keşfet") ve Filtrele butonu ekle
- [ ] Arama çubuğunu entegre et
- [ ] Kategori filtrelerini ekle
- [ ] Son aramaları ekle
- [ ] Popüler hizmetleri ekle
- [ ] Editörün seçimini ekle
- [ ] Boşlukları ve padding'leri tasarıma uygun ayarla

**Validation**: Ana sayfa tasarıma uygun görünüyor ve scroll edilebiliyor

---

## 10. ExploreScreen Entegrasyonu
- [ ] `ExploreScreen`'e ana sayfa görünümünü ekle
- [ ] View mode'a göre doğru görünümü göster (home/map/list)
- [ ] Varsayılan view mode'u `home` yap
- [ ] Harita ve liste görünümlerine geçiş butonlarını güncelle
- [ ] Ana sayfadan harita/liste'ye geçiş akışını test et

**Validation**: Tüm görünümler arasında geçiş sorunsuz çalışıyor

---

## 11. Arama Çubuğu Güncellemesi
- [ ] Arama çubuğuna tıklama ile arama moduna geçiş ekle
- [ ] Arama yapıldığında otomatik liste görünümüne geç
- [ ] Arama sonuçlarını göster
- [ ] Arama temizlendiğinde ana sayfaya dön

**Validation**: Arama akışı doğru çalışıyor

---

## 12. Filtrele Butonu Tasarımı
- [ ] Sağ üst köşeye "Filtrele" butonu ekle
- [ ] Pembe/kırmızı renk kullan (tasarıma uygun)
- [ ] Filtre ikonunu ekle
- [ ] Mevcut `FilterBottomSheet`'i aç
- [ ] Filtre uygulandığında badge göster

**Validation**: Filtrele butonu çalışıyor ve tasarıma uygun

---

## 13. Cache ve Performans Optimizasyonu
- [ ] Popüler hizmetler için cache ekle (5 dakika)
- [ ] Editörün seçimi için cache ekle (30 dakika)
- [ ] Son aramalar için local storage kullan
- [ ] Lazy loading uygula (gerekirse)
- [ ] Image caching optimize et

**Validation**: Ana sayfa 2 saniyeden kısa sürede yükleniyor

---

## 14. Test ve Hata Yönetimi
- [ ] Network hatası durumunda retry mekanizması ekle
- [ ] Boş state'ler için uygun mesajlar göster
- [ ] Loading state'leri ekle
- [ ] Error state'leri ekle
- [ ] Widget testleri yaz
- [ ] Integration testleri yaz

**Validation**: Tüm hata senaryoları doğru handle ediliyor

---

## 15. UI Polish ve Son Dokunuşlar
- [ ] Animasyonlar ekle (fade-in, slide)
- [ ] Scroll physics'i optimize et
- [ ] Renk ve tipografi tutarlılığını kontrol et
- [ ] Tasarım dosyası ile karşılaştır
- [ ] Dark mode desteği (varsa)
- [ ] Accessibility iyileştirmeleri

**Validation**: UI tasarıma %100 uygun ve smooth

---

## 16. Dokümantasyon ve Cleanup
- [ ] Widget'lar için dokümantasyon yaz
- [ ] README güncelle (yeni özellikler)
- [ ] Kullanılmayan kod temizle
- [ ] Lint hatalarını düzelt
- [ ] Code review yap

**Validation**: Kod temiz, dokümante ve lint-free

---

## Bağımlılıklar
- Task 2 → Task 3 (Repository Supabase'e bağımlı)
- Task 3 → Task 4 (Provider Repository'ye bağımlı)
- Task 4 → Task 5-8 (Widget'lar Provider'a bağımlı)
- Task 5-8 → Task 9 (Ana sayfa widget'lara bağımlı)
- Task 9 → Task 10 (ExploreScreen ana sayfaya bağımlı)

## Paralel Çalışılabilir Tasklar
- Task 1 (Modeller) ve Task 2 (Supabase) paralel yapılabilir
- Task 5, 6, 7, 8 (Widget'lar) paralel yapılabilir
- Task 13 (Cache) ve Task 14 (Test) paralel yapılabilir
