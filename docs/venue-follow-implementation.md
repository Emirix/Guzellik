# Venue Follow System - Implementation Notes

## Overview
This document provides implementation notes and code examples for the venue follow system with notification support.

## Database Schema

### Profiles Table Updates
```sql
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS fcm_token TEXT,
  ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMPTZ;
```

### Notifications Table Updates
```sql
ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS venue_id UUID REFERENCES venues(id) ON DELETE SET NULL;
```

### Indexes
```sql
CREATE INDEX IF NOT EXISTS idx_follows_user_venue ON follows(user_id, venue_id);
CREATE INDEX IF NOT EXISTS idx_follows_venue ON follows(venue_id);
CREATE INDEX IF NOT EXISTS idx_notifications_venue_id ON notifications(venue_id) WHERE venue_id IS NOT NULL;
```

## Code Structure

### Data Models
- **Venue**: Added `isFollowing` and `followerCount` fields
- **NotificationModel**: Added `venueId` field for venue-sent notifications

### Repositories
- **VenueRepository**: 
  - `checkIfFollowing(venueId)` - Check if user follows a venue
  - `followVenue(venueId)` - Follow a venue
  - `unfollowVenue(venueId)` - Unfollow a venue
  
- **AuthRepository**:
  - `saveFcmToken(token)` - Save FCM token to user profile
  - `clearFcmToken()` - Clear FCM token on logout

### Services
- **NotificationService**: Enhanced with FCM token refresh listener

### Providers
- **VenueDetailsProvider**:
  - `isFollowing` - Current follow state
  - `isFollowLoading` - Loading state for follow actions
  - `followVenue()` - Follow venue and update state
  - `unfollowVenue()` - Unfollow venue and update state

### UI Components
- **FollowInfoBottomSheet**: One-time educational bottom sheet about notifications
- **UnfollowConfirmationDialog**: Confirmation dialog before unfollowing
- **VenueIdentityV2**: Updated with functional follow button

## Follow Flow

### First-Time Follow
1. User taps "Takip Et" button
2. Check if user is authenticated (redirect to login if not)
3. Check if user has seen follow info (`has_seen_follow_info` in SharedPreferences)
4. If not seen, show `FollowInfoBottomSheet`
5. Request notification permissions if user agrees
6. Call `followVenue()` in repository
7. Get FCM token and save to user profile
8. Update local state and show success message

### Subsequent Follows
1. User taps "Takip Et" button
2. Check authentication
3. Skip info bottom sheet (already seen)
4. Call `followVenue()` in repository
5. Ensure FCM token is saved
6. Update local state and show success message

### Unfollow Flow
1. User taps "Takip Ediliyor" button
2. Show `UnfollowConfirmationDialog`
3. If confirmed, call `unfollowVenue()` in repository
4. Update local state and show success message

## Notification Sending (Backend)

### Example: Send Notification to Followers
```typescript
// Supabase Edge Function example
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const { venueId, title, body } = await req.json();
  
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // Get followers with FCM tokens
  const { data: followers } = await supabase
    .from('follows')
    .select('user_id, profiles!inner(fcm_token)')
    .eq('venue_id', venueId)
    .not('profiles.fcm_token', 'is', null);

  // Send FCM notifications
  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY');
  
  for (const follower of followers) {
    const token = follower.profiles.fcm_token;
    
    // Send push notification
    await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${fcmServerKey}`,
      },
      body: JSON.stringify({
        to: token,
        notification: { title, body },
        data: {
          type: 'venue_notification',
          venue_id: venueId,
        },
      }),
    });

    // Create in-app notification
    await supabase.from('notifications').insert({
      user_id: follower.user_id,
      venue_id: venueId,
      title,
      body,
      type: 'opportunity',
    });
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

## Testing Checklist

### Manual Testing
- [ ] Follow a venue (first time) - should show info bottom sheet
- [ ] Follow a venue (subsequent) - should skip info bottom sheet
- [ ] Unfollow a venue - should show confirmation dialog
- [ ] Follow while not authenticated - should show error message
- [ ] Check FCM token is saved to database after follow
- [ ] Send test notification to followers
- [ ] Verify notification appears in-app and as push

### Edge Cases
- [ ] Network error during follow/unfollow
- [ ] User denies notification permissions
- [ ] FCM token refresh while app is running
- [ ] Multiple rapid follow/unfollow taps
- [ ] Follow button state persists after app restart

## Troubleshooting

### Follow button not updating
- Check `VenueDetailsProvider` is properly provided in widget tree
- Verify `checkIfFollowing()` is called in `loadVenueDetails()`
- Check database for follow record

### Notifications not received
- Verify FCM token is saved in `profiles` table
- Check Firebase Console for delivery status
- Ensure notification permissions are granted
- Test with Firebase Console "Send test message"

### Info bottom sheet shows every time
- Check `SharedPreferences` key `has_seen_follow_info`
- Verify `setBool()` is called after showing sheet

## Future Enhancements
- [ ] Venue admin dashboard for sending notifications
- [ ] Notification preferences per venue
- [ ] Follow recommendations
- [ ] Follower count display
- [ ] Notification analytics
