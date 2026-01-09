# Tasks: Teklif İsteme Özelliği

## Database & Backend
- [ ] Migration: `quote_requests`, `quote_request_services`, `quote_responses` tabloları
- [ ] RLS politikaları ve indexler
- [ ] Supabase function: `get_my_quotes`, `create_quote_request`

## Data Layer
- [ ] `QuoteRequest` model
- [ ] `QuoteResponse` model
- [ ] `QuoteRepository` - CRUD operasyonları

## Provider Layer
- [ ] `QuoteProvider` - state yönetimi
- [ ] Service kategori seçimi state
- [ ] Form validation

## UI - Teklif Oluşturma
- [ ] `QuoteRequestScreen` - ana sayfa
- [ ] Stepper tasarımı (4 adım)
- [ ] `ServiceSelectorWidget` - hizmet seçici
- [ ] Tarih/saat seçici
- [ ] Not alanı
- [ ] Özet ve onay ekranı

## UI - Teklif Listeleme
- [ ] `MyQuotesScreen` - tekliflerim listesi
- [ ] `QuoteCard` widget
- [ ] Durum filtreleme (Aktif/Kapandı)

## UI - Teklif Detay
- [ ] `QuoteDetailScreen` - detay sayfası
- [ ] `QuoteResponseCard` widget
- [ ] Teklifi kapatma işlevi

## Navigation
- [ ] Navbar'a floating action button ekleme
- [ ] FAB tasarımı (gradient, icon)
- [ ] Profil sayfasına "Tekliflerim" menüsü

## Auth & Validation
- [ ] Giriş zorunluluğu kontrolü
- [ ] Form validation
- [ ] Error handling

## Testing & Polish
- [ ] Teklif oluşturma flow testi
- [ ] UI polish ve animasyonlar
- [ ] Edge case handling
