# Tasks: Add Phone Number Authentication

- [x] **Infrastructure & Services**
    - [x] `AuthService`'e `signUpWithPhone` metodu ekle (Email mapping mantığıyla) <!-- id: 1 -->
    - [x] `AuthService`'e `signInWithPhone` metodu ekle <!-- id: 2 -->
    - [x] `AuthProvider`'da yeni metodları UI'a aç <!-- id: 3 -->
    - [x] Telefon formatı için `Validator` util metodu ekle (`90xxxxxxxxx` kontrolü) <!-- id: 4 -->

- [x] **UI Implementation - Registration**
    - [x] `RegisterScreen`'e Telefon/Email seçim tabı veya toggle ekle <!-- id: 5 -->
    - [x] Telefon numarası input alanını ekle (InputMask veya basit regex validation ile) <!-- id: 6 -->
    - [x] Kayıt mantığını telefon seçimini destekleyecek şekilde güncelle <!-- id: 7 -->

- [x] **UI Implementation - Login**
    - [x] `LoginScreen` giriş alanına telefon numarası algılama mantığı ekle <!-- id: 8 -->
    - [x] Giriş butonunu hem e-posta hem telefon desteğiyle güncelle <!-- id: 9 -->

- [x] **Validation & Testing**
    - [x] Telefon numarası format testi (12 hane, 90 ile başlama) <!-- id: 10 -->
    - [x] OTP'siz girişin başarıyla tamamlandığını doğrula <!-- id: 11 -->
    - [x] Mevcut e-posta ve Google girişlerinin bozulmadığını kontrol et <!-- id: 12 -->
