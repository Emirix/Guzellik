## 1. Database Migration

- [x] 1.1 `campaigns` tablosu oluşturma migration dosyası
  - [x] 1.1.1 Tablo yapısı (id, venue_id, title, description, discount_percentage, discount_amount, start_date, end_date, image_url, is_active, created_at, updated_at)
  - [x] 1.1.2 Foreign key constraints (venue_id -> venues.id)
  - [x] 1.1.3 Indexes (venue_id, is_active, start_date, end_date)
  - [x] 1.1.4 RLS policies (public read for active campaigns)
- [x] 1.2 Migration dosyasını test etme

## 2. Data Layer

- [x] 2.1 Campaign model oluşturma (`lib/data/models/campaign.dart`)
  - [x] 2.1.1 Model sınıfı ve özellikleri
  - [x] 2.1.2 `fromJson` factory method
  - [x] 2.1.3 `toJson` method
  - [x] 2.1.4 `copyWith` method
  - [x] 2.1.5 Yardımcı getter'lar (isActive, isExpiringSoon, formattedDiscount)
- [x] 2.2 Campaign repository oluşturma (`lib/data/repositories/campaign_repository.dart`)
  - [x] 2.2.1 `getAllCampaigns()` - Tüm aktif kampanyaları getir
  - [x] 2.2.2 `getCampaignById(id)` - Belirli bir kampanyayı getir
  - [x] 2.2.3 `getCampaignsByVenue(venueId)` - İşletmeye özel kampanyalar
  - [x] 2.2.4 Filtreleme ve sıralama parametreleri

## 3. State Management

- [x] 3.1 Campaign provider oluşturma (`lib/presentation/providers/campaign_provider.dart`)
  - [x] 3.1.1 Kampanya listesi state yönetimi
  - [x] 3.1.2 Loading/error state'leri
  - [x] 3.1.3 `fetchCampaigns()` method
  - [x] 3.1.4 Filtreleme state'i (sortBy: discount/date)
  - [x] 3.1.5 `applySorting()` method
- [x] 3.2 Provider'ı main.dart'a ekleme

## 4. UI Components

- [x] 4.1 Campaign card widget (`lib/presentation/widgets/campaigns/campaign_card.dart`)
  - [x] 4.1.1 Kampanya görseli (opsiyonel, fallback icon)
  - [x] 4.1.2 İşletme adı ve logosu
  - [x] 4.1.3 Kampanya başlığı
  - [x] 4.1.4 İndirim badge'i (% veya ₺)
  - [x] 4.1.5 Geçerlilik tarihi gösterimi
  - [x] 4.1.6 "Yakında sona eriyor" badge'i (son 3 gün)
  - [x] 4.1.7 Tıklama event'i
- [x] 4.2 Campaign detail bottom sheet (`lib/presentation/widgets/campaigns/campaign_detail_bottom_sheet.dart`)
  - [x] 4.2.1 Kampanya görseli (hero image)
  - [x] 4.2.2 İşletme bilgileri (ad, logo, konum)
  - [x] 4.2.3 Kampanya başlığı ve açıklaması
  - [x] 4.2.4 İndirim detayları
  - [x] 4.2.5 Geçerlilik tarihleri
  - [x] 4.2.6 "İşletmeye Git" butonu (venue detail sayfasına yönlendirme)
- [x] 4.3 Campaign filter/sort widget (`lib/presentation/widgets/campaigns/campaign_sort_options.dart`)
  - [x] 4.3.1 "İndirim Oranına Göre" seçeneği
  - [x] 4.3.2 "Tarihe Göre" seçeneği (yeniden eskiye)
  - [x] 4.3.3 "Yakında Sona Erecekler" seçeneği

## 5. Campaigns Screen

- [x] 5.1 Campaigns screen oluşturma (`lib/presentation/screens/campaigns_screen.dart`)
  - [x] 5.1.1 AppBar (başlık: "Kampanyalar", sort butonu)
  - [x] 5.1.2 Loading state (shimmer/skeleton)
  - [x] 5.1.3 Empty state ("Henüz kampanya yok")
  - [x] 5.1.4 Error state
  - [x] 5.1.5 Kampanya listesi (ListView/GridView)
  - [x] 5.1.6 Pull-to-refresh
  - [x] 5.1.7 Bottom sheet açma logic'i
- [x] 5.2 Routing yapılandırması
  - [x] 5.2.1 Route tanımı ekleme
  - [x] 5.2.2 Route parametreleri (opsiyonel: venueId filter)

## 6. Navigation Updates

- [x] 6.1 FAB yönlendirmesini güncelleme (`lib/presentation/screens/home_screen.dart`)
  - [x] 6.1.1 Quote request kodunu kaldırma
  - [x] 6.1.2 Campaigns sayfasına yönlendirme
  - [x] 6.1.3 FAB icon'unu güncelleme (local_offer veya campaign)
- [ ] 6.2 Quote provider ve ilgili kodları temizleme
  - [ ] 6.2.1 QuoteProvider'ı kaldırma
  - [ ] 6.2.2 Quote-related screen'leri kaldırma
  - [ ] 6.2.3 Quote-related widget'ları kaldırma
  - [ ] 6.2.4 Quote-related model ve repository'leri kaldırma

## 7. Integration

- [ ] 7.1 Venue detail sayfasından kampanyalara erişim
  - [ ] 7.1.1 "Kampanyalar" section ekleme (eğer venue'nun aktif kampanyası varsa)
  - [ ] 7.1.2 Mini kampanya kartları
  - [ ] 7.1.3 "Tüm Kampanyaları Gör" butonu
- [x] 7.2 Test data ekleme
  - [x] 7.2.1 Seed script'e örnek kampanyalar ekleme
  - [x] 7.2.2 Farklı venue'lara kampanyalar atama

## 8. Testing & Polish

- [ ] 8.1 Kampanya kartı responsive tasarımı
- [ ] 8.2 Bottom sheet animasyonları
- [ ] 8.3 Filtreleme ve sıralama testleri
- [ ] 8.4 Edge case'ler (süresi dolmuş kampanyalar, görsel olmayan kampanyalar)
- [ ] 8.5 Performance optimizasyonu (lazy loading, caching)
- [ ] 8.6 Accessibility (semantic labels, contrast)

## 9. Documentation

- [ ] 9.1 Campaign model dokümantasyonu
- [ ] 9.2 API endpoint dokümantasyonu (RPC functions varsa)
- [ ] 9.3 Widget kullanım örnekleri
