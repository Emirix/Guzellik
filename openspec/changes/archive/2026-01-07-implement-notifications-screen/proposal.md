# Change: Implement Notifications Screen

## Why
Users currently have no way to view their notification history or manage their notifications within the app. A dedicated screen is needed to provide a central hub for venue updates, offers, and system messages to improve user engagement.

## What Changes
- **Database**: Dedicated `notifications` table for persistent storage.
- **Data Layer**: Notification model and repository for CRUD operations.
- **Provider**: State management for real-time updates and filtering.
- **UI**: Premium notifications screen with category tabs (All, Fırsatlar, Sistem) and date-based grouping.
- **Features**: Swipe-to-delete, Mark all as read, and unread indicators.

## Impact
- **Affected specs**: `notifications` (new capability), `database` (MODIFIED).
- **Affected code**: `lib/presentation/screens/notifications_screen.dart`, `lib/data/services/notification_service.dart`.
