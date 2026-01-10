## Context

Kampanya sayfası, kullanıcıların işletmelerin sunduğu indirimleri ve özel teklifleri keşfetmesini sağlayan yeni bir özellik. Bu değişiklik, quote request sisteminin kaldırılması ve FAB'ın yeniden amaçlandırılması ile birlikte geliyor.

### Constraints
- Sadece kullanıcı tarafı (customer-facing) özellikleri implement edilecek
- İşletme tarafından kampanya yönetimi (CRUD) gelecek bir değişiklikte ele alınacak
- Mevcut venue detail sayfası ile entegrasyon gerekli
- Supabase RLS policies ile güvenlik sağlanmalı

### Stakeholders
- **Kullanıcılar**: Kampanyaları görüntüleyecek, filtreleyecek
- **İşletmeler**: Kampanyalarını kullanıcılara sunacak (gelecek iterasyonda yönetecek)

## Goals / Non-Goals

### Goals
- Kullanıcıların tüm aktif kampanyaları görüntüleyebilmesi
- İndirim oranı ve tarihe göre sıralama
- Kampanya detaylarını bottom sheet'te görüntüleme
- Kampanyadan işletme sayfasına kolay geçiş
- Performanslı ve responsive UI

### Non-Goals
- İşletme tarafından kampanya oluşturma/düzenleme (gelecek değişiklik)
- Kampanya bildirimleri (gelecek değişiklik)
- Kampanya favorileme (gelecek değişiklik)
- Kampanya paylaşma (gelecek değişiklik)
- Kullanıcı bazlı kampanya önerileri (gelecek değişiklik)

## Decisions

### Database Schema

**Decision**: `campaigns` tablosu ayrı bir tablo olarak oluşturulacak, `venues` tablosu ile foreign key ilişkisi kurulacak.

**Rationale**:
- Kampanyalar venue'lardan bağımsız lifecycle'a sahip (başlangıç/bitiş tarihleri)
- Bir venue'nun birden fazla kampanyası olabilir
- Kampanya-specific alanlar (discount_percentage, discount_amount) venue tablosunu şişirmez
- Gelecekte kampanya analytics için ayrı tablo daha uygun

**Alternatives Considered**:
- JSONB field in venues table → Rejected: Query ve filtreleme zorlaşır
- Separate promotions service → Rejected: Over-engineering, tek bir tablo yeterli

### Discount Representation

**Decision**: Hem `discount_percentage` hem `discount_amount` alanları olacak, ikisi de nullable. En az biri dolu olmalı.

**Rationale**:
- Bazı kampanyalar % indirim (örn: %20 indirim)
- Bazı kampanyalar sabit tutar (örn: 50₺ indirim)
- Her ikisini de desteklemek esneklik sağlar

**Validation**: Application layer'da en az birinin dolu olduğu kontrol edilecek.

### Image Storage

**Decision**: `image_url` opsiyonel olacak, yoksa fallback icon gösterilecek.

**Rationale**:
- Tüm işletmelerin kampanya görseli olmayabilir
- Fallback UI daha iyi UX sağlar
- Gelecekte image upload özelliği eklenebilir

### Sorting Options

**Decision**: İki ana sıralama: (1) İndirim oranına göre, (2) Tarihe göre (yeniden eskiye)

**Rationale**:
- Kullanıcılar en yüksek indirimleri görmek ister
- Yeni kampanyalar daha ilgi çekici
- Basit ve anlaşılır seçenekler

**Future Enhancement**: "Yakında sona erecekler" badge'i ile urgency yaratılacak.

## Data Model

```sql
CREATE TABLE campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  discount_percentage INTEGER CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
  discount_amount DECIMAL(10, 2) CHECK (discount_amount >= 0),
  start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_date TIMESTAMPTZ NOT NULL,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- At least one discount type must be present
  CONSTRAINT check_discount CHECK (
    discount_percentage IS NOT NULL OR discount_amount IS NOT NULL
  ),
  
  -- End date must be after start date
  CONSTRAINT check_dates CHECK (end_date > start_date)
);

CREATE INDEX idx_campaigns_venue_id ON campaigns(venue_id);
CREATE INDEX idx_campaigns_is_active ON campaigns(is_active);
CREATE INDEX idx_campaigns_dates ON campaigns(start_date, end_date);
```

## UI/UX Flow

1. **Entry Point**: User taps FAB on home screen
2. **Campaigns Screen**: 
   - Shows list of active campaigns
   - Sort button in AppBar
   - Pull-to-refresh
3. **Campaign Card Tap**: Opens bottom sheet with details
4. **Bottom Sheet**:
   - Full campaign details
   - "İşletmeye Git" button → navigates to venue detail
5. **Venue Detail Integration**:
   - Shows venue's active campaigns in a section
   - Tapping campaign opens same bottom sheet

## Risks / Trade-offs

### Risk: Empty State
**Mitigation**: Seed database with sample campaigns for testing. Add clear empty state message.

### Risk: Expired Campaigns
**Mitigation**: RLS policy filters `is_active = true AND end_date > NOW()`. Background job (future) to auto-deactivate.

### Trade-off: No Pagination
**Decision**: Start without pagination, add if needed.
**Rationale**: Kampanya sayısı başlangıçta az olacak. Performance sorun olursa pagination eklenecek.

## Migration Plan

### Phase 1: Database
1. Create migration file
2. Test migration on development
3. Apply to production

### Phase 2: Backend (Supabase)
1. RLS policies
2. Test queries

### Phase 3: Frontend
1. Models and repositories
2. Provider
3. UI components
4. Screen
5. Navigation updates

### Phase 4: Cleanup
1. Remove quote request code
2. Update FAB
3. Test end-to-end

### Rollback Plan
- Migration can be rolled back with `DROP TABLE campaigns CASCADE`
- FAB can be reverted to previous behavior
- Quote request code is in git history

## Open Questions

- **Q**: Kampanya görseli için boyut/format kısıtlaması var mı?
  - **A**: Şimdilik yok, gelecekte image upload eklendiğinde belirlenecek.

- **Q**: Bir venue'nun aynı anda kaç kampanyası olabilir?
  - **A**: Limit yok, ancak UI'da en fazla 3-5 gösterilecek.

- **Q**: Süresi dolmuş kampanyalar silinecek mi?
  - **A**: Hayır, `is_active = false` yapılacak. Analytics için saklanacak.
