# Change: Ana Keşif Modülü - Harita ve Liste Görünümü

## Why

Uygulamanın temel değeri, kullanıcıların çevrelerindeki güzellik merkezlerini kolayca keşfetmesini sağlamaktır. Bu modül, kullanıcıların mekanları hem coğrafi olarak (harita) hem de liste halinde görmelerine olanak tanıyarak keşif deneyimini başlatır.

## What Changes

- Google Maps entegrasyonu ile interaktif harita görünümü eklenmesi
- Harita üzerinde mekanların konumlarını gösteren özel işaretçiler (Markers)
- Harita ve Liste görünümleri arasında pürüzsüz geçiş mekanizması
- Mekan adı veya kategorisine göre temel arama işlevi
- Kullanıcının mevcut konumunu belirleme ve haritayı oraya odaklama

## Impact

### Affected Specs
- `discovery`: Yeni keşif özellikleri ve gereksinimleri (YENİ)
- `navigation`: Harita/Liste ekranına yönlendirme

### Affected Code
- `lib/presentation/screens/discovery/`: Keşif ekranı ve alt bileşenleri
- `lib/data/services/location_service.dart`: Mevcut servis genişletilmesi
- `lib/presentation/widgets/discovery/`: Harita ve liste öğesi bileşenleri

### Breaking Changes
Yok.

## Dependencies
- Google Maps API Key (Yapılandırılmış olmalı)
- `google_maps_flutter` paketi
- `geolocator` paketi

## Success Criteria
- [x] Uygulama açıldığında veya keşif sekmesine gelindiğinde harita yükleniyor.
- [x] Harita üzerinde mekan işaretçileri görünüyor ve tıklanabiliyor.
- [x] Bir buton aracılığıyla Liste ve Harita görünümü arasında geçiş yapılabiliyor.
- [x] Arama çubuğu üzerinden yapılan aramalar sonuçları filtreliyor/haritayı güncelliyor.
- [x] Kullanıcı konumu izin verildiğinde harita üzerinde gösteriliyor.
