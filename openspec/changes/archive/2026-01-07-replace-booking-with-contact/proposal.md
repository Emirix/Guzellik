# Proposal: Replace Booking System with Contact Button

## Problem
The application currently has a booking (randevu) system implementation in several places, including a "Booking Bottom Bar" and "Add to Booking" buttons on service cards. The user has decided that a booking system is not desired at this stage and wants to replace these actions with a general "Contact" (İletişime Geç) button.

## Solution
Remove all internal booking logic and UI elements. Replace the primary "Randevu Oluştur" action with "İletişime Geç". This button will trigger a contact action (e.g., opening a bottom sheet with contact options like WhatsApp, Phone, etc.).

## Scope
- Update `VenueDetailsScreen` to handle the new contact action.
- Modify `BookingBottomBar` to become `ContactBottomBar` (or simply update its label and icon).
- Update `ServiceCard` to remove "Randevuya Ekle" or replace it with "Bilgi Al".
- Update `VenueCard` to replace "Randevu Al" with "İncele".
- Clean up any "Add to booking" logic/snackbars.
- Ensure all "Randevu" related terminology is replaced with contact-oriented wording.

## Benefits
- Simpler user flow.
- Direct communication between users and venus.
- Reduced complexity by removing the need for a full booking management system.
