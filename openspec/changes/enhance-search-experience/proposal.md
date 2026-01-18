# Change: Arama Deneyimi İyileştirmeleri (Popüler Aramalar ve Sesli Arama)

## Why
Kullanıcılar arama ekranında ne arayacaklarını bilmediklerinde kayboluyorlar ve hareket halindeyken klavye girişi zorlayıcı olabiliyor. Bu değişiklik, keşif sürecini kolaylaştırmak ve erişilebilirliği artırmak için popüler hizmet önerileri ve sesli arama özelliklerini ekler.

## What Changes
- **Popüler Aramalar**: Arama ekranının başlangıç görünümünde en çok sunulan 7 hizmeti chip formatında gösteren yeni bir bölüm eklenir.
- **Sesli Arama**: Arama çubuğuna entegre edilmiş, `speech_to_text` paketi kullanan ve Türkçe destekleyen sesli arama özelliği eklenir.
- **Backend Entegrasyonu**: Popüler hizmetleri `venue_services` tablosundan çeken yeni bir RPC fonksiyonu (`get_popular_services`) eklenir.
- **Provider Genişletme**: `SearchProvider`, popüler aramaları yüklemek, cache'lemek ve sesli arama durumunu yönetmek için güncellenir.

## Impact
- Affected specs: `discovery`, `database`
- Affected code: `SearchProvider`, `SearchHeader`, `SearchInitialView`, `VenueRepository`
