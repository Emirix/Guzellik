# Design: Advanced Filtering System

## Architectural Reasoning

### Search Strategy
Kullanıcıların "Botoks + Jawline" gibi aramalar yapabilmesi için, Supabase üzerinde hem mekan adını hem de mekanın sunduğu servislerin adlarını tarayan bir yapı kurulacaktır.

1.  **RPC Function (`search_venues_advanced`)**:
    - Parametreler: `search_query` (text), `category_list` (text[]), `min_rating` (float), `lat` (float), `lng` (float), `radius_meters` (float).
    - İşleyiş:
        - `venues` tablosunda `location` bazlı filtreleme yapar.
        - Eğer `search_query` varsa, hem `venues.name` hem de ilişkili `services.name` kolonlarında arama yapar.
        - `category_list` ve `min_rating` filtrelerini uygular.
        - Sonuçları uzaklık ve alaka düzeyine göre sıralar.

### Filtering UI
Discovery ekranının üst kısmındaki arama çubuğunun yanına bir "Filtrele" butonu eklenecektir. Bu butona tıklandığında açılacak Bottom Sheet şunları içerecektir:

- **Kategoriler**: Yatay kaydırılabilir Chip listesi veya Grid.
- **Uzaklık**: Slider (0 - 50 km).
- **Puan**: Yıldız bazlı seçici (3.0+, 4.0+, 4.5+).
- **Rozetler**: "Onaylı", "Hijyenik" gibi switch/chip filtreler.

### State Management
- `DiscoveryProvider` mevcut `VenueFilter` modelini kullanmaya devam edecek, ancak modeli yeni ihtiyaçlara (arama sorgusu içindeki çoklu terimleri ayrıştırma vb.) göre genişletecektir.
- Filtreler değiştiğinde `refresh()` metodu çağrılarak Supabase'den yeni veri çekilecektir.

## Risks and Trade-offs
- **Performans**: Coğrafi sorgu ile metin aramasını birleştirmek, veri seti büyüdüğünde yavaşlayabilir. Bu yüzden uygun indexler (`gist` on location, `gin` on text) kullanılmalıdır.
- **Google Maps**: Map view üzerindeki markerların filtrelere göre anlık güncellenmesi akıcılığı bozmamalıdır.
