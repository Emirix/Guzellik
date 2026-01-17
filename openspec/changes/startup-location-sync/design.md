# Design: Startup Location Synchronization

## Context
Kullanıcıların uygulama açılışında konumlarının güncel olduğundan emin olmak istiyoruz. Bu, hem GPS üzerinden otomatik olarak hem de profil bilgileri üzerinden akıllı bir varsayılan atama ile yapılmalıdır.

## Goals
- Uygulama her açıldığında konum kontrolü yapmak.
- GPS açıksa sessizce konumu güncellemek.
- GPS kapalıysa kullanıcıya sormak.
- Alternatif olarak profil şehrini kullanmak.

## Decisions

### 1. Onboarding Provider Güncellemesi
`LocationOnboardingProvider` sınıfına `checkStartupLocation` metodu eklenecek. Bu metod:
1. `LocationService.isLocationServiceEnabled()` ile GPS durumunu kontrol eder.
2. GPS açıksa `requestGPSLocation()` ile konumu günceller.
3. GPS kapalıysa `OnboardingState.showingServiceRequest` (yeni state) durumuna geçer.

### 2. Profil Konumu Entegrasyonu
Eğer kullanıcı GPS'i açmazsa, `AuthProvider` üzerinden profil bilgileri çekilecek:
- `profile.provinceId` ve `profile.districtId` kullanılarak `LocationRepository` üzerinden konum nesnesi oluşturulacak.
- **Kritik**: Mesafelerin düzgün hesaplanabilmesi için ilgili ilçe/ilin enlem ve boylam bilgileri (database'den veya geocoding servisinden) alınarak `UserLocation` nesnesine eklenecek.
- Bu nesne `LocationPreferences`'a kaydedilecek ve `DiscoveryProvider`'a aktarılacak.

### 3. Kullanıcı Deneyimi (Bottom Sheet)
Yeni bir `LocationServiceRequestBottomSheet` oluşturulacak. Bu sheet:
- "Konum Servislerini Aç" butonu (Cihaz ayarlarına yönlendirir).
- "Profil Şehrimi Kullan" veya "Manuel Seç" butonu (Red durumunda).

## Risks / Trade-offs
- **Düşük İnternet / GPS Sinyali**: Zaman aşımı (timeout) süreleri iyi ayarlanmalıdır (GPS için 10 sn, geocoding için 5 sn).
- **Misafir Kullanıcılar**: Profil bilgisi olmadığı için varsayılan olarak manuel seçime veya İstanbul gibi bir merkeze yönlendirilecekler.

## Open Questions
- Uygulama her açıldığında mı yoksa sadece oturum başına bir kez mi kontrol edilmeli? (User: "Uygulamam ilk açıldığında" -> Her soğuk açılışta kontrol edilecek şekilde planlandı).
