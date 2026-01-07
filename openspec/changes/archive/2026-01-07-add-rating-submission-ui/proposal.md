# Proposal: Add Rating Submission UI

## Overview

Kullanıcıların mekanları değerlendirme ve yorum yapabilmesi için kapsamlı bir rating ve review submission sistemi oluşturulacak. Mevcut sistem sadece yorumları gösterebiliyor, ancak kullanıcılar yeni değerlendirme ekleyemiyor. Bu özellik kullanıcıların deneyimlerini paylaşmasını ve diğer kullanıcıların daha bilinçli karar vermesini sağlayacak.

## Motivation

Platform üzerinde güven ve şeffaflığı artırmak için kullanıcı değerlendirmeleri kritik öneme sahiptir. Kullanıcıların:
- Deneyimlerini paylaşarak diğer kullanıcılara yardımcı olması
- Mekanların kalitesini objektif şekilde değerlendirmesi
- Kendi değerlendirmelerini düzenleyip silebilmesi
- Aldıkları hizmetleri puanlayıp yorum yapabilmesi

gereklidir. Ayrıca mekanlar için de kullanıcı geri bildirimleri hizmet kalitesini artırmak için değerli veri sağlayacaktır.

## Goals

- Kullanıcıların mekanlar için 1-5 yıldız arası rating verebilmesi
- Kullanıcıların opsiyonel olarak yazılı yorum ekleyebilmesi
- Kullanıcıların kendi yorumlarını düzenleyebilmesi ve silebilmesi
- Review submission ekranının premium tasarım diline uygun olması
- Spam ve kötüye kullanımı önlemek için temel validasyonlar (bir kullanıcı bir mekana sadece bir review)
- Mevcut reviews görüntüleme sisteminin geliştirilmesi (rating dağılımı, sıralama seçenekleri)
- Review gönderimi sonrası mekanın ortalama rating'inin otomatik güncellenmesi (zaten mevcut trigger ile yapılıyor)

## Non-Goals

- Review moderasyonu ve admin onay sistemi (gelecek iterasyonda)
- Fotoğraf/medya ekleme özelliği (gelecek iterasyonda)
- Review'lara like/dislike özelliği
- Review'lara yanıt verme sistemi
- "Verified purchase" veya "Verified visit" doğrulaması
- Anonim review gönderimi (tüm review'lar kullanıcı profili ile ilişkili)

## Proposed Solution

### 1. User Flow

```
Mekan Detay Sayfası
  ↓
"Değerlendirme Yap" Butonu
  ↓
Auth Kontrolü (giriş yapmamışsa → Login)
  ↓
Review Submission Screen
  ↓
  ├─ Rating Seçimi (1-5 yıldız, required)
  ├─ Yorum Yazma (opsiyonel, max 500 karakter)
  └─ "Gönder" Butonu
  ↓
Validation \u0026 Submission
  ↓
Success → Mekan Detay'a Dönüş (yeni review görünür)
```

### 2. Screen Structure

#### Review Submission Bottom Sheet / Modal
- **Header**: "Değerlendirmenizi Paylaşın" + venue adı
- **Rating Selector**: 5 interaktif yıldız (tap ile seçim)
- **Comment Text Field**:
  - Multi-line input (max 500 karakter)
  - Placeholder: "Deneyiminizi anlatın..."
  - Karakter sayacı (örn: "450/500")
- **Submit Button**: "Gönder" (rating seçilmeden disabled)
- **Cancel/Close Button**

#### Edit Review Screen (mevcut review varsa)
- Aynı layout ancak:
  - Mevcut rating ve comment pre-filled
  - "Güncelle" butonu yerine "Gönder"
  - "Değerlendirmeyi Sil" butonu (destructive action)

#### Reviews Tab Enhancements
- **"Değerlendirme Yap" CTA**: Tab'ın üst kısmında prominent buton
- **Rating Distribution Chart**: Her yıldız için bar chart (5★: 45%, 4★: 30%, vb.)
- **Sort Options**: "En Yeni", "En Faydalı" (like sistemi olana kadar sadece "En Yeni")
- **User's Own Review Highlight**: Kendi yorumu varsa öne çıkarılacak

### 3. Business Logic

#### Validations
- Rating: 1-5 arası zorunlu
- Comment: Opsiyonel, max 500 karakter
- Bir kullanıcı bir mekana sadece bir review (mevcut varsa edit/delete)
- Authenticated user required

#### Database Operations
- INSERT: Yeni review oluşturma
- UPDATE: Kendi review'unu güncelleme
- DELETE: Kendi review'unu silme
- Trigger zaten mevcut: Review değiştiğinde venue.rating ve venue.rating_count otomatik güncellenir

### 4. Error Handling

- **Duplicate Review**: "Bu mekan için zaten değerlendirme yaptınız. Değerlendirmenizi düzenleyebilirsiniz."
- **Network Error**: "Bağlantı hatası. Lütfen tekrar deneyin."
- **Validation Error**: "Lütfen 1-5 yıldız arası değerlendirme seçin."
- **Character Limit**: "Yorumunuz en fazla 500 karakter olabilir."

### 5. UI/UX Considerations

- **Premium Aesthetic**: Nude, soft pink, cream color palette ile uyumlu
- **Smooth Animations**: Star rating için interactive feedback
- **Loading States**: Submission sırasında buton loading state
- **Success Feedback**: Review gönderildikten sonra subtle success message
- **Keyboard Handling**: Comment yazarken keyboard overlay düzgün çalışmalı

## Implementation Phases

### Phase 1: Core Submission (MVP)
- Review submission bottom sheet UI
- Rating ve comment input
- Basic validation
- Submit API integration
- Existing review check

### Phase 2: Edit \u0026 Delete
- Edit existing review
- Delete review
- Confirmation dialogs

### Phase 3: Enhanced Display
- Rating distribution chart
- Sort options
- User's own review highlight
- Empty state improvements

## Alternative Considered

### Full-Screen Modal vs Bottom Sheet
**Decision**: Bottom Sheet kullanılacak
**Rationale**:
- Daha az intrusive
- Context (mekan bilgisi) görünür kalmaya devam eder
- Modern mobile UX pattern

### Inline Form vs Separate Screen
**Decision**: Bottom Sheet (modal-like)
**Rationale**:
- Clear focus on review submission
- Easier to implement keyboard handling
- Better validation \u0026 error messaging UX

## Dependencies

- Existing `reviews` table in Supabase (✅ already exists)
- Existing RLS policies (✅ already configured)
- Existing `Review` model (✅ already exists)
- Authentication system (⚠️ currently being implemented - `implement-auth-system`)
- Venue details screen (✅ already exists)

## Risks \u0026 Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Spam reviews | Medium | Enforce one review per user per venue |
| Inappropriate content | Medium | Character limit, future moderation system |
| Auth dependency | Low | Auth system being implemented in parallel |
| User confusion editing | Low | Clear UI indicators for edit vs new review |

## Success Metrics

- % of users who view a venue and submit a review
- Average time to submit a review
- Review submission error rate
- User review edit/delete rate
- Average review length (quality indicator)

## Open Questions

1. **Moderation**: Do we need manual review approval before reviews go live?
   - **Answer for now**: No, auto-publish. Add moderation in future if needed.

2. **Photo uploads**: Should users be able to add photos to reviews?
   - **Answer for now**: No, text-only for MVP. Photos in future iteration.

3. **Response from venues**: Should venues be able to respond to reviews?
   - **Answer for now**: No, one-way communication only for now.
