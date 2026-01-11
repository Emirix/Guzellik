# Proposal: İşletme Temel Bilgileri Yönetimi

## Overview

İşletme sahiplerinin mobil yönetim panelinden işletmelerinin temel bilgilerini (isim, açıklama, adres, telefon, sosyal medya linkleri, çalışma saatleri vb.) düzenleyebilmesi için yeni bir yönetim ekranı eklenmesi.

## Why

Şu anda işletme sahipleri:
- İşletme temel bilgilerini güncellemek için web admin paneline geçmek zorunda
- Mobil uygulamadan işletme bilgilerini görüntüleyebiliyor ancak düzenleyemiyor
- İsim, açıklama, adres, telefon gibi kritik bilgileri hızlıca güncelleyemiyor

Bu değişiklik şu nedenlerle önemli:
- **Erişilebilirlik**: İşletme sahipleri bilgilerini her yerden, mobil cihazlarından güncelleyebilir
- **Kullanıcı Deneyimi**: Tüm yönetim işlemleri tek bir mobil uygulamada birleşir
- **Veri Güncelliği**: İşletmeler bilgilerini güncel tutmaya teşvik edilir
- **Platform Benimsenmesi**: Sürtünmeyi azaltarak işletme kullanıcı memnuniyetini artırır

## Problem Statement

Mevcut `add-mobile-business-admin` değişikliği ile işletme sahipleri:
- ✅ Hizmetleri yönetebiliyor
- ✅ Galeriyi yönetebiliyor  
- ✅ Uzmanları yönetebiliyor
- ✅ Kampanyaları yönetebiliyor

Ancak **temel işletme bilgilerini** (name, description, address, phone, social_links, working_hours) düzenleyemiyorlar.

Yönetim ana ekranında (yonetim-index.html tasarımında görüldüğü gibi) "Temel Bilgiler" menü öğesi mevcut ancak henüz uygulanmamış durumda.

## Proposed Solution

Mobil yönetim paneline "Temel Bilgiler" yönetim ekranı eklenecek:

### 1. **Temel Bilgiler Ekranı** (`admin-basic-info`)

Düzenlenebilir alanlar:
- **İşletme Adı** (name) - Text input
- **Tanıtım Yazısı** (description) - Multiline text input
- **Adres** (address) - Text input with optional location picker
- **Telefon** (phone) - Phone number input
- **E-posta** (email) - Email input
- **Sosyal Medya Linkleri** (social_links):
  - Instagram URL
  - WhatsApp numarası
  - Facebook URL (opsiyonel)
  - Website URL (opsiyonel)

### 2. **Çalışma Saatleri Ekranı** (`admin-working-hours`)

- Günlük çalışma saatleri yönetimi
- Her gün için:
  - Açık/Kapalı toggle
  - Açılış saati (time picker)
  - Kapanış saati (time picker)
  - Ara verme saatleri (opsiyonel)
- Resmi tatil bilgisi

### 3. **Konum Yönetimi** (`admin-location`)

- Harita üzerinde konum seçimi (latitude, longitude)
- Adres otomatik tamamlama (Google Places API)
- İl/İlçe seçimi (province_id, district_id)
- Manuel koordinat girişi

### Navigation Structure

Yönetim ana ekranından erişim:
```
/business/admin (Ana yönetim ekranı)
  ├── /business/admin/basic-info (Temel Bilgiler) ← YENİ
  │   ├── /business/admin/basic-info/working-hours (Çalışma Saatleri) ← YENİ
  │   └── /business/admin/basic-info/location (Konum) ← YENİ
  ├── /business/admin/services (Hizmet Yönetimi)
  ├── /business/admin/gallery (Galeri Yönetimi)
  ├── /business/admin/specialists (Uzman Yönetimi)
  └── /business/admin/campaigns (Kampanya Yönetimi)
```

### Design Principles

- Mevcut yönetim paneli tasarımı ile tutarlılık (yonetim-index.html referans)
- Form validasyonu ve hata mesajları
- Değişiklikleri kaydetmeden önce onay
- Optimistic UI updates
- Gerçek zamanlı senkronizasyon

## What Changes

