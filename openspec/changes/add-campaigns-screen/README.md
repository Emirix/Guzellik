# Kampanya Sayfası - OpenSpec Proposal

## 📋 Özet

Bu proposal, kullanıcıların işletmelerin sunduğu kampanyaları görüntüleyebileceği yeni bir kampanya sayfası ekler. Floating Action Button (FAB) artık kampanya sayfasına yönlendirecek ve quote request özelliği kaldırılacak.

## 🎯 Hedefler

- ✅ Kullanıcıların aktif kampanyaları görüntülemesi
- ✅ İndirim oranı ve tarihe göre sıralama
- ✅ Kampanya detaylarını bottom sheet'te gösterme
- ✅ Kampanyadan işletme sayfasına kolay geçiş
- ✅ Performanslı ve responsive UI

## 📁 Oluşturulan Dosyalar

### OpenSpec Dosyaları
- `openspec/changes/add-campaigns-screen/proposal.md` - Değişiklik açıklaması
- `openspec/changes/add-campaigns-screen/tasks.md` - Implementation checklist (0/72 tasks)
- `openspec/changes/add-campaigns-screen/design.md` - Teknik tasarım kararları
- `openspec/changes/add-campaigns-screen/specs/campaigns/spec.md` - Kampanya capability spec
- `openspec/changes/add-campaigns-screen/specs/database/spec.md` - Database değişiklikleri
- `openspec/changes/add-campaigns-screen/specs/navigation/spec.md` - Navigation değişiklikleri

### Migration Dosyaları
- `supabase/migrations/20260110120000_create_campaigns_table.sql` - Campaigns tablosu
- `supabase/migrations/20260110120001_seed_campaigns.sql` - Test kampanyaları

## 🗄️ Database Schema

```sql
campaigns (
  id UUID PRIMARY KEY,
  venue_id UUID REFERENCES venues(id),
  title TEXT NOT NULL,
  description TEXT,
  discount_percentage INTEGER (0-100),
  discount_amount DECIMAL(10,2),
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
```

**Constraints:**
- En az biri dolu: `discount_percentage` VEYA `discount_amount`
- `end_date > start_date`
- Cascade delete on venue deletion

## 🎨 UI Components

### Yeni Ekranlar
- `CampaignsScreen` - Ana kampanya listesi sayfası

### Yeni Widget'lar
- `CampaignCard` - Kampanya kartı
- `CampaignDetailBottomSheet` - Kampanya detay görünümü
- `CampaignSortOptions` - Filtreleme/sıralama seçenekleri

## 🔄 Değişen Davranışlar

### FAB (Floating Action Button)
**Önce:** Quote request / My quotes sayfasına gidiyor
**Sonra:** Campaigns sayfasına gidiyor

### Kaldırılan Özellikler
- ❌ Quote request sistemi
- ❌ QuoteProvider
- ❌ Quote-related screens ve widget'lar

## 📊 Filtreleme ve Sıralama

1. **İndirim Oranına Göre** - En yüksek indirimler önce
2. **Tarihe Göre** - En yeni kampanyalar önce
3. **Yakında Sona Erecekler** - Son 3 gün badge'i

## 🚀 Implementation Aşamaları

### Phase 1: Database (Tasks 1.1-1.2)
- [x] Migration dosyası oluşturuldu
- [ ] Migration test edilecek
- [ ] Production'a deploy edilecek

### Phase 2: Data Layer (Tasks 2.1-2.2)
- [ ] Campaign model
- [ ] Campaign repository

### Phase 3: State Management (Tasks 3.1-3.2)
- [ ] Campaign provider
- [ ] Provider registration

### Phase 4: UI Components (Tasks 4.1-4.3)
- [ ] Campaign card
- [ ] Detail bottom sheet
- [ ] Filter/sort widget

### Phase 5: Campaigns Screen (Tasks 5.1-5.2)
- [ ] Screen implementation
- [ ] Routing

### Phase 6: Navigation Updates (Tasks 6.1-6.2)
- [ ] FAB güncelleme
- [ ] Quote code cleanup

### Phase 7: Integration (Tasks 7.1-7.2)
- [ ] Venue detail integration
- [ ] Test data

### Phase 8: Testing & Polish (Tasks 8.1-8.6)
- [ ] Responsive design
- [ ] Animations
- [ ] Edge cases
- [ ] Performance

### Phase 9: Documentation (Tasks 9.1-9.3)
- [ ] Model docs
- [ ] API docs
- [ ] Widget examples

## ✅ Validation

```bash
openspec validate add-campaigns-screen --strict
```

**Status:** ✅ PASSED

## 📝 Notlar

- **Sadece kullanıcı tarafı:** İşletme tarafından kampanya yönetimi gelecek bir değişiklikte eklenecek
- **RLS Policies:** Public read access, authenticated write (future)
- **Image Storage:** Opsiyonel, fallback icon mevcut
- **Pagination:** Şimdilik yok, gerekirse eklenecek

## 🔗 İlgili Linkler

- [Proposal](./proposal.md)
- [Tasks](./tasks.md)
- [Design](./design.md)
- [Campaigns Spec](./specs/campaigns/spec.md)
- [Database Spec](./specs/database/spec.md)
- [Navigation Spec](./specs/navigation/spec.md)

## 👥 Approval Required

Bu proposal implement edilmeden önce onay gereklidir. Onaylandıktan sonra `/openspec-apply` workflow'u ile implementation başlatılabilir.
