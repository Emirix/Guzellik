# Teklif İsteme Özelliği (Quote Request Feature)

Kullanıcıların işletmelerden fiyat teklifi isteyebilmesini sağlayan özellik. Bu aşamada sadece kullanıcı tarafı (teklif oluşturma, listeleme, takip) uygulanacak.

## User Review Required

> [!IMPORTANT]
> Bu değişiklik navbar'a yeni bir floating action button ekliyor. Mevcut 4 tab (Keşfet, Ara, Bildirimler, Profil) ortasına merkezi bir "Teklif İste" butonu eklenecek.

> [!NOTE]
> İşletme paneli (teklif görme ve yanıtlama) bu scope'un dışındadır. Veritabanı yapısı sadece kullanıcı tarafı için hazırlanacak.

## Proposed Changes

### Navigation Component

#### [MODIFY] [custom_bottom_nav.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/widgets/common/custom_bottom_nav.dart)
- Ortaya floating action button eklenecek (teklif ikonu)
- FAB tıklandığında `QuoteRequestScreen`'e yönlendirme
- Premium tasarım: pembe/gold gradient ile göz alıcı buton

#### [MODIFY] [home_screen.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/screens/home_screen.dart)
- `floatingActionButton` ve `floatingActionButtonLocation` ekleme

---

### Database Layer

#### [NEW] `20260110100000_add_quote_requests.sql`
- `quote_requests` tablosu: Teklif isteklerinin ana tablosu
  - `id`, `user_id`, `preferred_date`, `preferred_time_slot`, `notes`, `status`, `expires_at`, `created_at`
  - Status: `active` (yayında), `closed` (kapandı)
- `quote_request_services` tablosu: İstenen hizmetler (çoklu)
  - `id`, `quote_request_id`, `service_category_id`
- `quote_responses` tablosu: İşletme yanıtları (ileride kullanılacak)
  - `id`, `quote_request_id`, `venue_id`, `price`, `message`, `created_at`
- RLS politikaları: Kullanıcılar sadece kendi tekliflerini görebilir

---

### Data Models

#### [NEW] [quote_request.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/data/models/quote_request.dart)
```dart
class QuoteRequest {
  final String id;
  final String userId;
  final DateTime preferredDate;
  final String? preferredTimeSlot; // sabah, öğle, akşam
  final String? notes;
  final QuoteStatus status; // active, closed
  final DateTime expiresAt;
  final DateTime createdAt;
  final List<ServiceCategory> services;
  final int responseCount; // Kaç işletme yanıt verdi
}
```

#### [NEW] [quote_response.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/data/models/quote_response.dart)
```dart
class QuoteResponse {
  final String id;
  final String quoteRequestId;
  final String venueId;
  final double price;
  final String? message;
  final DateTime createdAt;
  final Venue? venue; // Join ile doldurulacak
}
```

---

### Repository Layer

#### [NEW] [quote_repository.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/data/repositories/quote_repository.dart)
- `createQuoteRequest()`: Yeni teklif oluştur
- `getMyQuoteRequests()`: Kullanıcının tekliflerini listele
- `getQuoteRequestById()`: Detay getir
- `closeQuoteRequest()`: Teklifi kapat
- `getQuoteResponses()`: Teklife gelen yanıtları listele

---

### Provider Layer

#### [NEW] [quote_provider.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/providers/quote_provider.dart)
- Teklif oluşturma state yönetimi
- Teklif listesi state yönetimi
- Seçilen hizmetler, tarih, notlar
- Loading/error states

---

### Presentation Layer

#### [NEW] [quote_request_screen.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/screens/quote/quote_request_screen.dart)
- **Adım 1**: Hizmet seçimi (service_categories'den çoklu seçim)
- **Adım 2**: Tarih ve saat tercihi
- **Adım 3**: Ek notlar (opsiyonel)
- **Adım 4**: Özet ve gönder
- Premium stepper tasarımı

#### [NEW] [my_quotes_screen.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/screens/quote/my_quotes_screen.dart)
- Tekliflerim listesi
- Durum filtreleme (Aktif/Kapandı)
- Teklif kartları (hizmetler, tarih, yanıt sayısı)
- Profil sayfasından erişim

#### [NEW] [quote_detail_screen.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/screens/quote/quote_detail_screen.dart)
- Teklif detayları
- Gelen yanıtlar listesi (işletme adı, fiyat, mesaj)
- Teklifi kapatma butonu

---

### Widgets

#### [NEW] [service_selector_widget.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/widgets/quote/service_selector_widget.dart)
- Kategorilere göre gruplandırılmış hizmet seçici
- Çoklu seçim desteği
- Arama/filtreleme

#### [NEW] [quote_card.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/widgets/quote/quote_card.dart)
- Teklif özet kartı (liste görünümü için)
- Durum badge'i (Yayında/Kapandı)
- Seçilen hizmetler, tarih, yanıt sayısı

#### [NEW] [quote_response_card.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/widgets/quote/quote_response_card.dart)
- İşletme yanıt kartı
- İşletme bilgileri, fiyat, mesaj

---

### Profile Integration

#### [MODIFY] [profile_screen.dart](file:///c:/Users/Emir/Documents/Proje/Guzellik/lib/presentation/screens/profile_screen.dart)
- "Tekliflerim" menü öğesi ekleme
- `MyQuotesScreen`'e yönlendirme

## Verification Plan

### Automated Tests
- Teklif oluşturma flow testi (hizmet seç → tarih seç → not ekle → gönder)
- Teklif listeleme ve detay görüntüleme
- Teklif kapatma

### Manual Verification
- FAB tasarımının görselliği
- Hizmet seçici kullanıcı deneyimi
- Teklif kartları tasarımı
- Responsive davranış
