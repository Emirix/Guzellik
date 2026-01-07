# Venue Details Specification Delta

## MODIFIED Requirements

### Requirement: Reviews Display Enhancement
The venue details reviews tab SHALL display rating distribution, sorting options, and highlight user's own review.

#### Scenario: Rating distribution visualization
- **GIVEN** a venue with multiple reviews
- **WHEN** the user views the Reviews tab
- **THEN** a rating distribution chart is displayed below the average rating
- **AND** each star level (1★ to 5★) shows a horizontal bar representing the percentage of reviews
- **AND** the percentage value is displayed next to each bar (e.g., "45%")

#### Scenario: User's own review highlighted
- **GIVEN** an authenticated user who has reviewed the venue
- **WHEN** the user views the Reviews tab
- **THEN** the user's own review appears at the top of the list
- **AND** the review has a visual indicator (e.g., "Sizin değerlendirmeniz" label or subtle background)
- **AND** the review displays "Düzenle" and "Sil" action buttons

#### Scenario: No reviews empty state
- **GIVEN** a venue with no reviews
- **WHEN** the user views the Reviews tab
- **THEN** an empty state illustration is displayed
- **AND** text "Henüz değerlendirme yok" is shown
- **AND** a "İlk Değerlendirmeyi Siz Yapın" call-to-action button is displayed

#### Scenario: Sort reviews by newest
- **GIVEN** a venue with multiple reviews
- **WHEN** the user views the Reviews tab
- **THEN** reviews are sorted by creation date (newest first) by default
- **AND** a sort dropdown/button displays "En Yeni"

## ADDED Requirements

### Requirement: Review Call-to-Action
The venue details screen SHALL prominently display a button to encourage users to submit reviews.

#### Scenario: Review CTA in Reviews tab
- **GIVEN** an authenticated user viewing a venue's Reviews tab
- **WHEN** the user has not yet reviewed this venue
- **THEN** a prominent "Değerlendirme Yap" button is displayed at the top of the tab
- **AND** the button uses primary color styling to draw attention

#### Scenario: Review CTA in Overview tab
- **GIVEN** an authenticated user viewing a venue's Overview tab
- **WHEN** the Reviews section is visible
- **THEN** a "Tüm Değerlendirmeleri Gör \u0026 Değerlendirme Yap" link or button is displayed
- **AND** tapping it navigates to the Reviews tab and opens the review submission screen

#### Scenario: Review CTA for unauthenticated users
- **GIVEN** an unauthenticated user viewing a venue details screen
- **WHEN** the user views any section showing review prompts
- **THEN** the "Değerlendirme Yap" button is still visible
- **AND** tapping it redirects to the login screen
