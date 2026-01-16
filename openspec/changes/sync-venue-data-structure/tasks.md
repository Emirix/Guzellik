# Tasks: Sync Venue Data Structure

- [ ] **Database: Implement Sync Triggers**
    - [ ] Create/Update trigger to sync `specialists` -> `venues.expert_team`.
    - [ ] Update `trg_sync_venue_features` to also handle `payment_options` and `accessibility` JSONB columns based on feature categories.
    - [ ] Run a one-time migration to sync existing data for all venues.
    - **Validation**: Verify `venues` table columns are updated after modifying specialists or features in the admin panel.

- [ ] **Data Model: Update Venue and Specialist Models**
    - [ ] Update `Specialist.fromJson` to handle potential field name differences between the table and legacy JSON.
    - [ ] Update `Venue.fromJson` to check for `specialists` and `venue_selected_features` keys.
    - [ ] Add mapping logic in `Venue.fromJson` to populate `expertTeam`, `features`, `paymentOptions`, and `accessibility` from joined data.
    - **Validation**: Unit test `Venue.fromJson` with a mock response containing joined data.

- [ ] **Data Repository: Update Fetching Logic**
    - [ ] Modify `VenueRepository.getVenueById` to use a complete join query.
    - [ ] (Optional) Update `getVenues` or search methods if full data is needed in lists, though triggers might handle this via JSONB.
    - **Validation**: Check logs or debugger to ensure `getVenueById` returns a fully populated `Venue` object.

- [ ] **Provider/UI: Refactor for Consistency**
    - [ ] Update `VenueDetailsProvider.loadVenueDetails` to rely more on the joined `Venue` object if appropriate.
    - [ ] Audit `AboutTab` and other venue tabs to ensure they reference the correct fields.
    - **Validation**: Verify that updates in the admin panel are immediately visible in the User App details page.
