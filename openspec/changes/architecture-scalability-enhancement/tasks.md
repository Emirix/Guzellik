# Tasks: Architecture Scalability & Logical Optimization

## Phase 1: Database Foundation & Media System
- [x] Create migration for `media` and `entity_media` tables. <!-- id: 0 -->
- [x] Implement storage triggers for automatic folder organization in Supabase Storage. <!-- id: 1 -->
- [x] Create data migration script to move existing URL strings to the `media` system. <!-- id: 2 -->
- [x] Create Database Views (e.g., `view_venues_with_media`) to maintain compatibility while transitioning. <!-- id: 3 -->

## Phase 2: Structured Availability
- [x] Create migration for `venue_hours` table. <!-- id: 4 -->
- [x] Develop and run migration script to parse `venues.working_hours` JSONB into structured table rows. <!-- id: 5 -->
- [x] Implement PostgreSQL helper function `is_venue_open(venue_id)` for high-performance status checks. <!-- id: 6 -->

## Phase 3: Reviews & Audit
- [x] Modify `reviews` table to support polymorphic targets (`target_type`, `target_id`). <!-- id: 7 -->
- [x] Create `audit_logs` table and generic audit trigger function. <!-- id: 8 -->
- [x] Attach audit triggers to `venues`, `venue_subscriptions`, and `profiles` tables. <!-- id: 9 -->

## Phase 4: Flutter Data Layer Updates
- [x] Refactor `AssetModel` and update `VenueModel`, `SpecialistModel`, and `ProfileModel` to use the new media structure. <!-- id: 10 -->
- [ ] Update `BusinessRepository` and `VenueRepository` to fetch media via the new join-table logic. <!-- id: 11 -->
- [ ] Create `AvailabilityService` in Flutter to handle complex opening hour logic and "Open Now" states. <!-- id: 12 -->

## Phase 5: UI Integration & Cleanup
- [ ] Update Venue Detail page to display structured working hours. <!-- id: 13 -->
- [ ] Update Specialist profiles to support detailed galleries/media. <!-- id: 14 -->
- [ ] Implement Audit trail viewer in the Admin Panel (`yonetim/`). <!-- id: 15 -->
- [ ] (Final Step) Remove deprecated columns (`photo_url`, `working_hours` JSONB) once the migration is fully validated. <!-- id: 16 -->
