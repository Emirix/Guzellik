# Phone Authentication Design

## User Experience

### 1. Registration Flow
- Kullanıcı kayıt ekranına girdiğinde "E-posta" veya "Telefon" seçeneklerinden birini seçer.
- Telefon seçildiğinde:
    - Etiket: "Telefon Numarası"
    - Örnek/Hint: "905XXXXXXXXX"
    - İkon: `phone_outlined`
- Format kontrolü anlık (onChanged) veya form submit sırasında yapılır.
- Şifre ve Şifre Tekrar alanları doldurulur.
- "Kayıt Ol" tıklandığında hesap oluşturulur ve ana sayfaya yönlendirilir.

### 2. Login Flow
- Mevcut "E-posta veya Telefon Numarası" alanı:
    - Eğer giriş `90` ile başlıyorsa ve rakamlardan oluşuyorsa telefon numara girişi olarak algılanır.
    - Değilse email olarak işleme alınır.
- Şifre girilir ve "Giriş Yap" tıklanır.

## Architectural Reasoning

### Phone Authentication without OTP in Supabase
Supabase normalde telefon ile auth için OTP (SMS) zorunlu tutar. Ancak kullanıcının "onay koduna gerek yok" talebini karşılamak için iki teknik yaklaşım mevcuttur:

1. **Email Mapping (Recommended for no-OTP)**:
   - Telefon numarası kullanıcıdan alınır.
   - Arka planda `[phone]@phone.internal` gibi benzersiz bir email adresine dönüştürülür.
   - Supabase'in email/password sistemi kullanılır.
   - Bu yöntem OTP maliyetini ve karmaşıklığını %100 ortadan kaldırır.
   - Kullanıcı sadece telefon numarasını görür, email arka planda kalır.

2. **Metadata Approach**:
   - Kullanıcı yine email ile kayıt olur (rastgele bir email atanabilir).
   - Telefon numarası `user_metadata` içinde saklanır.
   - Giriş sırasında telefon numarasına karşılık gelen email bulunup giriş yapılır.

**Karar**: 1. Yöntem (Email Mapping) en stabil ve hızlı çözümdür. Kullanıcı deneyimi açısından `%100` telefon numarası gibi davranır.

## UI/UX Rules
- Tasarım `design/login.html` ve `design/profilim.php` ile tam uyumlu olacak.
- Nude ve Nude-Pink geçişleri kullanılacak.
- Premium buton tasarımı (`AppColors.primary`'den pembe tona gradient) korunacak.
