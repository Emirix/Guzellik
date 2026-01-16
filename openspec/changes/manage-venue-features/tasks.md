# Tasks: Enhanced Venue Features System

- [x] **Infrastructure & Database**
    - [x] Create a migration to add new feature entries to `venue_features`.
    - [x] Add `sync_venue_features_to_array` trigger to Supabase to keep `venues.features` in sync with `venue_selected_features`.
    - [x] (Optional) Migrate existing `accessibility` and `payment_options` data to new system.

- [x] **Data Model & Repository**
    - [x] Update `Venue` model to ensure `features` are correctly parsed and possibly include `VenueFeature` objects if needed for UI icons.
    - [x] Update `VenueRepository` to fetch selected features with their details (icons, names) for the profile page.

- [x] **Admin Panel & Navigation**
    - [x] Update `AppRouter.dart` to include `/business/admin/features` route.
    - [x] Add "İşletme Özellikleri" list item to `AdminDashboardScreen`.
    - [x] Update `AdminFeaturesScreen` to remove icon display and checkboxes (use a toggle or simpler list).
    - [x] Add an "Özellikleri Düzenle" section to the Profile settings flow if requested.

- [x] **Venue Profile UI**
    - [x] Update `AboutTab` to display features as stylish, text-only chips.
    - [x] Remove old hardcoded sections for "Ödeme Seçenekleri" and "Özellikler".
    - [x] Ensure responsive layout with `Wrap`.

- [x] **Verification**
    - [x] Verify database sync works by updating features in admin and checking `venues` table.
    - [x] Verify UI displays text chips correctly without icons.
    - [x] Verify search by feature still works.
