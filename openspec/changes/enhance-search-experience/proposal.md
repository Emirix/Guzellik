# Arama Deneyimi İyileştirmeleri

## Problem

Güzellik uygulamasının arama özelliğinde kullanıcı deneyimini olumsuz etkileyen önemli eksiklikler bulunmaktadır:

1. **Popüler Aramalar Eksikliği**: Kullanıcılar arama ekranına geldiklerinde ne arayacaklarını bilmiyorlarsa, sistemde hangi hizmetlerin popüler olduğunu göremiyorlar. Bu durum özellikle yeni kullanıcılar için keşif sürecini zorlaştırıyor.

2. **Sesli Arama Desteği Yok**: Modern mobil uygulamalarda standart olan sesli arama özelliği mevcut değil. Kullanıcılar özellikle hareket halindeyken veya hızlı arama yapmak istediklerinde klavye kullanmak zorunda kalıyorlar.

3. **Arama Başlangıç Deneyimi Zayıf**: Arama ekranının başlangıç görünümü sadece kategorileri gösteriyor, ancak kullanıcılara trend olan veya popüler hizmetler hakkında bilgi vermiyor.

Bu eksiklikler kullanıcıların:
- Arama sürecini uzatıyor
- Keşif deneyimini kısıtlıyor
- Uygulamayı daha az kullanışlı hale getiriyor
- Rakip uygulamalara göre dezavantajlı konuma düşürüyor

## Why

Bu değişikliği şimdi yapmalıyız çünkü:

1. **Kullanıcı Geri Bildirimleri**: Kullanıcılar arama ekranında ne arayacaklarını bilmediklerinde kaybolduklarını belirtiyor. Popüler aramalar bu sorunu çözecek ve keşif deneyimini iyileştirecek.

2. **Rekabet Avantajı**: Rakip güzellik uygulamalarının çoğunda sesli arama ve popüler öneriler mevcut. Bu özellikleri eklemek bizi rekabetçi konuma getirecek.

3. **Mobil Kullanım Trendi**: Kullanıcıların %60'ı mobil cihazlarda hareket halindeyken arama yapıyor. Sesli arama bu kullanıcılar için büyük kolaylık sağlayacak.

4. **Mevcut Altyapı Hazır**: `venue_services` tablosu ve arama altyapısı zaten mevcut. Bu değişiklik mevcut sistemi genişletiyor, yeniden yazmıyor. Implementasyon riski düşük.

5. **Hızlı Değer Katma**: Her iki özellik de bağımsız olarak geliştirilebilir ve deploy edilebilir. Kullanıcılara hızlı bir şekilde değer katmaya başlayabiliriz.

6. **Veri Mevcudiyeti**: Sistemde yeterli `venue_services` verisi var. Popüler aramaları hesaplamak için gerekli veri zaten mevcut.

## Solution

### 1. Popüler Aramalar Önerisi

**Veri Kaynağı**: `venue_services` tablosundaki benzersiz hizmetlerden en çok kullanılan hizmetleri belirleyeceğiz. Bir hizmetin popülerliği, kaç farklı işletmenin o hizmeti sunduğuna göre hesaplanacak.

**Görsel Tasarım**: 
- Arama ekranının başlangıç görünümünde kategorilerin altında "Popüler Aramalar" bölümü
- 6-7 adet popüler hizmet chip/tag formatında gösterilecek
- Her chip tıklanabilir ve ilgili hizmet için arama başlatacak
- Modern, renkli ve etkileşimli tasarım

**Backend Yaklaşımı**:
- Mevcut `popular_services` view'ını kullanacağız (zaten `venue_count` ile sıralıyor)
- RPC fonksiyonu ile en popüler 6-7 hizmeti çekeceğiz
- Cache mekanizması ile performans optimize edilecek

### 2. Sesli Arama Özelliği

**Teknoloji**: `speech_to_text` Flutter paketi kullanılacak
- Cihazın native STT motorunu kullanır (iOS/Android)
- Offline çalışabilir
- Türkçe dil desteği mevcut
- Ücretsiz

**UI/UX Tasarımı**:
- Arama çubuğunun sağ tarafında mikrofon ikonu
- Mikrofona tıklandığında dinleme animasyonu
- Konuşma metne dönüştürüldükçe arama input'unda gösterilecek
- Hata durumları için kullanıcı dostu mesajlar

**İzinler**:
- Android: `RECORD_AUDIO` izni
- iOS: `NSMicrophoneUsageDescription` izni
- Runtime permission handling

## Scope

### Dahil Olanlar

