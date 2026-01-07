# Design: Venue Details Screen

## Architecture

### State Management
- **VenueDetailsProvider**: A dedicated provider will manage the state of the venue details screen.
- It will handle:
    - Loading specific venue details (if not already fully passed from the list).
    - Fetching services associated with the venue.
    - Managing "Follow" status in real-time.
    - Handling tab switching (Services, About, Reviews, Team).

### Data Layer
- **Service Model**:
    ```dart
    class Service {
      final String id;
      final String venueId;
      final String name;
      final String category;
      final double price;
      final int durationMinutes;
      final String? description;
    }
    ```
- **VenueRepository Extension**: Add `getServicesByVenueId(String venueId)` to fetch categorized services.

## UI Components

### 1. Hero Section
- Dynamic image carousel with parallax effect.
- Floating back button and share/bookmark buttons.
- Bottom overlay with Venue Name and Rating.

### 2. Tab Bar
- Persistent tab bar below the hero section.
- Tabs: **Hizmetler (Services)**, **Hakkında (About)**, **Yorumlar (Reviews)**, **Uzmanlar (Team)**.

### 3. Services Tab (Categorized)
- Grouped by `category`.
- List tiles showing service name, duration, and price.
- Premium styling with subtle gold accents for "Book Now" or "Add to Favorites" cues.

### 4. About Tab
- Descriptive text.
- Integrated mini-map with "Get Directions" button.
- Working hours list with "Open/Closed" status indicator.
- List of Amenities (Parking, Wi-Fi, etc.).

### 5. Experts Tab
- Horizontal or grid list of staff profiles.
- Round avatars with names and specialties.

## Interaction Design
- **SliverAppBar**: Use `SliverAppBar` for the hero image to provide a smooth collapse effect when scrolling.
- **Sticky Tabs**: The tab bar should stick to the top when the hero image is collapsed.
- **Micro-animations**: Subtle fades and scale transitions for trust badges and action buttons.

## Visual Reference
Based on `design/mekan_detay_sayfası_1`, `2`, and `3`:
- Use clean borders and generous white space.
- Primary color (Soft Pink/Nude) for active tabs and primary buttons.
- Gold accents for verification icons and premium markers.
