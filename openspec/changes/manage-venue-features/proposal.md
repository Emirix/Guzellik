# Proposal: Enhanced Venue Features System

## Problem
The current venue features system is fragmented. Features like "Wi-Fi" and "Parking" are stored in a rigid `accessibility` JSONB field, while "Payment Options" are in another. The recently introduced `venue_features` master-list system is not yet fully integrated into the venue profile page or search synchronization. Users want more granular features and an easy way for businesses to manage them.

## Proposed Solution
We will unify the venue features into a single, dynamic system based on the `venue_features` table.

1.  **Master List Expansion**: Add 10-15 new high-value features to the database (e.g., "VIP Oda", "Bahçe/Teras", "Kadınlara Özel", "Evcil Hayvan Dostu", etc.).
2.  **Icon Removal**: Remove icons from chips on both the Venue Profile page and the Admin Selection screen to maintain a cleaner, text-focused look as requested.
3.  **Route Integration**: Add the "İşletme Özellikleri" management screen to the Admin Dashboard and App Router so businesses can easily discover and edit their features.
4.  **Automatic Synchronization**: Implement a database trigger to keep the `venues.features` JSONB column (used for search/filtering) in sync with the `venue_selected_features` junction table.
5.  **Premium UI Design**: Update the venue profile's "About" tab to display all selected features as stylish, text-only chips organized into a single "Özellikler" section.

## Dependencies
- Supabase (PostgreSQL) for schema changes and triggers.
- Provider for state management in the admin section.

## Verification Plan
### Automated Tests
- Test database trigger for sync between junction table and venues column.
- Test repository methods for fetching and updating features.

### Manual Verification
- Verify that features selected in Admin Panel appear correctly on the Venue Profile page.
- Verify that icons match the feature types.
- Verify search filtering still works after sync implementation.
