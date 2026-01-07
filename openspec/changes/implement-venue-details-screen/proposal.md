# Proposal: Implement Venue Details Screen

## Problem
The application currently allows users to list venues on the discovery screen, but there is no way to view detailed information about a specific venue. Users cannot see available services, staff information, working hours, or precise location details, which is critical for making a booking decision.

## Proposed Solution
Implement a comprehensive venue details screen that allows users to explore everything about a venue. This screen will be the central hub for user engagement with service providers.

### Key Features
- **Visual Gallery**: High-quality photo carousel of the venue.
- **Service Categories**: Grouped services (e.g., Hair, Nails, Aesthetics) with pricing and duration.
- **Expert Team**: Profile list of professionals working at the venue.
- **Venue Info**: Integrated map, address detail, working hours, and contact options.
- **Trust Badges**: Visual confirmation of verification, preference, and hygiene status.
- **Action Hub**: Quick actions for following, sharing, and navigation.

## Goals
- Provide users with all necessary information to choose a service.
- Maintain a premium, clean aesthetic consistent with the brand.
- Enable easy navigation from the discovery screen to venue details.

## Discovery Research
- Existing `Venue` model already contains most metadata fields (working hours, social links, expert team).
- `VenueCard` in the discovery list needs its `onTap` listener implemented to navigate to the new screen.
- A new `Service` model and database fetching logic are required for the categorized service list.

## Risk Assessment
- **Image Performance**: Large galleries might impact performance if not optimized.
- **Data Complexity**: Grouping services by category requires careful UI state management.
