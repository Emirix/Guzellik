---
status: proposed
created: 2026-01-17
author: AI Assistant
---

# Business Onboarding UI Specification

## Purpose
Define the user interface requirements for the business account onboarding flow, including the profile entry point, onboarding carousel, and business information form.

## ADDED Requirements

### Requirement: Profile Screen Entry Point
The system SHALL display a business account conversion option on the profile screen for non-business users.

#### Scenario: Non-business user views profile
- **GIVEN** a logged-in user with `is_business_account = false`
- **WHEN** the user navigates to the profile screen
- **THEN** a "İşletme Hesabına Geç" button SHALL be displayed
- **AND** the button SHALL appear after the settings group and before the logout button
- **AND** the button SHALL have a distinct visual style with primary pink color
- **AND** the button SHALL include an icon (e.g., business/store icon)

#### Scenario: Business user views profile
- **GIVEN** a logged-in user with `is_business_account = true`
- **WHEN** the user navigates to the profile screen
- **THEN** the "İşletme Hesabına Geç" button SHALL NOT be displayed

#### Scenario: User taps business account button
- **GIVEN** a non-business user on the profile screen
- **WHEN** the user taps "İşletme Hesabına Geç"
- **THEN** the system SHALL navigate to the business onboarding screen
- **AND** a smooth page transition SHALL be applied

---

### Requirement: Onboarding Carousel
The system SHALL provide a multi-step carousel to educate users about business account benefits.

#### Scenario: Display onboarding carousel
- **GIVEN** a user navigates to the business onboarding screen
- **WHEN** the screen loads
- **THEN** a 4-step carousel SHALL be displayed
- **AND** the first step SHALL be visible by default
- **AND** dot indicators SHALL show the current step (1 of 4)
- **AND** navigation buttons SHALL be present ("Devam Et" and "Atla")

#### Scenario: Carousel step 1 - Campaign Management
- **GIVEN** the user is on step 1 of the onboarding carousel
- **THEN** the title SHALL be "Kampanyalarınızı Yönetin"
- **AND** the description SHALL be "Takipçilerinize özel kampanyalar oluşturun ve anında bildirim gönderin"
- **AND** a campaign/megaphone icon SHALL be displayed
- **AND** the visual style SHALL use primary pink gradient

#### Scenario: Carousel step 2 - Analytics
- **GIVEN** the user is on step 2 of the onboarding carousel
- **THEN** the title SHALL be "Performansınızı Takip Edin"
- **AND** the description SHALL be "Mekanınızın görüntülenme, takipçi ve değerlendirme istatistiklerini görün"
- **AND** a charts/analytics icon SHALL be displayed

#### Scenario: Carousel step 3 - Team Management
- **GIVEN** the user is on step 3 of the onboarding carousel
- **THEN** the title SHALL be "Ekibinizi ve Hizmetlerinizi Yönetin"
- **AND** the description SHALL be "Uzmanlarınızı ekleyin, hizmetlerinizi düzenleyin ve fiyatlandırma yapın"
- **AND** a team/services icon SHALL be displayed

#### Scenario: Carousel step 4 - Premium Features
- **GIVEN** the user is on step 4 of the onboarding carousel
- **THEN** the title SHALL be "Premium Özelliklere Erişin"
- **AND** the description SHALL be "Öne çıkan listeleme, öncelikli destek ve daha fazlası"
- **AND** a premium/star icon SHALL be displayed
- **AND** gold accent color SHALL be used for premium emphasis

#### Scenario: Navigate carousel by swiping
- **GIVEN** the user is viewing any step of the carousel
- **WHEN** the user swipes left
- **THEN** the next step SHALL be displayed (if not on last step)
- **AND** the dot indicator SHALL update to reflect the current step
- **AND** a smooth transition animation SHALL be applied

#### Scenario: Navigate carousel by tapping "Devam Et"
- **GIVEN** the user is viewing any step except the last
- **WHEN** the user taps "Devam Et"
- **THEN** the next step SHALL be displayed
- **AND** the button text SHALL remain "Devam Et" until the last step

#### Scenario: Complete carousel on last step
- **GIVEN** the user is on step 4 (last step)
- **WHEN** the user taps "Devam Et"
- **THEN** the system SHALL navigate to the business information form screen

