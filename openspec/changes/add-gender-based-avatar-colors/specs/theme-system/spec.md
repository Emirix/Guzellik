# Theme System Specification

## MODIFIED Requirements

### Requirement: Avatar Color Palette
**ID**: THEME-AVATAR-COLORS

The theme system SHALL provide gender-specific avatar background colors for specialist/expert profiles without photos.

#### Scenario: Male Specialist Avatar Background
**GIVEN** a specialist with gender set to "male", "erkek", "M", or "m"  
**AND** the specialist has no photo URL  
**WHEN** the avatar is rendered  
**THEN** the avatar background color SHALL be light blue (`Color(0xFFE3F2FD)`)

#### Scenario: Female Specialist Avatar Background
**GIVEN** a specialist with gender set to "female", "kadın", "F", or "f"  
**AND** the specialist has no photo URL  
**WHEN** the avatar is rendered  
**THEN** the avatar background color SHALL be light pink (`Color(0xFFFFEAF3)`)

#### Scenario: Neutral Specialist Avatar Background
**GIVEN** a specialist with null, empty, or unrecognized gender value  
**AND** the specialist has no photo URL  
**WHEN** the avatar is rendered  
**THEN** the avatar background color SHALL be neutral gray (`Color(0xFFF5F5F5)`)

#### Scenario: Specialist With Photo
**GIVEN** a specialist with any gender value  
**AND** the specialist has a valid photo URL  
**WHEN** the avatar is rendered  
**THEN** the photo SHALL be displayed  
**AND** the background color SHALL NOT be visible

---

### Requirement: Avatar Color Constants
**ID**: THEME-AVATAR-COLOR-CONSTANTS

The `AppColors` class SHALL define the following color constants for avatar backgrounds:

- `avatarMale`: `Color(0xFFE3F2FD)` - Light blue for male specialists
- `avatarFemale`: `Color(0xFFFFEAF3)` - Light pink for female specialists (matches existing `primaryLight`)
- `avatarNeutral`: `Color(0xFFF5F5F5)` - Neutral gray for unknown gender (matches existing `gray100`)

#### Scenario: Color Constants Accessibility
**GIVEN** any widget in the application  
**WHEN** the widget imports `app_colors.dart`  
**THEN** the widget SHALL be able to access `AppColors.avatarMale`, `AppColors.avatarFemale`, and `AppColors.avatarNeutral`

---

### Requirement: Gender-Based Color Utility
**ID**: THEME-AVATAR-COLOR-UTILITY

The system SHALL provide a utility function `getAvatarBackgroundColor(String? gender)` that returns the appropriate avatar background color based on gender.

#### Scenario: Case-Insensitive Gender Matching
**GIVEN** a gender value of "MALE", "Male", or "male"  
**WHEN** `getAvatarBackgroundColor()` is called  
**THEN** it SHALL return `AppColors.avatarMale`

**GIVEN** a gender value of "FEMALE", "Female", or "female"  
**WHEN** `getAvatarBackgroundColor()` is called  
**THEN** it SHALL return `AppColors.avatarFemale`

#### Scenario: Multiple Gender Format Support
**GIVEN** a gender value of "erkek" or "E"  
**WHEN** `getAvatarBackgroundColor()` is called  
**THEN** it SHALL return `AppColors.avatarMale`

**GIVEN** a gender value of "kadın" or "K"  
**WHEN** `getAvatarBackgroundColor()` is called  
**THEN** it SHALL return `AppColors.avatarFemale`

#### Scenario: Null and Unknown Gender Handling
**GIVEN** a gender value of null, empty string, or unrecognized value  
**WHEN** `getAvatarBackgroundColor()` is called  
**THEN** it SHALL return `AppColors.avatarNeutral`
