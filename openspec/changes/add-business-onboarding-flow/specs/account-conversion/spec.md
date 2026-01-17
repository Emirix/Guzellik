---
status: proposed
created: 2026-01-17
author: AI Assistant
---

# Business Account Conversion Specification

## Purpose
Define the backend requirements for converting a regular user account to a business account, including database updates, subscription creation, and state management.

## MODIFIED Requirements

### Requirement: Business Account Conversion Process
The system SHALL convert a regular user account to a business account with a 1-year trial subscription.

*This modifies the existing `business-account-management` spec's conversion requirement to include the onboarding flow integration.*

#### Scenario: Convert user to business account
- **GIVEN** a regular user with valid business information (name, type)
- **WHEN** the conversion is triggered
- **THEN** the `profiles.is_business_account` field SHALL be set to `true`
- **AND** a record SHALL be created in `business_subscriptions` table
- **AND** the subscription type SHALL be 'trial'
- **AND** the subscription status SHALL be 'active'
- **AND** the subscription SHALL expire 365 days from creation
- **AND** all standard business features SHALL be enabled
- **AND** the operation SHALL be atomic (all or nothing)

#### Scenario: Store business information in profile
- **GIVEN** a user submits business name and type
- **WHEN** the conversion is triggered
- **THEN** the `profiles.business_name` field SHALL be updated with the provided name
- **AND** the `profiles.business_type` field SHALL be updated with the selected category ID
- **AND** this information SHALL be available for pre-filling venue creation forms

#### Scenario: Subscription feature configuration
- **GIVEN** a new trial subscription is created
- **WHEN** the subscription record is inserted
- **THEN** the `features` JSONB field SHALL include:
  - `campaigns`: true
  - `analytics`: true
  - `team_management`: true
  - `priority_support`: true
  - `unlimited_campaigns`: false
  - `featured_listing`: false
- **AND** the feature set SHALL match standard plan capabilities

#### Scenario: Prevent duplicate conversion
- **GIVEN** a user who already has `is_business_account = true`
- **WHEN** the conversion is attempted
- **THEN** the system SHALL return an error
- **AND** the error message SHALL be "Bu hesap zaten işletme hesabıdır"
- **AND** no database changes SHALL be made

#### Scenario: Rollback on failure
- **GIVEN** the conversion process encounters an error
- **WHEN** any step fails (profile update, subscription creation)
- **THEN** all database changes SHALL be rolled back
- **AND** the user's account SHALL remain unchanged
- **AND** an error SHALL be returned to the caller

---

## ADDED Requirements

### Requirement: Profile Schema Extension
The system SHALL extend the profiles table to store temporary business information.

#### Scenario: Add business information fields
- **GIVEN** the profiles table exists
- **WHEN** the migration is applied
- **THEN** a `business_name` TEXT column SHALL be added
- **AND** a `business_type` UUID column SHALL be added
- **AND** the `business_type` column SHALL reference `venue_categories(id)`
- **AND** both columns SHALL be nullable
- **AND** existing rows SHALL have NULL values for these fields

---

### Requirement: Trial Subscription Type
The system SHALL support a 'trial' subscription type for new business accounts.

#### Scenario: Add trial subscription type
- **GIVEN** the business_subscriptions table exists
- **WHEN** the migration is applied
- **THEN** the subscription_type constraint SHALL include 'trial'
- **AND** the allowed values SHALL be: 'trial', 'standard', 'premium', 'enterprise'

#### Scenario: Trial subscription expiration
- **GIVEN** a trial subscription with `expires_at` in the past
- **WHEN** the system checks subscription status
- **THEN** the subscription SHALL be treated as expired
- **AND** the user SHALL be prompted to upgrade to a paid plan
- **AND** business features SHALL be disabled or limited

---

### Requirement: Business Onboarding State Management
The system SHALL manage the state of the onboarding flow.

#### Scenario: Track onboarding progress
- **GIVEN** a user is in the onboarding flow
- **WHEN** the user navigates between steps
- **THEN** the current step SHALL be tracked in memory
- **AND** the step SHALL be preserved during carousel navigation
- **AND** the step SHALL reset when leaving the flow

#### Scenario: Store form data temporarily
- **GIVEN** a user is filling out the business information form
- **WHEN** the user enters data
- **THEN** the data SHALL be stored in the provider state
- **AND** the data SHALL be validated in real-time
- **AND** the data SHALL be cleared after successful submission

