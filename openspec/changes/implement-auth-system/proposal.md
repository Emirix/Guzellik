# Proposal: Implement Authentication System

## Overview

Kullanıcı giriş ve kayıt işlemlerini içeren kapsamlı bir authentication sistemi oluşturulacak. Tasarım `design/login.html` dosyasından referans alınacak. Bazı sayfalar auth gerektirmeyecek (keşfet, harita, mekan detayları) ancak kişisel sayfalar (profilim, bildirimler, favoriler) için zorunlu auth kontrolü yapılacak.

## Motivation

Kullanıcıların uygulamada kişiselleştirilmiş deneyim yaşayabilmesi, favorilerini kaydedebilmesi, bildirim alabilmesi ve profil yönetimi yapabilmesi için güvenli bir authentication sistemi gereklidir.

## Goals

- Kullanıcı giriş ve kayıt ekranlarını `design/login.html` tasarımına uygun şekilde implement etmek
- Email/telefon ve şifre ile giriş yapabilme
- Email ile kayıt olabilme
- Şifremi unuttum fonksiyonalitesi
- Google, Apple ve Facebook ile sosyal giriş (opsiyonel, gelecek için hazırlık)
- Auth gerektiren sayfalara (profil, bildirimler, favoriler) erişim kontrolü
- Auth gerektirmeyen sayfalara serbest erişim (keşfet, harita, mekan detayları)
- Profil sayfasını `design/profilim.php` tasarımına göre yeniden tasarlamak
- Auth guard middleware ile route koruması

## Non-Goals

- Sosyal medya girişlerinin tam implementasyonu (sadece UI hazırlığı)
- Email doğrulama zorunluluğu (opsiyonel olacak)
- İki faktörlü kimlik doğrulama
- Biyometrik giriş (parmak izi, yüz tanıma)

## Proposed Solution

### 1. Authentication Flow

```
Unauthenticated User
  ↓
Splash Screen
  ↓
Home/Explore (Auth Required Değil)
  ↓
Profile/Favorites/Notifications'a Tıklama
  ↓
Auth Guard Kontrolü
  ↓
Auth Required Screen (Giriş Yap Butonu ile)
  ↓
Login Screen
  ↓
Authenticated → İstenen Sayfaya Yönlendirme
```

### 2. Screen Structure

#### Login Screen
- Email/Telefon input alanı
- Şifre input alanı (göster/gizle toggle)
- "Şifremi Unuttum?" linki
- "Giriş Yap" butonu
- Sosyal giriş butonları (Google, Apple, Facebook) - UI hazır, fonksiyon gelecekte
- "Hesabın yok mu? Kayıt Ol" linki

#### Register Screen
- Ad Soyad input alanı
- Email input alanı
- Telefon numarası input alanı (opsiyonel)
- Şifre input alanı
- Şifre tekrar input alanı
- "Kayıt Ol" butonu
- Sosyal kayıt butonları - UI hazır
- "Zaten hesabın var mı? Giriş Yap" linki

#### Auth Required Screen
- Bilgilendirme mesajı: "Bu sayfayı görüntülemek için giriş yapmanız gerekmektedir"
- "Giriş Yap" butonu
- Opsiyonel: "Kayıt Ol" butonu

#### Profile Screen (Yeniden Tasarım)
- Kullanıcı avatar'ı (düzenlenebilir)
- Kullanıcı adı ve email
- Üyelik rozeti (Gold Üye vb.)
- İstatistikler (Randevular, Favoriler, Puanlar)
- Menü öğeleri:
  - Randevularım
  - Favorilerim
  - Cüzdanım
  - Bildirim Ayarları
  - Genel Ayarlar
  - Yardım & Destek
- "Çıkış Yap" butonu

### 3. Route Protection

Auth gerektiren sayfalar:
- `/profile` - Profilim
- `/notifications` - Bildirimler
- `/favorites` - Favoriler

Auth gerektirmeyen sayfalar:
- `/` - Ana sayfa
- `/explore` - Keşfet
- `/search` - Arama
- `/venue/:id` - Mekan detayları

### 4. State Management

`AuthProvider` mevcut yapıyı kullanacak ve şu özellikleri sağlayacak:
- `isAuthenticated` - Kullanıcı giriş yapmış mı?
- `currentUser` - Mevcut kullanıcı bilgileri
- `signIn()` - Giriş yapma
- `signUp()` - Kayıt olma
- `signOut()` - Çıkış yapma
- `resetPassword()` - Şifre sıfırlama

### 5. Design Alignment

- `design/login.html` dosyasındaki tasarım Flutter widget'larına dönüştürülecek
- `design/profilim.php` dosyasındaki tasarım ProfileScreen için kullanılacak
- Renk paleti: Primary (#e23661), Gold (#C5A059), Nude (#E8DCD5)
- Font: Plus Jakarta Sans
- Border radius: Rounded (1rem default, full for buttons)

## Alternatives Considered

### Alternative 1: Tüm Sayfalar İçin Auth Zorunluluğu
**Rejected**: Kullanıcı deneyimini kısıtlar, uygulamayı keşfetmek isteyen kullanıcıları uzaklaştırabilir.

### Alternative 2: Auth Guard Yerine Manuel Kontroller
**Rejected**: Her sayfada manuel kontrol yapmak kod tekrarına ve hatalara yol açabilir.

## Open Questions

1. Email doğrulama zorunlu olacak mı? → Hayır, opsiyonel
2. Sosyal giriş ne zaman implement edilecek? → Gelecek versiyonlarda, şimdilik sadece UI hazır
3. Profil fotoğrafı yükleme nasıl olacak? → Supabase Storage kullanılacak
4. Şifre gereksinimleri neler? → Minimum 6 karakter

## Success Metrics

- Kullanıcılar başarıyla kayıt olabilmeli
- Kullanıcılar başarıyla giriş yapabilmeli
- Auth gerektiren sayfalara yetkisiz erişim engellenebilmeli
- Tasarım design dosyalarına %95+ uyumlu olmalı
- Tüm auth işlemleri 2 saniyeden kısa sürmeli

## Timeline

- Spec yazımı: 1 gün
- Login/Register ekranları: 2 gün
- Auth Guard implementasyonu: 1 gün
- Profile Screen yeniden tasarımı: 2 gün
- Test ve polish: 1 gün
- **Toplam**: ~7 gün
