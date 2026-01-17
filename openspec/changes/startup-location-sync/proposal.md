# Change: Startup Location Synchronization

## Why
Uygulama her açıldığında kullanıcının en güncel konum bilgisine sahip olunması, daha doğru mesafe hesaplamaları ve kişiselleştirilmiş bir deneyim sunmak için kritik öneme sahiptir. Mevcut yapıda konum bilgisi sadece bir kez onboarding aşamasında alınmakta, cihaz konumu kapalıysa kullanıcıya tekrar hatırlatılmamaktadır.

## What Changes
- Uygulama başlangıcında otomatik konum kontrolü mekanizması eklenecek.
- Cihaz konumu (GPS) açıksa, konum otomatik olarak güncellenecek ve kaydedilecek.
- Cihaz konumu kapalıysa, kullanıcıya konumu açmasını öneren bir Bottom Sheet gösterilecek.
- Kullanıcı konumu açmayı reddederse, profilindeki varsayılan il/ilçe bilgisinin **enlem ve boylam koordinatları** alınarak (mesafelerin doğru hesaplanması için) konum olarak ayarlanacak.
- Profilinde konum bilgisi yoksa veya login değilse, mevcut manuel seçim süreci devam edecek.

## Impact
- Affected specs: `discovery`
- Affected code:
  - `lib/presentation/providers/location_onboarding_provider.dart`
  - `lib/presentation/screens/location_onboarding_screen.dart`
  - `lib/presentation/widgets/discovery/location_service_request_bottom_sheet.dart` (New)
