# Change: Populate Venue Details Mock Data

## Why
Currently, the "Hizmetler" (Services), "Yorumlar" (Reviews), and "Uzmanlar" (Experts) tabs in the venue details screen are empty or have placeholders because there is no comprehensive test data in the database. Adding this data will allow for a complete demonstration and testing of the venue details page features.

## What Changes
- **Database**: Add `reviews` table and seed data for services, reviews, and experts.
- **Models**: Add `Review` model and update `Venue` model if needed.
- **Repository**: Add review fetching logic to `VenueRepository`.
- **UI**: Replace "Reviews Coming Soon" placeholder with a functional `ReviewsTab`, and ensure `ServicesTab`/`ExpertsTab` display data.

## Impact
- Affected specs: `database`, `venue-details` (which maps to current components)
- Affected code: `lib/data/models/`, `lib/data/repositories/`, `lib/presentation/widgets/venue/tabs/`