#### Scenario: Skip onboarding
- **GIVEN** the user is viewing any step of the carousel
- **WHEN** the user taps "Atla"
- **THEN** the system SHALL navigate directly to the business information form screen

---

### Requirement: Business Information Form
The system SHALL collect essential business information through a validated form.

#### Scenario: Display business information form
- **GIVEN** a user navigates to the business information form screen
- **WHEN** the screen loads
- **THEN** a form SHALL be displayed with the following fields:
  - Business name (text input, required)
  - Business type (dropdown, required)
- **AND** a "İşletme Hesabını Oluştur" submit button SHALL be displayed
- **AND** the submit button SHALL be disabled by default

#### Scenario: Business name input validation
- **GIVEN** the user is on the business information form
- **WHEN** the user enters a business name
- **THEN** the input SHALL accept alphanumeric characters and common symbols
- **AND** the minimum length SHALL be 2 characters
- **AND** the maximum length SHALL be 100 characters
- **AND** real-time validation feedback SHALL be shown

#### Scenario: Business type selection
- **GIVEN** the user is on the business information form
- **WHEN** the user taps the business type dropdown
- **THEN** a list of venue categories SHALL be displayed:
  - Güzellik Salonu
  - Kadın Kuaförleri
  - Tırnak Stüdyoları
  - Estetik Yerleri
  - Ayak Bakım
  - Kirpik & Kaş Stüdyo
  - Epilasyon Merkezleri
  - Cilt Bakım Merkezleri
- **AND** the categories SHALL be fetched from the `venue_categories` table
- **AND** only active categories SHALL be shown

#### Scenario: Enable submit button
- **GIVEN** the user is on the business information form
- **WHEN** both business name and business type are valid
- **THEN** the submit button SHALL be enabled
- **AND** the button SHALL change visual state to indicate it's clickable

#### Scenario: Form validation error
- **GIVEN** the user is on the business information form
- **WHEN** the user taps submit with invalid data
- **THEN** error messages SHALL be displayed for each invalid field
- **AND** the form SHALL NOT be submitted
- **AND** the first invalid field SHALL receive focus

#### Scenario: Submit business information
- **GIVEN** the user has filled out the form with valid data
- **WHEN** the user taps "İşletme Hesabını Oluştur"
- **THEN** a loading indicator SHALL be displayed
- **AND** the submit button SHALL be disabled during processing
- **AND** the account conversion process SHALL be triggered

---

### Requirement: Success and Error States
The system SHALL provide clear feedback for conversion success and failure.

#### Scenario: Successful account conversion
- **GIVEN** the account conversion completes successfully
- **WHEN** the backend confirms the conversion
- **THEN** a success message SHALL be displayed (SnackBar or Dialog)
- **AND** the message SHALL read "İşletme hesabınız başarıyla oluşturuldu!"
- **AND** the user SHALL be navigated to the business dashboard or venue setup screen
- **AND** the loading indicator SHALL be hidden

#### Scenario: Account conversion failure
- **GIVEN** the account conversion fails
- **WHEN** the backend returns an error
- **THEN** an error message SHALL be displayed (SnackBar)
- **AND** the message SHALL be user-friendly (e.g., "Bir hata oluştu. Lütfen tekrar deneyin.")
- **AND** the submit button SHALL be re-enabled
- **AND** the loading indicator SHALL be hidden
- **AND** the user SHALL remain on the form screen

---

## Non-Functional Requirements

### Performance
- Carousel transitions SHALL complete within 300ms
- Form validation SHALL provide feedback within 100ms
- Category dropdown SHALL load within 1 second

### Accessibility
- All interactive elements SHALL have minimum 48x48 logical pixel touch targets
- Form fields SHALL have semantic labels for screen readers
- Error messages SHALL be announced to screen readers
- Color contrast SHALL meet WCAG AA standards

### Responsiveness
- UI SHALL adapt to different screen sizes (phones, tablets)
- Carousel SHALL support both portrait and landscape orientations
- Form SHALL be scrollable on small screens

### Visual Design
- Follow existing design system (nude, soft pink, gold accents)
- Use `AppColors.primary` for all primary CTAs
- Apply consistent spacing (20px card padding, 24px section spacing)
- Use 20px border radius for cards, 12px for inputs
- Smooth animations for all transitions

---

## Dependencies
- `AppColors` theme system
- `AuthProvider` for user state
- `VenueCategoryRepository` for category data
- Navigation system (GoRouter)
