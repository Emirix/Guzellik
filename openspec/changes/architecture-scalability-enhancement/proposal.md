# Proposal: Architecture Scalability & Logical Optimization

## Context
The current system has grown organically, with some data stored in flexible but hard-to-query JSONB fields (like working hours) and assets (images) being managed as simple URL strings across various tables. As the platform prepares for advanced features like booking and comprehensive business analytics, a more structured and centralized approach is required.

## Problem Statement
1. **Asset Management**: Images are stored as simple `TEXT` columns (`avatar_url`, `photo_url`, `hero_image`). This makes it difficult to manage metadata, perform bulk updates, or implement advanced optimizations like blurhash/resizing centrally.
2. **Availability Logic**: `working_hours` is stored as JSONB in the `venues` table. While flexible, querying for "currently open venues" or "venues open on Sundays" is inefficient at scale.
3. **Review Granularity**: Reviews are currently limited to `venues`. Users cannot specifically rate a service (e.g., "The laser hair removal was great") or a specialist (e.g., "Ayşe is a master stylist").
4. **Administrative Audit**: Sensitive operations like subscription updates or venue verification lack a trail, making it hard to track changes in a multi-admin environment.

## Proposed Changes

### 1. Centralized Asset Management System
- Implement a `media` table to store all platform assets (venue photos, profile pictures, specialist photos, certificates).
- Support for metadata (alt text, width/height, primary flag, sort order).
- Transition from direct URL strings to `asset_id` references or a polymorphic `media_items` join table.

### 2. Structured Availability (Venue Hours)
- Move `working_hours` from JSONB to a dedicated `venue_hours` table.
- Each row represents a day (0-6) with open/close times and "is_closed" flag.
- This allows for high-performance PostgreSQL queries to filter "Open Now" venues.

### 3. Polymorphic Review System
- Refactor `reviews` to support multiple "reviewable" entities.
- Users can review a `venue`, a specific `service`, or a `specialist`.
- Aggregated ratings will be calculated for each entity type.

### 4. System Audit Logging
- Implement an `audit_logs` table to track all `INSERT`, `UPDATE`, `DELETE` operations on sensitive tables (`venues`, `venue_subscriptions`, `profiles`).
- Record `actor_id` (who made the change) and the `old_data`/`new_data` diff.

## Goals
- **Scalability**: Enable high-performance queries for availability and complex filtering.
- **Maintainability**: Centralize asset and review logic to avoid duplication.
- **Reliability**: Provide a clear audit trail for administrative actions.
- **Enhanced UX**: Provide users with more granular reviews and reliable "Open Now" information.

## What Changes

### Database (Supabase)
- Create `media` table and related storage triggers.
- Create `venue_hours` table and migrate existing JSONB data.
- Modify `reviews` table structure (or add polymorphic columns).
- Create `audit_logs` table and PostgreSQL triggers for sensitive tables.

### Data Layer (Flutter)
- Update `VenueModel`, `ProfileModel`, and `SpecialistModel` to handle new media structures.
- Update `ReviewRepository` to support target entity types.
- Add `AuditService` or similar for tracking manual admin actions in the UI.

### Presentation (Flutter & Admin Panel)
- Update Venue Detail screen to display structured hours and granular reviews.
- Update Admin Panel (`yonetim/`) to display audit logs and manage centralized media.
