# Design: Contact System UI

## Visual Changes

### 1. Booking Bottom Bar -> Contact Bottom Bar
- **Label**: "Randevu Oluştur" -> "İletişime Geç"
- **Icon**: `Icons.calendar_month` -> `Icons.chat_bubble_outline` or `Icons.message`
- **Action**: Instead of navigating to a booking flow, it will trigger the `VenueQuickActionsV2` logic or open a contact selection sheet.

### 2. Service Card
- **Label**: "Randevuya Ekle" -> "Bilgi Al" or removed.
- **Action**: Remove the "added to booking" snackbar.
- **Suggestion**: Clicking the button should open the same contact options as the bottom bar, perhaps pre-filled with the service name.

### 3. Contact Selection (New Component or Existing)
- If the venue has multiple contact methods (WhatsApp, Call, Instagram), the "İletişime Geç" button should show a sleek bottom sheet with these options.
- We can reuse the logic from `VenueQuickActionsV2`.

## Architecture Reasoning
- By keeping the structure of `BookingBottomBar` but changing its purpose, we maintain the premium "single-page" feel of the venue details screen.
- Removing booking logic simplifies state management in `VenueDetailsProvider`.
