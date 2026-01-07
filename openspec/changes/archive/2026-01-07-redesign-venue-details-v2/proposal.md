# Proposal: Redesign Venue Details to V2

## Problem
The current venue details screen uses a tabbed layout that divides information across multiple views. While functional, it doesn't match the new premium, high-density single-page design provided in `mekan_detay_sayfası_2`. The current design lacks visual depth in sections like certificates, features, and the integrated map/hours experience.

## Proposed Solution
Redesign the `VenueDetailsScreen` and its components to perfectly match the `mekan_detay_sayfası_2` design. This involves shifting from a strictly tabbed interface to a more integrated overview page that presents the venue's story, experts, hours, location, and social proof in a single, premium scrollable view.

### Key Features
- **Enhanced Hero**: Updated pagination dots, glass-effect action buttons (Back, Favorite, Share), and a bottom-rounded transition.
- **Integrated Overview**: A single scrollable flow containing:
    - Venue identity (Title, Location, Category, Logo).
    - Rating & Follow action.
    - Social/Communication Quick Actions (WhatsApp, Call, Map, Instagram).
    - About Section with "Read More".
    - Horizontal Expert List with premium avatars.
    - Working Hours Card with "Currently Open" indicator.
    - Integrated Map Preview with "See on Map" overlay.
    - Certificates & Awards grid.
    - Features & Amenities chips.
    - Recent Reviews preview.
- **Persistent Booking Bar**: A bottom bar showing starting price and a prominent "Book Appointment" button.

## Goals
- Achieve 1:1 visual match with the `mekan_detay_sayfası_2` design.
- Improve information density and user engagement by showing key details on the main page.
- Maintain the "Services" functionality while aligning with the new aesthetic.

## Discovery Research
- The `mekan_detay_sayfası_2` design is an HTML/Tailwind representation that needs to be translated into Flutter widgets.
- Some data points (certificates, features) might need to be added to the `Venue` model or handled as optional fields.
- The layout uses `Glassmorphism` and specific shadow/border patterns that should be standardized in the theme.

## Risk Assessment
- **Content Length**: A single long page might feel overwhelming; careful spacing and dividers (as seen in the design) are essential.
- **Data Completeness**: If a venue is missing certificates or features, the UI must handle their absence gracefully.
