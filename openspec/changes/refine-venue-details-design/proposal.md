# Change: Mekan Detay Sayfası Tasarım İyileştirmesi

## Why
Mevcut mekan detay sayfası temel işlevselliğe sahip ancak design klasöründeki premium tasarımlara göre görsel olarak yetersiz kalmaktadır. Kullanıcı deneyimini artırmak ve marka kimliğini güçlendirmek için tasarımın şu eksiklikleri giderilmelidir:

- Hero image üzerinde hızlı aksiyon butonları yok (WhatsApp, Telefon, Harita, Paylaş)
- Mekan hikayesi/açıklama bölümü eksik veya yetersiz
- Uzman listesi görsel olarak çekici değil
- Çalışma saatleri ve konum bilgisi tasarıma uygun şekilde gösterilmiyor
- Hizmet kartları before/after fotoğrafları ve premium görünüm içermiyor
- "Randevu Oluştur" butonu sabit alt bar olarak konumlandırılmamış
- Renk paleti ve tipografi design dosyalarındaki nude/soft pink/gold temasına uygun değil

## What Changes

### UI/UX İyileştirmeleri:
- **VenueHero Widget**: Hızlı aksiyon butonları ekleniyor (WhatsApp, Telefon, Harita, Paylaş)
- **AboutTab**: Mekan hikayesi bölümü zenginleştiriliyor, çalışma saatleri ve ödeme bilgileri ekleniyor
- **ExpertsTab**: Uzman kartları premium tasarıma göre yeniden düzenleniyor
- **ServicesTab**: Hizmet kartları before/after fotoğrafları ile güncelleniyor
- **Booking Button**: Sabit alt bar olarak "Randevu Oluştur" butonu ekleniyor
- **Color Scheme**: Tüm bileşenler design paletine göre güncelleniyor (nude, soft pink, gold)
- **Typography**: Google Fonts (Inter/Outfit) entegrasyonu

### Yeni Bileşenler:
- `QuickActionButton`: Hero image üzerindeki aksiyon butonları için
- `WorkingHoursCard`: Çalışma saatleri gösterimi için
- `ServiceCard`: Before/after fotoğraflı hizmet kartları için
- `ExpertCard`: Premium uzman kartları için
- `BookingBottomBar`: Sabit randevu butonu için

## Impact
- Affected specs: `venue-details` (MODIFIED requirements - UI/UX improvements)
- Affected code:
  - `lib/presentation/widgets/venue/venue_hero.dart` (quick action buttons)
  - `lib/presentation/widgets/venue/tabs/about_tab.dart` (story, hours, payment)
  - `lib/presentation/widgets/venue/tabs/experts_tab.dart` (premium cards)
  - `lib/presentation/widgets/venue/tabs/services_tab.dart` (before/after photos)
  - `lib/presentation/screens/venue/venue_details_screen.dart` (booking bottom bar)
  - `lib/core/theme/app_colors.dart` (design palette alignment)
  - `lib/core/theme/app_text_styles.dart` (typography updates)
  - New files under `lib/presentation/widgets/venue/components/`

## Dependencies
- Google Fonts package (zaten mevcut)
- url_launcher package (WhatsApp, telefon, harita linkleri için)
- share_plus package (paylaşım özelliği için)
