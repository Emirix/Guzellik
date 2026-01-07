# Change: Add Supabase Backend

## Why
The project needs a backend for data persistence, authentication, and server-side logic (Edge Functions) to support the beauty services platform features like venue discovery and notifications.

## What Changes
- Set up Supabase database schema for users, venues, and services.
- Configure Supabase Auth and RLS policies.
- Implement an Edge Function for sending push notifications via FCM.
- Integrate Supabase into the Flutter app.

## Impact

### Affected Specs
- `database`: Core data schema for profiles, venues, and services (NEW)
- `edge-functions`: Server-side logic for notifications and integrations (NEW)

### Affected Code
- `lib/main.dart`: Supabase initialization
- `pubspec.yaml`: New dependencies
- `lib/data/repositories/`: New data access layer
