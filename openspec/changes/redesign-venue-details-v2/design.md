# Design: Redesign Venue Details to V2

## Architectural Concepts

### Layout Strategy: Single-Page vs Tabbed
The design `mekan_detay_sayfası_2` presents a comprehensive overview in a single scroll. However, the application requires a list of services for booking.
We will maintain the `NestedScrollView` structure but redesign the "Overview" (currently `AboutTab`) to be the primary, default view that contains almost everything from the design.
The "Services" will remain a tab for easy access to booking, or we will implement a "Randevu Oluştur" button that either navigates to the services tab or opens a booking modal.

### Component Breakdown
1. **VenueHeaderV2**: Handles the Hero image, back/fav/share buttons, and the rounded overlapping title card.
2. **VenueIdentityV2**: Shows the title, location, category, and floating logo.
3. **VenueActionsV2**: The grid of 4 buttons (WhatsApp, Search, Map, Instagram).
4. **ExpertsSection**: Horizontal scroll of expert profiles with the pink border for the first one (as seen in design).
5. **HoursAndLocationCard**: Combines the working hours list and the map preview.
6. **SocialProofSection**: Grid for Certificates/Awards and the Reviews preview.
7. **BookingBottomBarV2**: updated with the starting price label on the left and the primary button on the right.

### State & Data
- The `Venue` model will be extended if necessary to support:
    - `certificates` (List of objects with title/subtitle/icon).
    - `features` (List of strings or enums).
    - `instagram_username` or `social_links`.
- `VenueDetailsProvider` will continue to manage the state.

### Visual Tokens
- **Colors**:
    - Primary: `#ee2b5b` (already standard)
    - Nude: `#f3e7ea` (new background/border color)
    - Gold: `#D4AF37` (for awards)
- **Effects**:
    - Glassmorphism for header buttons (`bg-white/30 backdrop-blur-md`).
    - Specific shadows for cards (`shadow-[0_-4px_20px_rgba(0,0,0,0.05)]`).
    - Pagination dots for hero.
