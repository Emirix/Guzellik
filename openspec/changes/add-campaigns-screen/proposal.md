# Change: Kampanya Sayfası Ekleme

## Why

Kullanıcıların işletmelerin sunduğu kampanyaları keşfedebilmesi ve takip edebilmesi için merkezi bir kampanya sayfasına ihtiyaç var. Navbar'daki floating action button (FAB) üzerinden erişilebilir olacak bu sayfa, kullanıcılara aktif kampanyaları görüntüleme, filtreleme ve detaylarını inceleme imkanı sunacak.

Teklif iste (quote request) özelliği kaldırıldığı için FAB'ın yeni bir amacı olacak ve kullanıcı deneyimi kampanyalar etrafında şekillenecek.

## What Changes

- **Yeni Kampanya Ekranı**: Kullanıcıların kampanyaları listeleyebileceği, filtreleyebileceği ve sıralayabileceği bir sayfa
- **Kampanya Detay Bottom Sheet**: Kampanya kartına tıklandığında açılacak detay görünümü
- **FAB Yönlendirmesi**: Floating action button artık kampanya sayfasına yönlendirecek
- **Kampanya Filtreleme**: İndirim oranı ve tarihe göre sıralama özellikleri
- **Database Schema**: `campaigns` tablosu ve ilgili migration dosyaları
- **Kampanya Modeli ve Repository**: Veri yönetimi için gerekli altyapı
- **Kampanya Provider**: State management için provider yapısı

**NOT**: Bu değişiklik sadece kullanıcı tarafını içerir. İşletme tarafından kampanya ekleme/düzenleme özellikleri gelecek bir değişiklikte ele alınacak.

## Impact

### Affected Specs
- `campaigns` (YENİ): Kampanya yönetimi ve görüntüleme
- `database`: Yeni `campaigns` tablosu
- `navigation`: FAB'ın yeni davranışı

### Affected Code
- `lib/presentation/screens/home_screen.dart`: FAB yönlendirmesi
- `lib/presentation/screens/campaigns_screen.dart`: YENİ
- `lib/presentation/widgets/campaigns/`: YENİ widget'lar
- `lib/data/models/campaign.dart`: YENİ model
- `lib/data/repositories/campaign_repository.dart`: YENİ repository
- `lib/presentation/providers/campaign_provider.dart`: YENİ provider
- `supabase/migrations/`: Yeni migration dosyası

### Breaking Changes
- **BREAKING**: Floating action button artık quote request yerine campaigns sayfasına yönlendiriyor
- Quote request özelliği tamamen kaldırılıyor
