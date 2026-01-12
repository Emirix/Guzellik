# Proposal: Add Business Credits Store

Introduce a credit system for businesses to purchase and spend on premium features like notifications and prominence (being featured).

## Problem
Currently, businesses don't have a way to purchase or manage credits for advanced features. We need a foundation for a monetization model where businesses pay for extra visibility and engagement tools.

## Proposed Solution
- Create a `venue_credits` table to store the current credit balance for each venue.
- Create a `credit_packages` table to define available purchase options.
- Create a `credit_transactions` table to track purchases and usage.
- Implement a "Credit Store" screen in the Flutter app where business owners can see packages and "purchase" them (mocked for now).
- Implement a repository and provider to manage credit data.

## What Changes

### Database
- New table: `venue_credits` (venue_id, balance, updated_at).
- New table: `credit_packages` (id, name, credit_amount, price, description).
- New table: `credit_transactions` (id, venue_id, amount, type, description, created_at).

### Flutter
- New screen: `CreditStoreScreen` for viewing and buying packages.
- New repository: `CreditRepository` for database interactions.
- New provider: `CreditProvider` for state management.
- Update business drawer/navigation to include the Credit Store.

## Impact
- **Venues**: Can now acquire credits to fuel premium features.
- **Admin**: Future potential to manage packages and view transaction history.

## Verification Plan
### Automated Tests
- Unit tests for `CreditRepository`.
- Provider tests for `CreditProvider`.

### Manual Verification
- Navigate to the Credit Store as a business owner.
- View available credit packages.
- Click a package and verify the "mock" purchase increases the credit balance.
- Verify transaction history is recorded.
