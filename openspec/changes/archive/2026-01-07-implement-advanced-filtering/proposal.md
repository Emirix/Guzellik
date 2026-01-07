# Change: Gelişmiş Filtreleme ve Arama Sistemi

## Why
Mevcut sistemde sadece basit metin araması bulunmaktadır. Kullanıcılar "Botoks + Jawline" gibi spesifik hizmet kombinasyonlarını arayamamakta, kategori/puan/uzaklık bazlı filtreleme yapamamaktadır. Bu durum kullanıcı deneyimini olumsuz etkilemekte ve mekan keşfini zorlaştırmaktadır.

## What Changes
- Supabase'de `search_venues_advanced` RPC fonksiyonu ekleniyor (hizmet adı, kategori, puan, konum filtrelerini destekler)
- `VenueFilter` modeli genişletiliyor (hizmet listesi desteği)
- `VenueRepository.searchVenues()` metodu yeni RPC'yi kullanacak şekilde güncelleniyor
- Yeni `FilterBottomSheet` widget'ı oluşturuluyor (kategori, puan, uzaklık, rozet filtreleri)
- Discovery ekranına filtre butonu ekleniyor
- Arama çubuğu hizmet aramasını destekleyecek şekilde güncelleniyor

## Impact
- Affected specs: `discovery` (ADDED requirements), `database` (ADDED RPC function)
- Affected code:
  - `lib/data/models/venue_filter.dart` (model genişletme)
  - `lib/data/repositories/venue_repository.dart` (RPC entegrasyonu)
  - `lib/presentation/providers/discovery_provider.dart` (filtre yönetimi)
  - `lib/presentation/screens/discovery/discovery_screen.dart` (filtre butonu)
  - `lib/presentation/widgets/discovery/` (yeni FilterBottomSheet)
  - `supabase/migrations/` (yeni RPC migration)
