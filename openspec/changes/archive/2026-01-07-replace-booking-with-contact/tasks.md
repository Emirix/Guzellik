# Tasks: Replace Booking with Contact Button

- [x] Update `BookingBottomBar` widget <!-- id: 0 -->
    - [x] Rename text from "Randevu Oluştur" to "İletişime Geç"
    - [x] Change icon to `Icons.chat_bubble_outline`
    - [x] (Optional) Rename component to `ContactBottomBar` if appropriate, but keeping name is fine for now if requested as a simple change.

- [x] Update `VenueDetailsScreen` integration <!-- id: 1 -->
    - [x] Update the `onBookingTap` callback to trigger a contact selection sheet or scroll to `VenueQuickActionsV2`.
    - [x] Create a `showContactOptions(BuildContext context, Venue venue)` helper.

- [x] Update `ServiceCard` widget <!-- id: 2 -->
    - [x] Rename "Randevuya Ekle" button to "Bilgi Al"
    - [x] Remove the "randevuya eklendi" snackbar logic.
    - [x] Update the `onAddToBooking` callback name to `onInquiry`.

- [x] Update `VenueCard` widget <!-- id: 5 -->
    - [x] Rename text from "Randevu Al" to "İncele" or "Detay" for horizontal cards.

- [x] Clean up `ServicesTab` <!-- id: 3 -->
    - [x] Remove any references to adding services to a booking list.
    - [x] Update button click handlers.

- [x] Global Search & Replace for "Randevu" <!-- id: 4 -->
    - [x] Search for remaining instances of "Randevu" in UI strings and replace with appropriate contact wording.
