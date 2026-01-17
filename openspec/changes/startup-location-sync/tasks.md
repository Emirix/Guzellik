## 1. Data & Service Updates
- [ ] 1.1 `LocationService`'de konumun açık olup olmadığını kontrol eden metodun doğrulanması
- [ ] 1.2 `LocationRepository`'ye profil üzerinden konum (ve koordinatlarını) getirme desteği eklenmesi
- [ ] 1.3 `Province` ve `District` modellerinin enlem/boylam bilgilerini tam olarak desteklediğinin doğrulanması (Gerekirse geocoding entegrasyonu)

## 2. Provider Logic Updates
- [ ] 2.1 `LocationOnboardingProvider`'da `OnboardingState.showingServiceRequest` state'inin eklenmesi
- [ ] 2.2 `LocationOnboardingProvider.checkLocationStatus` metodunun yeni akışa göre güncellenmesi
- [ ] 2.3 `useProfileLocation` metodunun implementasyonu (AuthProvider entegrasyonu ile)

## 3. UI Implementation
- [ ] 3.1 `LocationServiceRequestBottomSheet` widget'ının oluşturulması (Premium tasarım)
- [ ] 3.2 `LocationOnboardingScreen`'in yeni state'i dinleyecek ve bottom sheet'i tetikleyecek şekilde güncellenmesi
- [ ] 3.3 Konum ayarlarından dönüldüğünde otomatik yeniden kontrol mekanizmasının kurulması

## 4. Verification
- [ ] 4.1 GPS açıkken uygulama açılışı testi (Otomatik güncelleme)
- [ ] 4.2 GPS kapalıyken uygulama açılışı testi (Bottom sheet gösterimi)
- [ ] 4.3 Profil şehrine düşme (fallback) senaryosunun testi
