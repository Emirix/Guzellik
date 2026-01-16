# Venue Details Specification

## MODIFIED Requirements

### Requirement: Specialist Avatar Display
**ID**: VENUE-SPECIALIST-AVATAR-DISPLAY

Specialist avatars displayed in venue details SHALL use gender-specific background colors when no photo is available.

#### Scenario: Expert Card Avatar Rendering
**GIVEN** a venue details page displaying specialists  
**AND** a specialist without a photo URL  
**WHEN** the specialist's `ExpertCard` is rendered  
**THEN** the avatar background color SHALL match the specialist's gender:
  - Male → Light blue (`AppColors.avatarMale`)
  - Female → Light pink (`AppColors.avatarFemale`)
  - Unknown/Null → Neutral gray (`AppColors.avatarNeutral`)

#### Scenario: Experts Tab Consistency
**GIVEN** the "Experts" tab in venue details  
**AND** multiple specialists with different genders  
**WHEN** the tab displays the specialist list  
**THEN** each specialist avatar SHALL display the correct gender-based background color  
**AND** the colors SHALL be consistent across all viewing modes (list, grid)

#### Scenario: Experts Section V2 Rendering
**GIVEN** the V2 design of the experts section  
**AND** specialists without photos  
**WHEN** the section is rendered  
**THEN** avatar background colors SHALL match the gender-based color scheme  
**AND** SHALL be visually consistent with V1 design

---

### Requirement: Admin Specialist Management Avatar Display
**ID**: VENUE-ADMIN-SPECIALIST-AVATAR

Specialist avatars in the admin management interface SHALL use the same gender-based color scheme as the user-facing interface.

#### Scenario: Admin Specialist Card Rendering
**GIVEN** the admin specialists management screen  
**AND** a specialist without a photo  
**WHEN** the specialist card is rendered  
**THEN** the avatar background color SHALL match the specialist's gender using the same logic as user-facing components

#### Scenario: Consistency Between Admin and User Views
**GIVEN** a specialist viewed in both admin panel and user-facing venue details  
**WHEN** the specialist has no photo  
**THEN** the avatar background color SHALL be identical in both views

---

### Requirement: Avatar Color Accessibility
**ID**: VENUE-AVATAR-ACCESSIBILITY

Avatar background colors SHALL maintain sufficient contrast for accessibility.

#### Scenario: Icon Contrast Ratio
**GIVEN** any gender-based avatar background color  
**AND** the default person icon displayed on the avatar  
**WHEN** rendered together  
**THEN** the contrast ratio between icon and background SHALL be at least 3:1 (WCAG AA for large graphics)

#### Scenario: Color Independence
**GIVEN** a user with color vision deficiency  
**WHEN** viewing specialist avatars  
**THEN** the specialist's name and profession text SHALL provide sufficient information  
**AND** color SHALL NOT be the only means of conveying specialist identity
