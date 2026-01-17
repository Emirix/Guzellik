# Proposal: Business Account Onboarding Flow

## Overview
Add a comprehensive onboarding flow for users to convert their regular accounts to business accounts. This includes a "Switch to Business Account" button on the profile page, a step-by-step onboarding carousel showcasing business features, and a business information form to complete the conversion with a 1-year free trial subscription.

## Problem Statement
Currently, users cannot easily discover or convert to business accounts from within the app. There is no clear entry point or guided process to help users understand the benefits of a business account and complete the conversion.

## Proposed Solution

### 1. Profile Page Entry Point
- Add a prominent "İşletme Hesabına Geç" button at the bottom of the profile screen (before the logout button)
- Button should only appear for users who are NOT already business accounts
- Design: Primary pink gradient with icon, visually distinct from other menu items

### 2. Onboarding Carousel
A 4-step carousel that educates users about business account benefits:

**Step 1: Campaign Management**
- Title: "Kampanyalarınızı Yönetin"
- Description: "Takipçilerinize özel kampanyalar oluşturun ve anında bildirim gönderin"
- Icon/Illustration: Campaign/megaphone visual

**Step 2: Analytics & Insights**
- Title: "Performansınızı Takip Edin"
- Description: "Mekanınızın görüntülenme, takipçi ve değerlendirme istatistiklerini görün"
- Icon/Illustration: Charts/analytics visual

**Step 3: Team & Service Management**
- Title: "Ekibinizi ve Hizmetlerinizi Yönetin"
- Description: "Uzmanlarınızı ekleyin, hizmetlerinizi düzenleyin ve fiyatlandırma yapın"
- Icon/Illustration: Team/services visual

**Step 4: Premium Features**
- Title: "Premium Özelliklere Erişin"
- Description: "Öne çıkan listeleme, öncelikli destek ve daha fazlası"
- Icon/Illustration: Premium/star visual

- Navigation: Swipeable carousel with dot indicators
- Bottom: "Devam Et" button (enabled after viewing all steps or immediately)

### 3. Business Information Form
After completing onboarding, users fill out:
- **İşletme Adı** (required, text input)
- **İşletme Türü** (required, dropdown from `venue_categories` table)
  - Güzellik Salonu
  - Kadın Kuaförleri
  - Tırnak Stüdyoları
  - Estetik Yerleri
  - Ayak Bakım
  - Kirpik & Kaş Stüdyo
  - Epilasyon Merkezleri
  - Cilt Bakım Merkezleri

- Submit button: "İşletme Hesabını Oluştur"

### 4. Account Conversion
Upon form submission:
1. Set `is_business_account = true` in `profiles` table
2. Create a subscription record in `business_subscriptions`:
   - `subscription_type`: 'trial' or 'standard'
   - `status`: 'active'
   - `expires_at`: 1 year from now
   - `features`: All standard features enabled
3. Show success message
4. Navigate to business dashboard or prompt to create/claim venue

## Design Principles
- **Clean & Premium**: Follow existing design system (nude, soft pink, gold accents)
- **Primary Pink Buttons**: Use `AppColors.primary` for all CTAs
- **Smooth Transitions**: Page transitions and carousel animations
- **Mobile-First**: Optimized for mobile screens
- **Accessibility**: Clear labels, sufficient contrast, touch targets

## User Flow
```
Profile Screen
    ↓
[İşletme Hesabına Geç] button
    ↓
Onboarding Carousel (4 steps)
    ↓
[Devam Et] button
    ↓
Business Information Form
    ↓
[İşletme Hesabını Oluştur] button
    ↓
Account Conversion (backend)
    ↓
Success Message
    ↓
Navigate to Business Dashboard / Venue Setup
```

## Dependencies
- Existing `business-account-management` spec
- `venue_categories` table in database
- `profiles` table with `is_business_account` field
- `business_subscriptions` table
- Business dashboard screen (already exists)

## Success Criteria
- [ ] Users can discover business account option from profile
- [ ] Onboarding carousel clearly communicates benefits
- [ ] Form validation works correctly
- [ ] Account conversion creates proper database records
- [ ] 1-year trial subscription is activated
- [ ] User can switch back to normal mode (existing functionality)

## Out of Scope
- Payment integration for subscription renewal
- Venue creation/claiming flow (handled separately)
- Business dashboard enhancements
- Multi-user access control

## Risks & Mitigations
- **Risk**: Users might skip onboarding too quickly
  - **Mitigation**: Make carousel engaging with visuals, allow immediate skip
  
- **Risk**: Form validation errors confuse users
  - **Mitigation**: Clear error messages, inline validation

- **Risk**: Database transaction fails during conversion
  - **Mitigation**: Proper error handling, rollback mechanism

## Timeline Estimate
- Design & Spec: 1 day
- Implementation: 2-3 days
- Testing & Polish: 1 day
- **Total**: 4-5 days
