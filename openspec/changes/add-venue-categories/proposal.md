# Proposal: Add Venue Category System

## Problem
Currently, venue categories (e.g., Güzellik Salonu, Kuaför) are only defined as a text list in documentation and lack a structured representation in the database. This makes it difficult to:
- Filter venues by category efficiently.
- Manage categories dynamically (add/remove/edit) without code changes.
- Ensure data consistency across the platform.

## Proposed Solution
Implement a dedicated `venue_categories` table in the database and link it to the `venues` table. This will involve:
1.  **Database Migration**: Creating the `venue_categories` table and adding a foreign key `category_id` to the `venues` table.
2.  **Data Population**: Inserting the initial set of categories provided by the user.
3.  **Model Updates**: Updating the `Venue` and creating a `VenueCategory` model in the Flutter application.
4.  **UI Updates**: (Optional but likely needed) Updating discovery and search screens to use these categories for filtering.

## Impact
- **Database**: New table `venue_categories`, modified table `venues`.
- **Data Model**: New `VenueCategory` class, updated `Venue` class.
- **API**: Repositories will now fetch category information along with venues.
- **UI**: Improved filtering and discovery experience.