✅ **Popüler Aramalar**:
- Backend: Popüler hizmetleri getiren RPC fonksiyonu
- Frontend: Popüler aramalar widget'ı
- UI: Premium tasarım ile chip/tag gösterimi
- Etkileşim: Chip'e tıklandığında arama başlatma
- Cache: Popüler aramaları cache'leme

✅ **Sesli Arama**:
- `speech_to_text` paketi entegrasyonu
- Mikrofon butonu ve animasyonlar
- İzin yönetimi (Android/iOS)
- Hata yönetimi ve kullanıcı geri bildirimleri
- Türkçe dil desteği
- Sesli arama sırasında görsel feedback

✅ **UI İyileştirmeleri**:
- Arama başlangıç ekranı yeniden tasarımı
- Popüler aramalar bölümü eklenmesi
- Mikrofon butonu ve animasyonlar
- Loading states ve error states

### Dahil Olmayanlar

❌ Arama geçmişi gösterimi (farklı bir değişiklik olarak ele alınacak)
❌ Gelişmiş filtreler (fiyat aralığı, mesafe, açık/kapalı)
❌ Boş durum (empty state) tasarımları iyileştirmesi
❌ Sesli arama için cloud-based STT servisleri (Google Cloud, Gemini AI)
❌ Popüler aramaları manuel olarak yönetme (admin panel)
❌ Arama analitiği ve kullanıcı davranışı tracking

### Bağımlılıklar

- Mevcut `venue_services` tablosu ve `popular_services` view
- Mevcut `SearchProvider` ve arama altyapısı
- `speech_to_text` paketi (pubspec.yaml'a eklenecek)
- Android/iOS izin yapılandırmaları

## Success Criteria

- [x] Popüler aramalar arama ekranında görüntüleniyor
- [x] Popüler aramalara tıklandığında ilgili hizmet araması başlatılıyor
- [x] Popüler aramalar en az 6-7 adet gösteriliyor
- [x] Mikrofon butonu arama çubuğunda görünüyor
- [x] Sesli arama başlatıldığında izin kontrolü yapılıyor
- [x] Konuşma metne dönüştürülüyor ve arama input'unda gösteriliyor
- [x] Sesli arama Türkçe dilini destekliyor
- [x] Hata durumları kullanıcıya net bir şekilde bildiriliyor
- [x] Tüm animasyonlar ve geçişler akıcı çalışıyor
- [x] iOS ve Android'de test edildi ve çalışıyor

## Risks

### Risk 1: Sesli Arama İzin Reddi
**Açıklama**: Kullanıcı mikrofon iznini reddederse sesli arama çalışmayacak.

**Mitigasyon**: 
- İlk kullanımda açıklayıcı dialog göster
- İzin reddedilirse kullanıcıyı ayarlara yönlendir
- Mikrofon butonunu disable et ve tooltip göster

### Risk 2: Popüler Hizmet Verisi Yetersiz
**Açıklama**: Yeni kurulan sistemlerde henüz yeterli `venue_services` verisi olmayabilir.

**Mitigasyon**:
- Minimum 3 hizmet varsa göster, yoksa bölümü gizle
- Fallback olarak manuel seçilmiş hizmetler listesi
- Seed data ile test ortamında veri sağla

### Risk 3: STT Doğruluğu
**Açıklama**: Cihazın native STT motoru Türkçe'de yeterince doğru olmayabilir.

**Mitigasyon**:
- Kullanıcı metni düzenleyebilir
- "Tekrar dene" butonu ekle
- İleride cloud-based STT'ye geçiş için altyapı hazır olsun

### Risk 4: Performans
**Açıklama**: Popüler aramaları her seferinde veritabanından çekmek performans sorununa yol açabilir.

**Mitigasyon**:
- Popüler aramaları cache'le (5 dakika TTL)
- Lazy loading uygula
- Pagination kullan (ilk 7 hizmet)

## Implementation Notes

### Faz 1: Popüler Aramalar (Öncelik: Yüksek)
1. Backend RPC fonksiyonu
2. Flutter model ve repository
3. SearchProvider'a popüler aramalar ekleme
4. UI widget'ı oluşturma
5. Test ve validasyon

### Faz 2: Sesli Arama (Öncelik: Orta)
1. Paket entegrasyonu ve izin yapılandırması
2. Sesli arama servisi oluşturma
3. UI butonu ve animasyonlar
4. SearchProvider entegrasyonu
5. Test ve validasyon

### Teknik Notlar

- Popüler aramalar için `SharedPreferences` ile cache
- Sesli arama için `permission_handler` paketi kullanılacak
- Tüm string'ler Turkish localization dosyasına eklenecek
- Widget testleri yazılacak
- Platform-specific kod için conditional imports
