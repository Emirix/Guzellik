# Firebase Cloud Messaging (FCM) Setup Guide

This guide explains how to configure Firebase Cloud Messaging for the Güzellik app to enable push notifications for venue followers.

## Prerequisites

- Firebase project created at [Firebase Console](https://console.firebase.google.com/)
- Flutter project with Firebase dependencies already added (see `pubspec.yaml`)

## Step 1: Register Android App

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Click "Add app" → Select Android
4. Enter package name: `com.example.guzellik` (or your actual package name from `android/app/build.gradle`)
5. Download `google-services.json`
6. Place the file at: `android/app/google-services.json`

**File location:**
```
android/
  app/
    google-services.json  ← Place here
    build.gradle
```

## Step 2: Register iOS App

1. In Firebase Console, click "Add app" → Select iOS
2. Enter iOS bundle ID: `com.example.guzellik` (or your actual bundle ID from `ios/Runner.xcodeproj`)
3. Download `GoogleService-Info.plist`
4. Place the file at: `ios/Runner/GoogleService-Info.plist`

**File location:**
```
ios/
  Runner/
    GoogleService-Info.plist  ← Place here
    Info.plist
```

**Important:** Open Xcode and drag `GoogleService-Info.plist` into the Runner folder to ensure it's properly linked.

## Step 3: Enable Cloud Messaging API

1. In Firebase Console, go to **Project Settings** → **Cloud Messaging** tab
2. Under **Cloud Messaging API (Legacy)**, note the **Server key** (you'll need this for backend)
3. Enable **Cloud Messaging API (V1)** if not already enabled

## Step 4: Configure Android

The following should already be in place (verify in your project):

### `android/build.gradle`
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

### `android/app/build.gradle`
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

## Step 5: Configure iOS

### `ios/Runner/Info.plist`
Add the following if not present:
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### Enable Push Notifications Capability
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → Signing & Capabilities
3. Click "+ Capability" → Add "Push Notifications"
4. Click "+ Capability" → Add "Background Modes"
5. Check "Remote notifications" under Background Modes

## Step 6: Upload APNs Authentication Key (iOS only)

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
2. Create a new key with "Apple Push Notifications service (APNs)" enabled
3. Download the `.p8` key file
4. In Firebase Console → Project Settings → Cloud Messaging → iOS app configuration
5. Upload the APNs Authentication Key:
   - Key ID: (from Apple Developer Portal)
   - Team ID: (your Apple Developer Team ID)
   - Upload the `.p8` file

## Step 7: Retrieve FCM Server Key (for Backend)

The FCM Server Key is needed to send notifications from your backend (Supabase Edge Functions or other server).

1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Under **Cloud Messaging API (Legacy)**, copy the **Server key**
3. Store this securely in your backend environment variables

**Example usage in Supabase Edge Function:**
```typescript
const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY');

const response = await fetch('https://fcm.googleapis.com/fcm/send', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `key=${FCM_SERVER_KEY}`,
  },
  body: JSON.stringify({
    to: userFcmToken,
    notification: {
      title: 'Yeni Kampanya!',
      body: 'Mekanınızdan yeni bir kampanya var.',
    },
    data: {
      type: 'venue_notification',
      venue_id: venueId,
    },
  }),
});
```

## Step 8: Test FCM Setup

### Test on Android
```bash
flutter run
```
Check logs for:
```
Notification permissions granted
FCM Token: <your-token>
```

### Test on iOS
```bash
flutter run
```
Ensure you're testing on a **real device** (FCM doesn't work on iOS Simulator).

### Send Test Notification
1. Go to Firebase Console → Cloud Messaging → Send test message
2. Enter the FCM token from your app logs
3. Send a test notification
4. Verify it appears on your device

## Step 9: Database Migration

Run the following SQL in your Supabase SQL Editor to add FCM token storage:

```sql
-- Add FCM token columns to profiles
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS fcm_token TEXT,
  ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMPTZ;

-- Add venue_id to notifications
ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS venue_id UUID REFERENCES venues(id) ON DELETE SET NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_follows_user_venue ON follows(user_id, venue_id);
CREATE INDEX IF NOT EXISTS idx_follows_venue ON follows(venue_id);
```

Or run the migration file:
```bash
# If using Supabase CLI
supabase db push
```

## Troubleshooting

### Android: "Default FirebaseApp is not initialized"
- Ensure `google-services.json` is in `android/app/`
- Verify `apply plugin: 'com.google.gms.google-services'` is in `android/app/build.gradle`
- Run `flutter clean && flutter pub get`

### iOS: "FirebaseApp.configure() not called"
- Ensure `GoogleService-Info.plist` is in Xcode project
- Check that Firebase is initialized in `main.dart` before `runApp()`

### No FCM Token Received
- Check notification permissions are granted
- Verify Firebase configuration files are correctly placed
- Check device has internet connection
- For iOS, ensure testing on real device (not simulator)

### Notifications Not Appearing
- Check notification permissions in device settings
- Verify FCM server key is correct
- Check notification payload format
- Review device logs for errors

## Security Notes

- **Never commit** `google-services.json` or `GoogleService-Info.plist` to public repositories
- Add them to `.gitignore` if needed
- Store FCM Server Key securely in environment variables
- Rotate keys periodically for security

## Next Steps

After completing this setup:
1. Test follow/unfollow functionality
2. Verify FCM tokens are saved to user profiles
3. Test sending notifications to followers
4. Monitor notification delivery rates in Firebase Console

## References

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Setup](https://firebase.flutter.dev/docs/overview)
- [FCM HTTP v1 API](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)
