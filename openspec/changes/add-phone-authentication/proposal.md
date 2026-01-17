# Proposal: Add Phone Number Authentication

## Overview
Bu değişiklik ile uygulamaya telefon numarası ile kayıt olma ve giriş yapma özelliği eklenecektir. Kullanıcılar `90xxxxxxxxxx` formatında telefon numarası ve şifre belirleyerek hesap oluşturabileceklerdir. Herhangi bir onay kodu (OTP) gerekmeyecektir.

## Motivation
Kullanıcıların e-posta adresi yerine daha yaygın kullanılan telefon numarası ile hızlıca kayıt olmalarını ve giriş yapmalarını sağlamak.

## Goals
- Kayıt ekranına (`RegisterScreen`) telefon numarası ile kayıt sekmesi/seçeneği eklemek.
- Giriş ekranına (`LoginScreen`) telefon numarası ile giriş seçeneği eklemek.
- Telefon numarası formatını `90xxxxxxxxxx` (12 hane) olarak doğrulamak.
- Supabase Auth üzerinde telefon numarası ve şifre ile kullanıcı oluşturmak.
- Herhangi bir doğrulama kodu (SMS OTP) olmadan doğrudan erişim sağlamak.
- Mevcut email/google sistemleri ile uyumlu çalışmak.

## Non-Goals
- SMS ile doğrulama kodu (OTP) gönderimi.
- Telefon numarası sahipliği kanıtı (bu aşamada istenmiyor).
- Eski hesapların telefon numarası ile birleştirilmesi (otomatik değilse).

## Proposed Solution

### 1. UI Changes
- **Login Screen**: "E-posta veya Telefon Numarası" alanı halihazırda mevcut. Bu alan hem email hem de `90xxxxxxxxxx` formatındaki telefon numarasını kabul edecek şekilde geliştirilecek.
- **Register Screen**: Kayıt formuna "Telefon Numarası" alanı eklenecek veya Email/Telefon arasında seçim yapan bir tab yapısı kurulacak. Kullanıcının isteğine göre tasarımda en premium duran yöntem seçilecek.

### 2. Validation
- Telefon numarası için `RegExp(r'^90\d{10}$')` kullanılacak.
- Toplam 12 karakter zorunluluğu olacak.

### 3. Backend (Supabase)
- Supabase Auth `signUp` metodunda `phone` parametresi kullanılacak.
- `phone_confirm: false` (veya ilgili admin ayarı) ile OTP gereksinimi bypass edilecek. (Not: Supabase'de telefon ile kayıtta normalde OTP istenir, ancak kullanıcı "Herhangi bir onay koduna gerek yok" dediği için şifreli telefon kaydı veya meta-data üzerinden yönetim değerlendirilecek).
- *Önemli*: Supabase'de şifre + telefon ile kayıt (OTP'siz) için `admin` yetkileri veya şifreli telefon girişi desteği kontrol edilecek. Eğer Supabase doğrudan desteklemiyorsa, telefon numarası `[phone]@phone.internal` gibi sanal bir email formatına dönüştürülerek email sistemi üzerinden de simüle edilebilir, ancak en temizi telefon auth desteğidir.

### 4. Code Architecture
- `AuthService`: `signInWithPhone` ve `signUpWithPhone` metodları eklenecek.
- `AuthProvider`: Telefon auth metodlarını UI'a açacak.

## Timeline
- Spec & Design: 1 gün
- Backend/Service Layer: 1 gün
- UI Implementation: 1 gün
- Testing: 1 gün
- **Total**: ~4 gün