#### Scenario: Handle loading state
- **GIVEN** the conversion process is in progress
- **WHEN** the API call is made
- **THEN** a loading state SHALL be set to true
- **AND** the UI SHALL display a loading indicator
- **AND** the submit button SHALL be disabled
- **WHEN** the API call completes (success or error)
- **THEN** the loading state SHALL be set to false

---

### Requirement: Venue Category Retrieval
The system SHALL provide access to active venue categories for the business type dropdown.

#### Scenario: Fetch active venue categories
- **GIVEN** the business information form is displayed
- **WHEN** the categories are requested
- **THEN** the system SHALL query the `venue_categories` table
- **AND** only categories with `is_active = true` SHALL be returned
- **AND** the categories SHALL be ordered by name alphabetically
- **AND** the result SHALL be cached to avoid repeated queries

#### Scenario: Handle category fetch failure
- **GIVEN** the category fetch request fails
- **WHEN** the error occurs
- **THEN** an error message SHALL be displayed to the user
- **AND** the dropdown SHALL show a "Kategoriler yüklenemedi" message
- **AND** a retry option SHALL be provided

---

## Non-Functional Requirements

### Performance
- Account conversion SHALL complete within 3 seconds under normal conditions
- Database transaction SHALL use proper indexing for fast lookups
- Category fetch SHALL be cached for 5 minutes

### Security
- Only authenticated users SHALL be able to convert accounts
- Business name SHALL be sanitized to prevent XSS attacks
- Category ID SHALL be validated against the database before insertion
- Database operations SHALL use parameterized queries

### Reliability
- Conversion SHALL be atomic (use database transaction)
- Failed conversions SHALL not leave partial data
- Subscription expiration SHALL be calculated accurately
- System SHALL handle concurrent conversion attempts gracefully

### Data Integrity
- `business_type` foreign key SHALL enforce referential integrity
- Subscription dates SHALL be stored in UTC
- Feature flags SHALL be stored as valid JSON

---

## Database Schema

### Migration: Add business info to profiles
```sql
-- Add business information fields to profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS business_name TEXT,
ADD COLUMN IF NOT EXISTS business_type UUID REFERENCES venue_categories(id);

-- Add index for business type lookups
CREATE INDEX IF NOT EXISTS idx_profiles_business_type ON profiles(business_type);
```

### Migration: Add trial subscription type
```sql
-- Update subscription type constraint
ALTER TABLE business_subscriptions
DROP CONSTRAINT IF EXISTS business_subscriptions_subscription_type_check;

ALTER TABLE business_subscriptions
ADD CONSTRAINT business_subscriptions_subscription_type_check
CHECK (subscription_type IN ('trial', 'standard', 'premium', 'enterprise'));
```

---

## API Integration

### BusinessRepository Methods

```dart
/// Convert a regular user account to a business account
Future<void> convertToBusinessAccount({
  required String userId,
  required String businessName,
  required String businessType,
}) async {
  // Implementation in design.md
}

/// Check if user can convert to business account
Future<bool> canConvertToBusinessAccount(String userId) async {
  final profile = await _supabase
    .from('profiles')
    .select('is_business_account')
    .eq('id', userId)
    .single();
  
  return profile['is_business_account'] == false;
}
```

### VenueCategoryRepository Methods

```dart
/// Get all active venue categories
Future<List<VenueCategory>> getActiveCategories() async {
  // Implementation in design.md
}
```

---

## Error Handling

### Error Codes

| Error Code | Message | User Action |
|------------|---------|-------------|
| `already-business-account` | "Bu hesap zaten işletme hesabıdır" | Navigate to dashboard |
| `invalid-business-name` | "İşletme adı geçersiz" | Correct input |
| `invalid-business-type` | "İşletme türü seçilmedi" | Select a type |
| `conversion-failed` | "Hesap dönüştürme başarısız oldu" | Retry |
| `database-error` | "Bir hata oluştu. Lütfen tekrar deneyin." | Retry |
| `network-error` | "İnternet bağlantınızı kontrol edin" | Check connection |

---

## Testing Requirements

### Unit Tests
- Test conversion logic with valid data
- Test conversion prevention for existing business accounts
- Test rollback on database error
- Test feature flag generation

### Integration Tests
- Test complete conversion flow from form to database
- Test subscription creation with correct expiration
- Test profile update with business information
- Test category fetch and caching

### Edge Cases
- Test conversion with special characters in business name
- Test conversion with network interruption
- Test concurrent conversion attempts
- Test conversion with invalid category ID

---

## Dependencies
- `profiles` table
- `business_subscriptions` table
- `venue_categories` table
- `AuthProvider` for user authentication
- Supabase client for database operations
