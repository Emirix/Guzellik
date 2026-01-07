# Change: Implement Venue Follow System with Notification Support

## Why
Users need a way to stay connected with their favorite venues and receive updates about campaigns, special offers, and news. Currently, the follow button exists in the UI but is non-functional, and there's no user feedback or notification integration when users follow venues.

## What Changes
- Implement functional venue follow/unfollow with user feedback
- Add one-time informational bottom sheet explaining notification permissions when user first follows a venue
- Add visual notification indicator icon next to the "Takip Et" button
- Add confirmation dialog for unfollowing venues
- Integrate Firebase Cloud Messaging (FCM) for push notifications to followers
- Store FCM tokens in user profiles for targeted notification delivery
- Enable venues to send both in-app and push notifications to their followers
- Document Firebase setup requirements for future configuration

## Impact
- Affected specs: `venue-following` (new), `notifications` (modified), `database` (modified)
- Affected code:
  - `lib/presentation/widgets/venue/v2/venue_identity_v2.dart` - Follow button implementation
  - `lib/data/repositories/venue_repository.dart` - Follow/unfollow logic
  - `lib/data/services/notification_service.dart` - FCM token management
  - `lib/data/models/venue.dart` - Add follow state tracking
  - Database schema - Add FCM token storage, notification metadata
  - New components: Follow confirmation dialogs, info bottom sheet
