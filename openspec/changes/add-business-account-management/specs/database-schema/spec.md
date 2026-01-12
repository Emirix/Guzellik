# Spec Delta: Database Schema

## ADDED Requirements

### Requirement: Business Account Flag
**GIVEN** a user profile exists in the system  
**WHEN** the profile is queried  
**THEN** it SHALL include an `is_business_account` boolean field indicating whether the account is a business account

#### Scenario: Regular user profile
- Profile has `is_business_account = false` by default
- User can only access normal user features

#### Scenario: Business account profile
- Profile has `is_business_account = true`
- User can access both normal and business features
- Profile has a reference to their business venue

---

### Requirement: Business Venue Association
**GIVEN** a profile with `is_business_account = true`  
**WHEN** the profile is queried  
**THEN** it SHALL include a `business_venue_id` field referencing their associated venue

#### Scenario: Business account with venue
- Profile has `business_venue_id` pointing to their venue
- Relationship is 1-to-1 (one profile, one venue)
- Venue owner_id matches profile id

#### Scenario: Business account without venue (pending)
- Profile has `is_business_account = true` but `business_venue_id = null`
- This occurs when business application is approved but venue not yet created

---

### Requirement: Business Subscriptions Table
**GIVEN** the database schema  
**WHEN** business subscription data needs to be stored  
**THEN** a `business_subscriptions` table SHALL exist with the following columns:
- `id` (UUID, primary key)
- `profile_id` (UUID, foreign key to profiles)
- `subscription_type` (TEXT, default 'standard')
- `status` (TEXT, default 'active')
- `started_at` (TIMESTAMP)
- `expires_at` (TIMESTAMP, nullable)
- `features` (JSONB, default '{}')
- `payment_method` (TEXT, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### Scenario: Active subscription
- Subscription has `status = 'active'`
- `expires_at` is in the future or null (lifetime)
- Business features are accessible

#### Scenario: Expired subscription
- Subscription has `status = 'expired'`
- `expires_at` is in the past
- Business features are restricted

#### Scenario: Standard subscription
- All new business accounts get `subscription_type = 'standard'`
- Standard features are enabled in `features` JSONB

---

### Requirement: RLS Policies for Business Data
**GIVEN** a business account user  
**WHEN** they attempt to access their business data  
**THEN** RLS policies SHALL enforce that:
- Users can only access their own subscription data
- Users can only manage venues where they are the owner
- Users can only access business features if subscription is active

#### Scenario: Business owner accessing own venue
- User with `is_business_account = true` can SELECT, UPDATE their venue
- User cannot access other venues' data

#### Scenario: Non-business user attempting business access
- User with `is_business_account = false` cannot access business_subscriptions
- User cannot modify any venue data

---

## MODIFIED Requirements

### Requirement: Profiles Table Structure
**GIVEN** the existing profiles table  
**WHEN** business account support is added  
**THEN** the table SHALL be extended with:
- `is_business_account` BOOLEAN DEFAULT false
- `business_venue_id` UUID REFERENCES venues(id) NULLABLE

#### Scenario: Backward compatibility
- Existing profiles automatically have `is_business_account = false`
- Existing functionality remains unchanged
- No breaking changes to current queries
