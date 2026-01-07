# Design Document: Venue Follow System with Notifications

## Context
The application needs a venue following system that allows users to track their favorite venues and receive notifications about campaigns and updates. The current codebase has:
- Basic `follows` table in database (from database spec)
- Stub follow/unfollow methods in `VenueRepository`
- Non-functional "Takip Et" button in `VenueIdentityV2` widget
- Existing Firebase notification infrastructure in `NotificationService`

This change makes the follow system fully functional and integrates it with push notifications.

## Goals / Non-Goals

### Goals
- Users can follow/unfollow venues with visual feedback
- Users understand that following enables notification permissions (one-time education)
- Venues can send targeted notifications to their followers (in-app + push)
- FCM tokens are properly stored and managed for push notification delivery
- Provide clear documentation for Firebase setup steps

### Non-Goals
- Venue admin dashboard for sending notifications (future feature)
- Advanced notification preferences per venue (e.g., "only campaigns")
- Notification rate limiting/scheduling (handled in future backend implementation)
- Follow recommendations or "suggested venues"
- Social features (followers list, public follow counts)

## Decisions

### 1. Follow State Management
**Decision:** Track follow state in `VenueDetailsProvider` and fetch it when venue details load.

**Why:**
- Centralized state management for the venue details screen
- Avoids prop drilling through multiple widget layers
- Easy to refresh state after follow/unfollow actions

**Alternatives considered:**
- Global follow state in a separate provider → Too complex for single-screen feature
- Local widget state → Would lose state on navigation and be harder to test

### 2. One-Time Education Pattern
**Decision:** Use `SharedPreferences` to track if user has seen the follow info bottom sheet.

**Why:**
- Simple key-value storage for boolean flag
- Persists across app restarts
- Doesn't require server-side tracking

**Key:** `has_seen_follow_info` (boolean)

**Alternatives considered:**
- Store in user profile table → Unnecessary database call for UI-only state
- Show on every follow → Annoying user experience

### 3. FCM Token Storage
**Decision:** Store FCM tokens in `profiles` table with `fcm_token` (text) and `fcm_token_updated_at` (timestamp) columns.

**Why:**
- Tokens can expire or refresh, need to track freshness
- Direct association with user for targeted notifications
- Enables backend to query active tokens for venue followers

**Token Refresh Strategy:**
- Update token on app start if older than 7 days
- Update on FCM token refresh callback
- Delete token on logout

**Alternatives considered:**
- Separate `fcm_tokens` table → Over-engineering for 1:1 relationship
- Store in local storage only → Can't send notifications when app is closed

### 4. Notification Flow
**Decision:** Two-tier notification system (already in place, we're extending it):

**In-App Notifications:**
- Stored in `notifications` table with `venue_id` reference
- Displayed in notifications screen
- Marked as read/deleted by user

**Push Notifications:**
- Sent via Firebase Cloud Messaging to user's device
- Trigger in-app notification creation on delivery
- Can open app to specific venue when tapped

**Why:**
- In-app ensures users see notifications even if push is disabled
- Push provides real-time engagement when app is backgrounded
- Dual approach maximizes reach

### 5. Unfollow Confirmation
**Decision:** Show confirmation dialog with "Emin misiniz?" message before unfollowing.

**Why:**
- Prevents accidental unfollows
- Explains consequence (won't receive notifications anymore)
- Standard UX pattern for destructive actions

**Dialog Copy:**
```
Title: "Takipten Çık?"
Body: "Bu mekanı takipten çıkarsanız, kampanya ve bildirimlerini artık almayacaksınız."
Actions: "Vazgeç" (cancel), "Takipten Çık" (confirm, destructive style)
```

### 6. UI/UX Changes

**Follow Button States:**
1. **Not Following:**
   - Text: "Takip Et"
   - Style: Primary color background with 10% opacity, primary text
   - Icon: Notification bell icon (outlined) next to text

2. **Following:**
   - Text: "Takip Ediliyor"
   - Style: Primary color background (filled), white text
   - Icon: Notification bell icon (filled) next to text

3. **Loading:**
   - Text: "..." or spinner
   - Disabled state

**Icon Placement:**
- Small bell icon to the left of button text
- 16x16 size, vertically centered
- 6px spacing between icon and text

### 7. Firebase Setup (Deferred Configuration)
**Decision:** Document Firebase setup steps but defer actual configuration to later.

**Why:**
- User will provide Firebase credentials separately
- Setup requires external Firebase Console access
- Implementation can proceed with mock/test mode FCM

**Documentation Location:** `docs/firebase-setup.md`

**Required Information (to be provided later):**
- Android: `google-services.json` → `android/app/google-services.json`
- iOS: `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`
- FCM Server Key (for backend notification sending)

## Risks / Trade-offs

### Risk: FCM Token Expiry
**Impact:** Users won't receive push notifications if tokens expire and aren't refreshed.

**Mitigation:**
- Implement token refresh listener in `NotificationService`
- Update token in database on every refresh
- Re-request token on app start if current token is old (>7 days)

### Risk: User Denies Notification Permission
**Impact:** Users can follow venues but won't receive push notifications.

**Mitigation:**
- Still store in-app notifications (users can check notifications screen)
- Show educational message explaining benefit of enabling notifications
- Don't block follow action if permission is denied (graceful degradation)

### Risk: Database Query Performance
**Impact:** Checking follow state for every venue could slow down discovery/list views.

**Mitigation:**
- Only fetch follow state on venue details screen (not in list/map views)
- Use database index on `(user_id, venue_id)` in `follows` table
- Consider caching follow states locally for visited venues (future optimization)

### Trade-off: One-Time Info vs. Always Show
**Decision:** Show follow info bottom sheet only once (first follow).

**Rationale:**
- Reduces friction for repeat follows
- Users who follow multiple venues don't need repeated education
- Can be re-shown if user denies permissions and later wants to enable

**Alternative:** Show every time → Better education but worse UX

## Migration Plan

### Phase 1: Database Schema (Safe to run in production)
```sql
-- Add FCM token columns to profiles
ALTER TABLE profiles
  ADD COLUMN fcm_token TEXT,
  ADD COLUMN fcm_token_updated_at TIMESTAMPTZ;

-- Add venue_id to notifications (for tracking which venue sent the notification)
ALTER TABLE notifications
  ADD COLUMN venue_id UUID REFERENCES venues(id) ON DELETE SET NULL;

-- Ensure follows table has proper index (may already exist)
CREATE INDEX IF NOT EXISTS idx_follows_user_venue ON follows(user_id, venue_id);
CREATE INDEX IF NOT EXISTS idx_follows_venue ON follows(venue_id); -- For querying followers
```

### Phase 2: Code Deployment
- Deploy updated Flutter app with new follow functionality
- Users can start following venues immediately
- FCM tokens will be collected and stored

### Phase 3: Firebase Configuration (Manual, Later)
- User provides Firebase credentials
- Add `google-services.json` and `GoogleService-Info.plist`
- Configure FCM server key in backend/Supabase Edge Functions
- Test push notification delivery

### Rollback Plan
- If critical bug in follow system:
  - Revert to previous app version
  - Database schema changes are additive (safe to keep)
- If FCM issues:
  - Disable push notification sending from backend
  - In-app notifications continue to work

## Open Questions
1. ~~Should we show notification count badge on the bell icon?~~ → No, it's just a visual indicator
2. ~~Do we need different notification types (campaign, news, update)?~~ → Not in this phase, can add later
3. **When venue admin dashboard is built, what notification rate limits should apply?** → Defer to dashboard implementation
4. **Should we track notification open rates?** → Future analytics feature