- **Temel Bilgiler Ekranı**: İşletme adı, açıklama, telefon, e-posta ve sosyal medya linklerini düzenleme
- **Çalışma Saatleri Ekranı**: Haftalık çalışma saatlerini yönetme
- **Konum Ekranı**: Harita ile konum seçimi ve adres güncelleme
- **Yeni Provider'lar**: AdminBasicInfoProvider, AdminWorkingHoursProvider, AdminLocationProvider
- **Database RPC**: Konum güncelleme fonksiyonu
- **Yönetim Menüsü**: "Temel Bilgiler" menü kartı ekleme

## Impact

### Affected Specs
- `business-management` (YENİ): İşletme temel bilgileri yönetimi gereksinimleri

### Affected Code
- `lib/presentation/screens/business/admin_dashboard_screen.dart`: "Temel Bilgiler" menü kartı
- `lib/presentation/screens/business/admin_basic_info_screen.dart`: YENİ
- `lib/presentation/screens/business/admin_working_hours_screen.dart`: YENİ
- `lib/presentation/screens/business/admin_location_screen.dart`: YENİ
- `lib/presentation/providers/admin_basic_info_provider.dart`: YENİ
- `lib/presentation/providers/admin_working_hours_provider.dart`: YENİ
- `lib/presentation/providers/admin_location_provider.dart`: YENİ
- `lib/main.dart`: Provider'ları MultiProvider'a ekleme
- `lib/config/routes.dart`: Yeni route'lar

### Database
- `supabase/migrations/`: Konum güncelleme RPC fonksiyonu
- `venues` tablosu: Mevcut alanlar kullanılacak (phone, email eklenmesi gerekebilir)

## Success Criteria

- [ ] İşletme sahipleri temel bilgilerini mobil uygulamadan düzenleyebilir
- [ ] Çalışma saatleri ekranı kullanıcı dostu ve sezgisel
- [ ] Konum seçimi harita ile kolayca yapılabilir
- [ ] Sosyal medya linkleri doğru formatta kaydedilir
- [ ] Değişiklikler anında venue_details ekranında görünür
- [ ] Form validasyonu çalışır (telefon, email, URL formatları)
- [ ] RLS politikaları sadece işletme sahibinin düzenleme yapmasına izin verir
- [ ] UI tasarımı mevcut admin panel tasarımı ile uyumlu

## Dependencies

### Existing Database Tables
- `venues` - Tüm temel bilgiler bu tabloda
  - name, description, address
  - latitude, longitude
  - working_hours (JSONB)
  - social_links (JSONB)
  - phone, email
  - province_id, district_id

### Existing Providers/Services
- `BusinessProvider` - İşletme modu durumu
- `VenueDetailsProvider` - Venue verisi
- Supabase client

### Flutter Packages
- Mevcut: `supabase_flutter`, `provider`, `go_router`
- Gerekebilir: 
  - `google_maps_flutter` - Konum seçimi için
  - `url_launcher` - Sosyal medya link önizleme için
  - `intl_phone_field` - Telefon numarası girişi için

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Geçersiz veri girişi | Kapsamlı form validasyonu ve hata mesajları |
| RLS politika ihlalleri | Sadece owner_id kontrolü ile güvenli güncellemeler |
| Konum seçimi karmaşıklığı | Basit harita arayüzü ve adres otomatik tamamlama |
| Çalışma saatleri karmaşık yapısı | Kullanıcı dostu UI ile JSONB yapısını soyutlama |
| Sosyal medya link formatları | URL validasyonu ve format örnekleri |

## Out of Scope

- İşletme kategorisi değişikliği (category_id) - Onay gerektirir
- Logo/kapak fotoğrafı değişikliği - Galeri yönetiminde
- Ödeme seçenekleri yönetimi - Gelecek iterasyon
- Erişilebilirlik bilgileri - Gelecek iterasyon
- Sertifikalar yönetimi - Gelecek iterasyon
- FAQ yönetimi - Gelecek iterasyon
- Çoklu işletme yönetimi UI
- İşletme silme/deaktive etme

## Related Changes

- Extends: `add-mobile-business-admin` - Mevcut admin panel yapısına eklenir
- Complements: `refine-venue-details-design` - Güncellenmiş bilgiler venue details'da görünür
- May inform: Gelecekteki işletme onboarding iyileştirmeleri
