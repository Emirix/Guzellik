# Implementation Tasks

## 1. Database Schema Updates
- [x] 1.1 Add `fcm_token` and `fcm_token_updated_at` columns to `profiles` table
- [x] 1.2 Verify `follows` table exists with proper indexes (user_id, venue_id, created_at)
- [x] 1.3 Add `venue_id` foreign key to `notifications` table for venue-sent notifications
- [x] 1.4 Create database migration script
- [ ] 1.5 Test schema changes in development environment (requires manual Supabase migration)

## 2. Firebase Configuration Documentation
- [x] 2.1 Create `docs/firebase-setup.md` with step-by-step FCM configuration guide
- [x] 2.2 Document required Firebase Console settings (Android/iOS app registration)
- [x] 2.3 Document where to place `google-services.json` and `GoogleService-Info.plist`
- [x] 2.4 Document FCM server key retrieval for backend notification sending

## 3. Data Layer - Models
- [x] 3.1 Add `isFollowing` field to `Venue` model
- [x] 3.2 Add `followerCount` field to `Venue` model (optional, for future stats)
- [x] 3.3 Update `Venue.fromJson()` to handle follow state
- [x] 3.4 Update `NotificationModel` to include `venueId` field

## 4. Data Layer - Repository & Services
- [x] 4.1 Implement `checkIfFollowing(venueId)` in `VenueRepository`
- [x] 4.2 Add error handling to `followVenue()` and `unfollowVenue()` methods
- [x] 4.3 Implement `saveFcmToken(token)` in `AuthRepository`
- [x] 4.4 Implement `getFcmToken()` and update token on app start in `NotificationService`
- [x] 4.5 Create `sendNotificationToFollowers(venueId, title, body)` method (backend placeholder - documented)

## 5. UI Components - Dialogs & Bottom Sheets
- [x] 5.1 Create `FollowInfoBottomSheet` widget with notification permission explanation
- [x] 5.2 Create `UnfollowConfirmationDialog` widget with "Emin misiniz?" message
- [x] 5.3 Add shared preference key to track if user has seen follow info (one-time display)
- [x] 5.4 Style dialogs according to app theme (nude/gold colors)

## 6. UI Components - Follow Button
- [x] 6.1 Add notification bell icon next to "Takip Et" button in `VenueIdentityV2`
- [x] 6.2 Implement follow state management in `VenueDetailsProvider`
- [x] 6.3 Update button text: "Takip Et" → "Takip Ediliyor" when followed
- [x] 6.4 Update button style when followed (filled vs outlined)
- [x] 6.5 Add loading state during follow/unfollow API calls
- [x] 6.6 Show success snackbar after follow/unfollow actions
- [x] 6.7 Handle unauthenticated users (redirect to login or show auth prompt)

## 7. Follow Flow Integration
- [x] 7.1 On "Takip Et" tap: Check if user is authenticated
- [x] 7.2 On first follow: Show `FollowInfoBottomSheet` (one-time)
- [x] 7.3 On follow success: Update UI state, request FCM permission if needed, save FCM token
- [x] 7.4 On "Takip Ediliyor" tap: Show `UnfollowConfirmationDialog`
- [x] 7.5 On unfollow confirm: Call `unfollowVenue()`, update UI state

## 8. Notification Integration
- [x] 8.1 Ensure `NotificationService.initialize()` is called on app start (already implemented)
- [x] 8.2 Request FCM permissions after first follow action
- [x] 8.3 Save FCM token to user profile in Supabase on token refresh
- [x] 8.4 Handle FCM token refresh events
- [ ] 8.5 Update notification click handlers to navigate to venue details when notification is from a venue (requires router integration)

## 9. Testing
- [ ] 9.1 Unit test: `checkIfFollowing()` returns correct state
- [ ] 9.2 Unit test: Follow/unfollow updates database correctly
- [ ] 9.3 Widget test: Follow button shows correct state
- [ ] 9.4 Widget test: UnfollowConfirmationDialog appears and functions
- [ ] 9.5 Widget test: FollowInfoBottomSheet displays on first follow only
- [ ] 9.6 Integration test: Complete follow → notification permission → FCM token save flow
- [ ] 9.7 Manual test: Send test FCM notification to followed venue's followers

## 10. Documentation
- [x] 10.1 Update README with Firebase setup instructions reference
- [x] 10.2 Add code comments explaining follow state management
- [x] 10.3 Document notification payload structure for venue notifications
- [x] 10.4 Create example notification sending script (for testing)
